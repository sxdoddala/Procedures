create or replace PROCEDURE      ttec_emp_atelka (
/************************************************************************************
        Program Name: TTEC_PO_TSG_INTERFACE 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
   MXKEERTHI(ARGANO)  19-May-2023           1.0          R12.2 Upgrade Remediation
    ****************************************************************************************/

    errbuf    OUT VARCHAR2,
    retcode   OUT VARCHAR2
) IS

    v_dir_path   VARCHAR2(250);
    v_dt_DATE    VARCHAR2(12);
    v_dt_MONTH    VARCHAR2(12);
    v_dt_YEAR    VARCHAR2(12);
    v_re_file    utl_file.file_type;
    CURSOR ttec_atelka_cursor IS
        SELECT DISTINCT
            papf.employee_number,
            papf.last_name,
            NULL middle_name,
            papf.first_name,
            ppb.name salary_basis,
            c.address_line1 address1,
            c.address_line2 address2,
            c.town_or_city city,
            c.region_1 state,
            c.postal_code,
            c.country,
            user_status employee_status,
            TO_CHAR(
                ppos.adjusted_svc_date,
                'mm/dd/yyyy'
            ) adjusted_service_date,
            papf.email_address,
            pjb.name job_code,
            papf.national_identifier ssn,
            hrl.location_code,
            papf_sup.national_identifier supervisor,
            c.telephone_number_1 phone_number,
            DECODE(
                papf.sex,
                'M',
                'Male',
                'F',
                'Female'
            ) gender,
            TO_CHAR(
                papf.date_of_birth,
                'mm/dd/yyyy'
            ) date_of_birth,
            NULL salary,
            sob.name ledger,
            gcc.segment1 location_code_1,
            gcc.segment2 client,
            gcc.segment3 department,
            gcc.segment4 account,
            pcak.segment1 gl_location_code,
            pcak.segment2 gl_client_code,
            pcak.segment3 gl_department_code,
            papf.attribute15 atelka_id,
            papf.attribute29 us_mgr,
            normal_hours,
            TO_CHAR(
                ppos.actual_termination_date,
                'mm/dd/yyyy'
            ) actual_termination_date,
            TO_CHAR(
                papf.original_date_of_hire,
                'mm/dd/yyyy'
            ) latest_start_date,
            papf.correspondence_language,
            pea.segment3 account_number,
            pea.segment4 transit_code,
            pea.segment5 bank_name,
            pcep.additional_tax prov_addional_tax,
            pcef.additional_tax fed_additional_tax,
                CASE
                    WHEN to_number(papf.attribute30) BETWEEN 1000 AND 50000THEN 'OLD HIRED'
                    ELSE 'NEW HIRED'
                END
            AS atelka_flag,
            (
                SELECT
    --(pp.proposed_salary_n * b.pay_annualization_factor) salary
                    pp.proposed_salary_n salary
                FROM
                    per_all_assignments_f a,
                    per_pay_proposals pp,
                    per_pay_bases b
                WHERE
                        trunc(SYSDATE + 30) BETWEEN a.effective_start_date AND a.effective_end_date
                    AND
                        pp.assignment_id = a.assignment_id
                    AND
                        a.assignment_id = paaf.assignment_id
                    AND
                        change_date IN (
                            SELECT
                                MAX(change_date)
                            FROM
                                per_pay_proposals pp
                            WHERE
                                assignment_id = paaf.assignment_id
                        )
                    AND
                        b.pay_basis_id = a.pay_basis_id
            ) salary_1,
            clt_cd client_code,
            prog_cd program_code,
            prj_cd project_code,
            tepa.prj_strt_dt,
            tepa.prj_end_dt
        FROM
		     --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
            hr.per_all_people_f papf,
            hr.per_all_assignments_f paaf,
            hr.per_periods_of_service ppos,
            hr.per_periods_of_placement ppop,
            hr.hr_locations_all hrl,
            hr.per_jobs pjb,
            hr.per_person_types pt,
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
            apps.per_all_people_f papf,
            apps.per_all_assignments_f paaf,
            apps.per_periods_of_service ppos,
            apps.per_periods_of_placement ppop,
            apps.hr_locations_all hrl,
            apps.per_jobs pjb,
            apps.per_person_types pt,
	  --END R12.2.10 Upgrade remediation


            per_pay_bases ppb,
            per_addresses c,
			 -- hr.per_all_people_f papf_sup,  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
            apps.per_all_people_f papf_sup,--code added by MXKEERTHI-ARGANO, 05/19/2023
            apps.gl_sets_of_books sob,
            apps.gl_code_combinations gcc,
			 --hr.pay_cost_allocations_f pca,  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
            apps.pay_cost_allocations_f pca,--code added by MXKEERTHI-ARGANO, 05/19/2023
			 --  hr.pay_cost_allocation_keyflex pcak,--Commented code by MXKEERTHI-ARGANO, 05/19/2023
            apps.pay_cost_allocation_keyflex pcak,--code added by MXKEERTHI-ARGANO, 05/19/2023
            apps.per_assignment_status_types past,
            pay_personal_payment_methods_f pppm,
            pay_external_accounts pea,
            pay_ca_emp_prov_tax_info_f pcep,
            pay_ca_emp_fed_tax_info_f pcef,
            apps.ttec_emp_proj_asg tepa
        WHERE
                papf.person_id = paaf.person_id
            AND
                pppm.assignment_id (+) = paaf.assignment_id
            AND
                pea.external_account_id (+) = pppm.external_account_id
            AND
                payee_type IS NULL
            AND
                pcep.assignment_id (+) = paaf.assignment_id
            AND
                pcef.assignment_id (+) = paaf.assignment_id
            AND
                paaf.assignment_type IN (
                    'E','C'
                )
            AND
                paaf.primary_flag = 'Y'
            AND
                paaf.period_of_service_id = ppos.period_of_service_id (+)
            AND
                paaf.person_id = ppop.person_id (+)
            AND
                paaf.period_of_placement_date_start = ppop.date_start (+)
            AND
                trunc(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
            AND
                paaf.effective_start_date = (
                    SELECT
                        MAX(paaf2.effective_start_date)
                    FROM
					 -- hr.per_all_assignments_f paaf2  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
                        apps.per_all_assignments_f paaf2 --code added by MXKEERTHI-ARGANO, 05/19/2023
                   WHERE
                            paaf2.person_id = paaf.person_id
                        AND
                            paaf2.effective_start_date <= trunc(SYSDATE)
                        AND
                            paaf2.primary_flag = 'Y'
                )
            AND
                papf.business_group_id = paaf.business_group_id
            AND
                paaf.business_group_id = 326
            AND
                paaf.location_id = hrl.location_id (+)
            AND
                paaf.job_id = pjb.job_id (+)
            AND
                ppb.pay_basis_id (+) = paaf.pay_basis_id
            AND
                c.person_id (+) = papf.person_id
            AND
                sob.set_of_books_id (+) = paaf.set_of_books_id
            AND
                gcc.code_combination_id (+) = paaf.default_code_comb_id
            AND
                pca.assignment_id (+) = paaf.assignment_id
            AND
                pca.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id (+)
            AND
                papf.national_identifier IS NOT NULL
            AND
                papf.business_group_id = 326
            AND
                pt.person_type_id = papf.person_type_id
            AND
                SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
            AND
                SYSDATE BETWEEN nvl(
                    pcef.effective_start_date,
                    SYSDATE
                ) AND nvl(
                    pcef.effective_end_date,
                    SYSDATE
                )
            AND
                SYSDATE BETWEEN nvl(
                    pcep.effective_start_date,
                    SYSDATE
                ) AND nvl(
                    pcep.effective_end_date,
                    SYSDATE
                )
            AND
                paaf.supervisor_id = papf_sup.person_id (+)
            AND
                past.assignment_status_type_id = paaf.assignment_status_type_id
            AND
                gcc.segment1 IN (
                    '05420','05421','05422','05423','05424','05425','05426','05427','05428','05429'
                )
            AND
                SYSDATE BETWEEN nvl(
                    c.date_from,
                    SYSDATE
                ) AND nvl(
                    c.date_to,
                    SYSDATE
                )
            AND
                c.primary_flag (+) = 'Y'
            AND
                SYSDATE BETWEEN nvl(
                    pca.effective_start_date,
                    SYSDATE
                ) AND nvl(
                    pca.effective_end_date,
                    SYSDATE
                )
            AND
                SYSDATE BETWEEN nvl(
                    pcak.start_date_active,
                    SYSDATE
                ) AND nvl(
                    pcak.end_date_active,
                    SYSDATE
                )
            AND
                SYSDATE BETWEEN nvl(
                    pppm.effective_start_date,
                    SYSDATE
                ) AND nvl(
                    pppm.effective_end_date,
                    SYSDATE
                )
            AND
                SYSDATE BETWEEN nvl(
                    papf_sup.effective_start_date,
                    SYSDATE
                ) AND nvl(
                    papf_sup.effective_end_date,
                    SYSDATE
                )
              AND
                tepa.person_id (+) = papf.person_id
            AND (
                    tepa.prj_end_dt IS NULL
                OR
                    tepa.prj_end_dt = (
                        SELECT
                            MAX(tepa1.prj_end_dt)
                        FROM
                            apps.ttec_emp_proj_asg tepa1
                        WHERE
                            tepa.person_id = tepa1.person_id
                    )
            )
--Order by employee_number
        UNION
        SELECT DISTINCT
            papf.employee_number,
            papf.last_name,
            NULL middle_name,
            papf.first_name,
            ppb.name salary_basis,
            c.address_line1 address1,
            c.address_line2 address2,
            c.town_or_city city,
            c.region_1 state,
            c.postal_code,
            c.country,
            user_status employee_status,
            TO_CHAR(
                ppos.adjusted_svc_date,
                'mm/dd/yyyy'
            ) adjusted_service_date,
            papf.email_address,
            pjb.name job_code,
            papf.national_identifier ssn,
            hrl.location_code,
            papf_sup.national_identifier supervisor,
            c.telephone_number_1 phone_number,
            DECODE(
                papf.sex,
                'M',
                'Male',
                'F',
                'Female'
            ) gender,
            TO_CHAR(
                papf.date_of_birth,
                'mm/dd/yyyy'
            ) date_of_birth,
            NULL salary,
            sob.name ledger,
            gcc.segment1 location_code,
            gcc.segment2 client,
            gcc.segment3 department,
            gcc.segment4 account,
            pcak.segment1 gl_location_code,
            pcak.segment2 gl_client_code,
            pcak.segment3 gl_department_code,
            papf.attribute15 atelka_id,
            papf.attribute29 us_mgr,
            normal_hours,
            TO_CHAR(
                ppos.actual_termination_date,
                'mm/dd/yyyy'
            ) actual_termination_date,
            TO_CHAR(
                papf.original_date_of_hire,
                'mm/dd/yyyy'
            ) latest_start_date,
            papf.correspondence_language,
            pea.segment3 account_number,
            pea.segment4 transit_code,
            pea.segment5 bank_name,
            pcep.additional_tax prov_addional_tax,
            pcef.additional_tax fed_additional_tax --,ORG_PAYMENT_METHOD_ID
            ,
                CASE
                    WHEN to_number(papf.attribute30) BETWEEN 1000 AND 50000THEN 'OLD HIRED'
                    ELSE 'NEW HIRED'
                END
            AS atelka_flag
  --
            ,
            (
                SELECT
    --(pp.proposed_salary_n * b.pay_annualization_factor) salary
                    pp.proposed_salary_n salary
                FROM
                    per_all_assignments_f a,
                    per_pay_proposals pp,
                    per_pay_bases b
                WHERE
                        trunc(SYSDATE + 30) BETWEEN a.effective_start_date AND a.effective_end_date
                    AND
                        pp.assignment_id = a.assignment_id
                    AND
                        a.assignment_id = paaf.assignment_id
                    AND
                        change_date IN (
                            SELECT
                                MAX(change_date)
                            FROM
                                per_pay_proposals pp
                            WHERE
                                assignment_id = paaf.assignment_id
                        )
                    AND
                        b.pay_basis_id = a.pay_basis_id
            ) salary,
            clt_cd client_code,
            prog_cd program_code,
            prj_cd project_code,
            tepa.prj_strt_dt,
            tepa.prj_end_dt
			    --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
        FROM
            hr.per_all_people_f papf,
            hr.per_all_assignments_f paaf,
            hr.per_periods_of_service ppos,
            hr.per_periods_of_placement ppop,
            hr.hr_locations_all hrl,
            hr.per_jobs pjb,
            hr.per_person_types pt,
            per_pay_bases ppb,
            per_addresses c,
            hr.per_all_people_f papf_sup,
            apps.gl_sets_of_books sob,
            apps.gl_code_combinations gcc,
            hr.pay_cost_allocations_f pca,
            hr.pay_cost_allocation_keyflex pcak,
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
        FROM
            apps.per_all_people_f papf,
            apps.per_all_assignments_f paaf,
            apps.per_periods_of_service ppos,
            apps.per_periods_of_placement ppop,
            apps.hr_locations_all hrl,
            apps.per_jobs pjb,
            apps.per_person_types pt,
            per_pay_bases ppb,
            per_addresses c,
            apps.per_all_people_f papf_sup,
            apps.gl_sets_of_books sob,
            apps.gl_code_combinations gcc,
            apps.pay_cost_allocations_f pca,
            apps.pay_cost_allocation_keyflex pcak,
	  --END R12.2.10 Upgrade remediation


            apps.per_assignment_status_types past,
            pay_personal_payment_methods_f pppm,
            pay_external_accounts pea,
            pay_ca_emp_prov_tax_info_f pcep,
            pay_ca_emp_fed_tax_info_f pcef,
            apps.ttec_emp_proj_asg tepa
        WHERE
                papf.person_id = paaf.person_id

            AND
                pppm.assignment_id (+) = paaf.assignment_id
            AND
                pea.external_account_id (+) = pppm.external_account_id
            AND
                payee_type IS NULL
            AND
                pppm.external_account_id IN (
                    SELECT
                        MAX(external_account_id)
                    FROM
                        pay_personal_payment_methods_f x
                    WHERE
                        x.assignment_id = paaf.assignment_id
                )
            AND
                pcep.assignment_id (+) = paaf.assignment_id
            AND
                pcef.assignment_id (+) = paaf.assignment_id
            AND
                paaf.assignment_type IN (
                    'E','C'
                )
            AND
                paaf.primary_flag = 'Y'
            AND
                paaf.period_of_service_id = ppos.period_of_service_id (+)
            AND
                paaf.person_id = ppop.person_id (+)
            AND
                paaf.period_of_placement_date_start = ppop.date_start (+)
            AND
                trunc(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
            AND
                paaf.effective_start_date = (
                    SELECT
                        MAX(paaf2.effective_start_date)
                    FROM
					 -- hr.per_all_assignments_f paaf2  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
                        apps.per_all_assignments_f paaf2  --code added by MXKEERTHI-ARGANO, 05/19/2023
                   WHERE
                            paaf2.person_id = paaf.person_id
                        AND
                            paaf2.effective_start_date <= trunc(SYSDATE)
                        AND
                            paaf2.primary_flag = 'Y'
                )
            AND
                papf.business_group_id = paaf.business_group_id
            AND
                paaf.business_group_id = 326
            AND
                paaf.location_id = hrl.location_id (+)
            AND
                paaf.job_id = pjb.job_id (+)
            AND
                ppb.pay_basis_id (+) = paaf.pay_basis_id
            AND
                c.person_id (+) = papf.person_id
            AND
                sob.set_of_books_id (+) = paaf.set_of_books_id
            AND
                gcc.code_combination_id (+) = paaf.default_code_comb_id
            AND
                pca.assignment_id (+) = paaf.assignment_id
            AND
                pca.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id (+)
            AND
                papf.national_identifier IS NOT NULL
            AND
                papf.business_group_id = 326
            AND
                pt.person_type_id = papf.person_type_id
            AND
                SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date --
            AND
                SYSDATE BETWEEN nvl(
                    pcef.effective_start_date,
                    SYSDATE
                ) AND nvl(
                    pcef.effective_end_date,
                    SYSDATE
                )
            AND
                SYSDATE BETWEEN nvl(
                    pcep.effective_start_date,
                    SYSDATE
                ) AND nvl(
                    pcep.effective_end_date,
                    SYSDATE
                )
            AND
                paaf.supervisor_id = papf_sup.person_id (+)
            AND
                past.assignment_status_type_id = paaf.assignment_status_type_id
            AND
                gcc.segment1 IN (
                    '05420','05421','05422','05423','05424','05425','05426','05427','05428','05429'
                )
            AND
                SYSDATE BETWEEN nvl(
                    c.date_from,
                    SYSDATE
                ) AND nvl(
                    c.date_to,
                    SYSDATE
                )
            AND
                c.primary_flag (+) = 'Y'
            AND
                SYSDATE BETWEEN nvl(
                    pca.effective_start_date,
                    SYSDATE
                ) AND nvl(
                    pca.effective_end_date,
                    SYSDATE
                )
            AND
                SYSDATE BETWEEN nvl(
                    pcak.start_date_active,
                    SYSDATE
                ) AND nvl(
                    pcak.end_date_active,
                    SYSDATE
                )
  --and sysdate between nvl(pppm.effective_start_date,sysdate) and nvl(pppm.effective_end_date,sysdate)
            AND
                SYSDATE BETWEEN nvl(
                    papf_sup.effective_start_date,
                    SYSDATE
                ) AND nvl(
                    papf_sup.effective_end_date,
                    SYSDATE
                )
            AND
                tepa.person_id (+) = papf.person_id
            AND (
                    tepa.prj_end_dt IS NULL
                OR
                    tepa.prj_end_dt = (
                        SELECT
                            MAX(tepa1.prj_end_dt)
                        FROM
                            apps.ttec_emp_proj_asg tepa1
                        WHERE
                            tepa.person_id = tepa1.person_id
                    )
            )
        ORDER BY 1;--employee_number;

BEGIN
    SELECT
        TO_CHAR(
            SYSDATE,
            'DD'
        )
    INTO
        v_dt_DATE
    FROM
        dual;

        SELECT
        TO_CHAR(
            SYSDATE,
            'MON'
        )
    INTO
        v_dt_MONTH
    FROM
        dual;

        SELECT
        TO_CHAR(
            SYSDATE,
            'YYYY'
        )
    INTO
        v_dt_YEAR
    FROM
        dual;

    fnd_file.put_line(
        fnd_file.log,
        'Generating report'
    );
    SELECT
        directory_path || '/data/dac_data/data_in'
    INTO
        v_dir_path
    FROM
        dba_directories
    WHERE
        directory_name = 'CUST_TOP';

--x_id:=utl_file.fopen('/d11/appldev1/DEV1/apps/apps_st/appl/teletech/12.0.0/data/dac_data/data_in','PROD_Full Atelka Emp list.csv','W');

    v_re_file := utl_file.fopen(
        v_dir_path,
        'PROD_Full_Atelka_Emp_list_by_LOC_' || v_dt_DATE || '_' || v_dt_MONTH|| '_' || v_dt_YEAR ||'.csv',
        'W',
        32767
    );
    utl_file.put_line(
        v_re_file,
        'EMPLOYEE_NUMBER,'
         || 'LAST_NAME,'
         || 'MIDDLE_NAME,'
         || 'FIRST_NAME,'
         || 'SALARY_BASIS,'
         || 'ADDRESS1,'
         || 'ADDRESS2,'
         || 'CITY,'
         || 'STATE,'
         || 'POSTAL_CODE,'
         || 'COUNTRY,'
         || 'EMPLOYEE_STATUS,'
         || 'ADJUSTED_SERVICE_DATE,'
         || 'EMAIL_ADDRESS,'
         || 'JOB_CODE,'
         || 'SSN,'
         || 'LOCATION_CODE,'
         || 'SUPERVISOR,'
         || 'PHONE_NUMBER,'
         || 'GENDER,'
         || 'DATE_OF_BIRTH,'
         || 'SALARY,'
         || 'LEDGER,'
         || 'LOCATION_CODE_1,'
         || 'CLIENT,'
         || 'DEPARTMENT,'
         || 'ACCOUNT,'
         || 'GL_LOCATION_CODE,'
         || 'GL_CLIENT_CODE,'
         || 'GL_DEPARTMENT_CODE,'
         || 'ATELKA_ID,'
         || 'US_MGR,'
         || 'NORMAL_HOURS,'
         || 'ACTUAL_TERMINATION_DATE,'
         || 'LATEST_START_DATE,'
         || 'CORRESPONDENCE_LANGUAGE,'
         || 'ACCOUNT_NUMBER,'
         || 'TRANSIT_CODE,'
         || 'BANK_NAME,'
         || 'PROV_ADDIONAL_TAX,'
         || 'FED_ADDITIONAL_TAX,'
         || 'ATELKA_FLAG,'
         || 'SALARY_1,'
         || 'CLIENT_CODE,'
         || 'PROGRAM_CODE,'
         || 'PROJECT_CODE,'
         || 'PRJ_STRT_DT,'
         || 'PRJ_END_DT,'
    );

    fnd_file.put_line(
        fnd_file.log,
        'Listing employees'
    );
    FOR i IN ttec_atelka_cursor LOOP
        utl_file.put_line(
            v_re_file,
            i.employee_number
             || ','
             || i.last_name
             || ','
             || i.middle_name
             || ','
             || i.first_name
             || ','
             || i.salary_basis
             || ','
             || '"'
             || i.address1
             || '"'
             || ','
             || i.address2
             || ','
             || i.city
             || ','
             || i.state
             || ','
             || i.postal_code
             || ','
             || i.country
             || ','
             || i.employee_status
             || ','
             || i.adjusted_service_date
             || ','
             || i.email_address
             || ','
             || '"'
             || i.job_code
             || '"'
             || ','
             || i.ssn
             || ','
             || '"'
             || i.location_code
             || '"'
             || ','
             || i.supervisor
             || ','
             || i.phone_number
             || ','
             || i.gender
             || ','
             || i.date_of_birth
             || ','
             || i.salary
             || ','
             || i.ledger
             || ','
             || i.location_code_1
             || ','
             || i.client
             || ','
             || i.department
             || ','
             || i.account
             || ','
             || i.gl_location_code
             || ','
             || i.gl_client_code
             || ','
             || i.gl_department_code
             || ','
             || i.atelka_id
             || ','
             || i.us_mgr
             || ','
             || i.normal_hours
             || ','
             || i.actual_termination_date
             || ','
             || i.latest_start_date
             || ','
             || i.correspondence_language
             || ','
             || i.account_number
             || ','
             || i.transit_code
             || ','
             || i.bank_name
             || ','
             || i.prov_addional_tax
             || ','
             || i.fed_additional_tax
             || ','
             || i.atelka_flag
             || ','
             || i.salary_1
             || ','
             || i.client_code
             || ','
             || i.program_code
             || ','
             || i.project_code
             || ','
             || i.prj_strt_dt
             || ','
             || i.prj_end_dt
        );

--        fnd_file.put_line(
--            fnd_file.log,
--            'C'
--        );
    END LOOP;

    fnd_file.put_line(
        fnd_file.log,
        'Report Generated'
    );
/*fnd_file.put_line(
        fnd_file.log,
        'File Name: ' || v_re_file
    );
--utl_file.fclose(x_id);
    utl_file.fclose(v_re_file);*/
EXCEPTION
    WHEN utl_file.invalid_path THEN
        fnd_file.put_line(
            fnd_file.log,
            'invalid path'
        );
        fnd_file.put_line(
            fnd_file.log,
            'Error during File generation process'
        );
        utl_file.fclose_all;
END ttec_emp_atelka;
/
show errors;
/