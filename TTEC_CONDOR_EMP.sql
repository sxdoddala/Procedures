create or replace PROCEDURE      ttec_condor_emp (
    errbuf    OUT VARCHAR2,
    retcode   OUT VARCHAR2
) IS
/*== START ================================================================================================*\

    Author :   PAVITHRA SUBBURAJU
       Date:   JULY 04, 2018
       Desc:   This procedure provides the list of condor employees for the required client codes

  Modification History:

  Mod#  Date         Author       Description
 -----  ----------  ----------  ----------------------------------------------
   1.0  07/04/2019  PAVITHRA    Written to provide the list of condor employees
   1.1  09/26/2019  PAVITHRA    Changed the file format to csv
                                Changed comma to pipe delimter
   1.0  19/MAY/2023 RXNETHI-ARGANO  R12.2 Upgrade Remediation
\*== END ==================================================================================================*/
v_dir_path   VARCHAR2(250);
    v_dt_DATE    VARCHAR2(12);
    v_dt_MONTH    VARCHAR2(12);
    v_dt_YEAR    VARCHAR2(12);
     v_re_file    utl_file.file_type;

    CURSOR ttec_condor_cur IS
        SELECT DISTINCT
            papf.employee_number,
            papf.last_name,
            NULL middle_name,
            papf.first_name,
            ppb.name salary_basis,
            c.address_line1 address1,
            c.address_line2 address2,
            c.town_or_city city,
            c.region_2 state,
            c.postal_code,
            c.country,
            user_status employee_status,
            papf.original_date_of_hire adjusted_service_date,
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
            papf.date_of_birth,
            (
                SELECT
                    ( pp.proposed_salary_n * b.pay_annualization_factor ) salary
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
            ) yearly_salary,
            sob.name ledger--,paaf.DEFAULT_CODE_COMB_ID ,paaf.ORGANIZATION_ID
            ,
            gcc.segment1 gl_location_code,
            gcc.segment2 gl_client,
            gcc.segment3 gl_department,
            gcc.segment4 gl_account
-- ,pcak.segment1 CPP_LOCATION_CODE,pcak.segment2 CPP_CLIENT_CODE,pcak.segment3 CPP_DEPARTMENT_CODE
            ,
            papf.attribute12 condor_id,
            NULL us_mgr,
            ppos.actual_termination_date,
            papf.start_date actual_start_date
        /*
		START R12.2 Upgrade Remediation
		code commented by RXNETHI-ARGANO,19/05/23
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
            apps.per_assignment_status_types past,
            apps.pay_all_payrolls_f pay,
            apps.pay_people_groups ppg
	    */
		--code added by RXNETHI-ARGANO,19/05/23
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
            apps.per_assignment_status_types past,
            apps.pay_all_payrolls_f pay,
            apps.pay_people_groups ppg
		--END R12.2 Upgrade Remediation
        WHERE
                papf.person_id = paaf.person_id
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
                papf.business_group_id = paaf.business_group_id -- assures the business groups are the same
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
                pt.person_type_id = papf.person_type_id
            AND
                paaf.supervisor_id = papf_sup.person_id (+)
            AND
                past.assignment_status_type_id = paaf.assignment_status_type_id
--and gcc.segment1 IN ('01123','01424','01425','01426','01427','01428','01422','01423','01421','01412','01413')
            AND
                gcc.segment2 IN (
                    select lookup_code from apps.fnd_lookup_values_vl
          WHERE lookup_type = 'TTEC_CONDOR_CLIENT_CODES'
          AND enabled_flag = 'Y'
            AND TRUNC (SYSDATE) BETWEEN TRUNC (start_date_active)
                                    AND NVL (TRUNC (end_date_active),'31-DEC-4712')
                )
            AND
                trunc(SYSDATE + 30) BETWEEN c.date_from AND nvl(
                    c.date_to,
                    SYSDATE + 30
                ) -- 2648
            AND
                trunc(SYSDATE + 30) BETWEEN papf.effective_start_date AND papf.effective_end_date --  2638
            AND
                trunc(SYSDATE + 30) BETWEEN paaf.effective_start_date AND paaf.effective_end_date --  2638
            AND
                pay.payroll_id (+) = paaf.payroll_id
            AND
                ppg.people_group_id (+) = paaf.people_group_id
