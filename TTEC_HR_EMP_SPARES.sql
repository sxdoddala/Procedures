create or replace PROCEDURE ttec_hr_emp_spares (
    errbuf      OUT VARCHAR2,
    retcode     OUT NUMBER,
    p_bus_grp   IN NUMBER
) IS

  /***********************************************************************************
       Program Name: ttec_emp_spares

       Description:  This program gets the informaion about TTEC HRSOFT EMP Spares Details

       Called By   : TTEC HRSOFT EMP SPARES Details Concurrent Program

       Created by:        Rajasekar

       Date:              26-Sep-2019

       Modification Log

       Mod#    Date     Author     Description (Include Ticket#)
	           19-May-2023        MXKEERTHI(ARGANO)       1.0          R12.2 Upgrade Remediation
      -----  --------  --------    ----------------------------------------------

         */

    output_file     utl_file.file_type;
    v_cnt           NUMBER := 0;
    v_last_run_dt   DATE;
    v_filename      VARCHAR2(50) := 'Compensation_TTEC_Emp_Spares'
     || TO_CHAR(
        SYSDATE,
        'YYYYMMDD_HH24MISS'
    )
     || '.dat';
    v_directory     VARCHAR2(500);
    CURSOR c_emp_spares IS
       SELECT
            papf.employee_number,
           -- PJD.SEGMENT1,
            null chg_by,
            null chg_date,
            NULL dept_name,
            NULL dept_code,
            (
                SELECT
                    location_code
                FROM
                    apps.hr_locations
                WHERE
                    location_id = paaf.location_id
            ) location,
            papf.sex gender,
            pj.attribute20 career_level,
            pj.attribute2 bonus_type,
            NULL jan_ema_elig_flag,
            NULL ema_year_to_date_y1,
            NULL ema_year_to_date_y2,
            NULL ema_year_to_date_y3,
            NULL segment,
            paaf.employment_category employment_category,
            (
                SELECT
                    MAX(pafjob.effective_end_date) + 1 job_change_date
                FROM
				--hr.per_all_assignments_f pafjob  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
                  apps.per_all_assignments_f pafjob --code added by MXKEERTHI-ARGANO, 05/19/2023

               WHERE
                        pafjob.effective_start_date <= trunc(SYSDATE)
                    AND
                        pafjob.assignment_id = paaf.assignment_id
                    AND
                        nvl(
                            pafjob.job_id,
                            -1
                        ) <> nvl(
                            paaf.job_id,
                            -1
                        )
                GROUP BY
                    pafjob.assignment_id
            ) promotion_date,
            papf.date_of_birth date_of_birth,
            pj.attribute3 vip_bonus_tar_per
        FROM
            per_all_people_f papf,
            fnd_user fu,
            apps.per_all_assignments_f paaf,
            per_jobs pj,
            apps.hr_all_organization_units hou,
            per_job_definitions pjd
        WHERE
                paaf.last_updated_by = fu.user_id
            AND
                papf.person_id = paaf.person_id
            AND
                pj.job_id = paaf.job_id and
                papf.current_employee_flag='Y' AND
                paaf.organization_id = hou.organization_id
                AND
              papf.business_group_id = nvl(
                    p_bus_grp,
                    papf.business_group_id
                )
            AND
                trunc(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
            AND
                trunc(SYSDATE) BETWEEN paaf.effective_start_date (+) AND paaf.effective_end_date (+) and
                             pj.attribute5 NOT IN (
            'Agent'
        )
    AND
        hou.name NOT IN (
            'TELETECH UAE','TTEC-UAE-Sales','TTEC-UAE-New Business 025','TTEC-UAE-Operations','TTEC-UAE-Consulting Operations 003','TTEC-UAE-Administration'
,'TTEC-UAE-Noncorporate Administration 033','TeleTech Spain Global Services Costa Rica','TT PRG Turkey IC','TT PRG Turkey','PERCEPTA THAILAND'
        )
    AND
        paaf.employment_category NOT IN (
            'TTHK_CS','TTAU_FT_FTC','TTAU_CWK_PT','FTCWK','MX2_TEMP_WRK','TTAU_CWK_FT','TTAU_PT_FTC'
        )
        and (
                SELECT
                    location_code
                FROM
                    apps.hr_locations
                WHERE
                    location_id = paaf.location_id
            )not in ('TR-Turkey (PRG) 04440','AE-Dubai (PRG) 04425')
            AND
        pj.job_definition_id = pjd.job_definition_id
        and   pjd.segment1 NOT IN (
            'CSTMPS4'
        )
        AND pjd.segment1 NOT LIKE 'P%'
        and papf.employee_number is not null
        and pj.attribute20 not in ('AG')
        and papf.NPW_NUMBER is null;

BEGIN
    SELECT
        directory_path || '/data/EBS/HC/Payroll/HRSOFT/OUTBOUND'
    INTO
        v_directory
    FROM
        dba_directories
    WHERE
        directory_name = 'CUST_TOP';

    fnd_file.put_line(
        fnd_file.output,
        'TeleTech HRSOFT Employee Spares Details :  '
         || '   Date : '
         || TO_CHAR(
            SYSDATE,
            'MM/DD/YYYY HH24:MM'
        )
    );

    output_file := utl_file.fopen(
        v_directory,
        v_filename,
        'W'
    );
    utl_file.put_line(
        output_file,
        'EMPLOYEE_NUMBER|CHG_BY|CHG_DATE|DEPT_NAME|DEPT_CODE|LOCATION|GENDER|CAREER_LEVEL|BONUS_TYPE|JAN_EMA_ELIG_FLAG|EMA_YEAR_TO_DATE_Y1|EMA_YEAR_TO_DATE_Y2|EMA_YEAR_TO_DATE_Y3|SEGMENT|EMPLOYMENT_CATEGORY|PROMOTION_DATE|DATE_OF_BIRTH|VIP_BONUS_TARGET_PER'
    );
    FOR c1 IN c_emp_spares LOOP
        utl_file.put_line(
            output_file,
            c1.employee_number
             || '|'
             || c1.chg_by
             || '|'
             || c1.chg_date
             || '|'
             || c1.dept_name
             || '|'
             || c1.dept_code
             || '|'
             || c1.location
             || '|'
             || c1.gender
             || '|'
             || c1.career_level
             || '|'
             || c1.bonus_type
             || '|'
             || c1.jan_ema_elig_flag
             || '|'
             || c1.ema_year_to_date_y1
             || '|'
             || c1.ema_year_to_date_y2
             || '|'
             || c1.ema_year_to_date_y3
             || '|'
             || c1.segment
             || '|'
             || c1.employment_category
             || '|'
             || c1.promotion_date
             || '|'
             || c1.date_of_birth
             || '|'
             || c1.vip_bonus_tar_per
        );
    END LOOP;

    utl_file.fclose(output_file);
EXCEPTION
    WHEN OTHERS THEN
        utl_file.fclose(output_file);
END ttec_hr_emp_spares;
/
show errors;
/