--and papf.employee_number = '4000018'--'3129701'--'3129443'--'3197569'
            AND
                papf.business_group_id = 325
        ORDER BY papf.employee_number;

       -- x_id utl_file.file_type;

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

--   x_id := utl_file.fopen(
--        '/d11/appldev1/DEV1/apps/apps_st/appl/teletech/12.0.0/TASK0784534',
--        'Full_Condor_Emp_list.csv',
--        'W'
--    );

    v_re_file := utl_file.fopen(
        v_dir_path,
        'Full_Condor_Emp_list_BY_GL_CLIENT_' || v_dt_DATE || '_' || v_dt_MONTH|| '_' || v_dt_YEAR ||'.csv',
        'W',
        32767
    );
    utl_file.put_line(
        v_re_file,
        'EMPLOYEE_NUMBER|'
         || 'LAST_NAME|'
         || 'MIDDLE_NAME|'
         || 'FIRST_NAME|'
         || 'SALARY_BASIS|'
         || 'ADDRESS1|'
         || 'ADDRESS2|'
         || 'CITY|'
         || 'STATE|'
         || 'POSTAL_CODE|'
         || 'COUNTRY|'
         || 'EMPLOYEE_STATUS|'
         || 'ADJUSTED_SERVICE_DATE|'
         || 'EMAIL_ADDRESS|'
         || 'JOB_CODE|'
         || 'SSN|'
         || 'LOCATION_CODE|'
         || 'SUPERVISOR|'
         || 'PHONE_NUMBER|'
         || 'GENDER|'
         || 'DATE_OF_BIRTH|'
         || 'YEARLY_SALARY|'
         || 'LEDGER|'
         || 'GL_LOCATION_CODE|'
         || 'GL_CLIENT|'
         || 'GL_DEPARTMENT|'
         || 'GL_ACCOUNT|'
         || 'CONDOR_ID|'
         || 'US_MGR|'
         || 'ACTUAL_TERMINATION_DATE|'
         || 'actual_start_date|');
           fnd_file.put_line(
        fnd_file.log,
        'Report Headers'
    );
    FOR i IN ttec_condor_cur LOOP
        utl_file.put_line(
            v_re_file,
            i.employee_number
             || '|'
             || i.last_name
             || '|'
             || i.middle_name
             || '|'
             || i.first_name
             || '|'
             || i.salary_basis
             || '|'
             || '"'
             || i.address1
             || '"'
             || '|'
             || i.address2
             || '|'
             || i.city
             || '|'
             || i.state
             || '|'
             || i.postal_code
             || '|'
             || i.country
             || '|'
             || i.employee_status
             || '|'
             || i.adjusted_service_date
             || '|'
             || i.email_address
             || '|'
             || '"'
             || i.job_code
             || '"'
             || '|'
             || i.ssn
             || '|'
             || '"'
             || i.location_code
             || '"'
             || '|'
             || i.supervisor
             || '|'
             || i.phone_number
             || '|'
             || i.gender
             || '|'
             || i.date_of_birth
             || '|'
             || i.yearly_salary
             || '|'
             || i.ledger
             || '|'
             || i.gl_location_code
             || '|'
             || i.gl_client
             || '|'
             || i.gl_department
             || '|'
             || i.gl_account
             || '|'
             || i.condor_id
             || '|'
             || i.us_mgr
             || '|'
             || i.actual_termination_date
             || '|'
             || i.actual_start_date
             || '|'
              );

       /* fnd_file.put_line(
            fnd_file.log,
            'C'
        );*/
    END LOOP;

    fnd_file.put_line(
        fnd_file.log,
        'Report Generated'
    );
  --  utl_file.fclose(x_id);
EXCEPTION
    WHEN utl_file.invalid_path THEN
        fnd_file.put_line(
            fnd_file.log,
            'invalid path'
        );
        utl_file.fclose_all;
    WHEN OTHERS THEN
        errbuf := sqlerrm;
        retcode := '2';
        fnd_file.put_line(
            fnd_file.log,
            errbuf
        );
END ttec_condor_emp;
/
show errors;
/