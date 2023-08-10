create or replace PROCEDURE ttec_user_insert( errbuf OUT VARCHAR2,retcode OUT NUMBER,p_mode IN VARCHAR2,p_bus_grp IN NUMBER)
IS

/***********************************************************************************
     Program Name: ttec_user_insert

     Description:  This program gets the user informaion from fnd user, per all peoplef and assignment table and reates UserInsert.dat

     Called By   : TeleTech Taleo User Insert Outbound Interface Concurrent Program

     Created by:        Elango Pandu

     Date:              Feb 25,2007

     Modification Log

     Mod#    Date     Author     Description (Include Ticket#)
    -----  --------  --------    ----------------------------------------------
     001  07/31/2008 MLagostena   T# - Fix Oracle outbound code to assign pseudo business group id
     002  07-29-2009 C. Chan     WO#584809 - Add Order by to the outbound file
	 003  19/MAY/2023 RXNETHI-ARGANO  R12.2 Upgrade Remediation
*/


   output_file utl_file.file_type;
   v_cnt NUMBER := 0;
   v_last_run_dt DATE;
   v_filename1   VARCHAR2(50)  := 'User_one_'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS')||'.csv';
   v_filename2   VARCHAR2(50)  := 'User_two_'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS')||'.csv';
   v_bus_grp_name hr_organization_units.name%TYPE;

  CURSOR c_user IS
	  SELECT DISTINCT
	    ppl.employee_number emp_num ,
	    UPPER(SUBSTR(ppl.first_name,1,1)||SUBSTR(ppl.last_name,1,1))||TO_CHAR(ppl.date_of_birth,'MMDDYYYY') pwd,
	    4 role,
	    ppl.first_name first_name,
	    substr(ppl.middle_names,1,1) m_initial,
	    ppl.last_name last_name,
	    ppl.employee_number emp_id,
	    nvl(ppl.email_address,'no_email_address@teletech.com') email_address,
	    2  product,
	    'true' force_pwd,
	    APPS.ttec_get_bg(ppl.business_group_id, asg.ORGANIZATION_ID) user_group_1,
	    null user_group_2,
	    pjd.segment2  Job_title,
	    asg.organization_id department_id,
       	   ppl.effective_start_date start_date,
   	   ppl.effective_end_date end_date
	FROM
	    apps.per_all_people_f ppl,
	    apps.per_all_assignments_f asg,
	    apps.per_jobs pj,
	    apps.per_job_definitions pjd
	WHERE  ppl.person_id = asg.person_id
	AND    asg.job_id = pj.job_id
	AND    pj.job_definition_id = pjd.job_definition_id
	AND    ppl.current_employee_flag = 'Y'
	AND    asg.primary_flag = 'Y'
	AND    pj.attribute5 != 'Agent'
	AND    ppl.business_group_id != 0
	AND    ppl.business_group_id = NVL(p_bus_grp,ppl.business_group_id)
	AND    TRUNC(SYSDATE) BETWEEN ppl.effective_start_date AND ppl.effective_end_date
	AND    TRUNC(SYSDATE) BETWEEN asg.effective_start_date AND asg.effective_end_date
    ORDER BY ppl.employee_number,ppl.effective_start_date,ppl.effective_end_date -- 002 Added By C. Chan on 7/29/2009 for WO#584809
    ;




   CURSOR c_upd_user IS
	  SELECT DISTINCT
	    ppl.employee_number emp_num ,ppl.effective_start_date ppl_strt_dt,asg.effective_start_date asg_strt_dt,
	    UPPER(SUBSTR(ppl.first_name,1,1)||SUBSTR(ppl.last_name,1,1))||TO_CHAR(ppl.date_of_birth,'MMDDYYYY') pwd,
	    4 role,
	    ppl.first_name first_name,
	    substr(ppl.middle_names,1,1) m_initial,
	    ppl.last_name last_name,
	    ppl.employee_number emp_id,
	    nvl(ppl.email_address,'no_email_address@teletech.com') email_address,
	    2  product,
	    'true' force_pwd,
	    APPS.ttec_get_bg(ppl.business_group_id, asg.ORGANIZATION_ID) user_group_1,
	    null user_group_2,
	    pjd.segment2  Job_title,
	    asg.organization_id department_id,
	    per_srvc.actual_termination_date start_date,
                  (CASE WHEN per_srvc.actual_termination_date IS NOT NULL THEN
		           per_srvc.actual_termination_date + 1
                              ELSE
		      NULL END) end_date
	FROM
	    apps.per_all_people_f ppl,
	    apps.per_all_assignments_f asg,
	    apps.per_jobs pj,
	    apps.per_job_definitions pjd,
  	   (SELECT person_id,date_start,actual_termination_date
                   --FROM hr.per_periods_of_service pps    --code commented by RXNETHI-ARGANO,19/05/23
                   FROM apps.per_periods_of_service pps    --code added by RXNETHI-ARGANO,19/05/23
                   WHERE date_start = (SELECT MAX (pps2.date_start)
                                                    --FROM hr.per_periods_of_service pps2     --code commented by RXNETHI-ARGANO,19/05/23
                                                    FROM apps.per_periods_of_service pps2     --code added by RXNETHI-ARGANO,19/05/23
                                                    WHERE pps2.person_id = pps.person_id)) per_srvc
	WHERE  ppl.person_id = asg.person_id
	AND    asg.job_id = pj.job_id
	AND    pj.job_definition_id = pjd.job_definition_id
	AND    asg.primary_flag = 'Y'
	AND    pj.attribute5 != 'Agent'
	AND    ppl.business_group_id != 0
	AND    ppl.business_group_id = NVL(p_bus_grp,ppl.business_group_id)
	AND    ppl.person_id = per_srvc.person_id
	AND    TRUNC(SYSDATE) BETWEEN ppl.effective_start_date AND ppl.effective_end_date
	AND    TRUNC(SYSDATE) BETWEEN asg.effective_start_date AND asg.effective_end_date
              AND  (GREATEST(ppl.last_update_date,asg.last_update_date) BETWEEN   v_last_run_dt AND SYSDATE
                        OR
                        GREATEST(ppl.creation_date,asg.creation_date) BETWEEN  v_last_run_dt  AND SYSDATE)
    ORDER BY 1,2,3 -- 002 Added By C. Chan on 7/29/2009 for WO#584809
;



   CURSOR c_last_run IS
   SELECT  MAX(TRUNC(actual_start_date)) FROM fnd_conc_req_summary_v
   WHERE  program_short_name = 'TTEC_USER_INSERT' AND phase_code = 'C'
   AND completion_text = 'Normal completion';

   CURSOR c_bus_grp IS
   SELECT name
   FROM hr_organization_units
   WHERE organization_id = business_group_id
	AND  business_group_id != 0
	AND  organization_id != 0
	AND organization_id = p_bus_grp;


BEGIN

    IF p_bus_grp IS NOT NULL THEN
          OPEN c_bus_grp;
	FETCH c_bus_grp INTO v_bus_grp_name;
           CLOSE c_bus_grp;
   ELSE
          v_bus_grp_name := 'All ';
   END IF;

    output_file := utl_file.fopen('/d01/oracle/prodappl/teletech/11.5.0/data/taleo/data_out',v_filename1,'W');
     FND_FILE.PUT_LINE (  Fnd_File.output, 'TeleTech Taleo User Insert Outbound Interface  Mode :  '|| p_mode||'  Business Group :  '|| v_bus_grp_name||'   Date : '||TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MM'));
     utl_file.put_line(output_file,'UserName1|UserName2|Identifier|Password|Role|FirstName|Initial|LastName|EmployeeNumberID|Email|Product|ForceNewPassword|UserGroupCustomerCode1|UserGroupCustomerCode2 |JobTitle|DepartmentNumber|StartDate|EndDate');

IF p_mode = 'Full File' THEN

       FOR c1 IN c_user LOOP
                 v_cnt := v_cnt + 1;
                IF v_cnt < 5000 THEN
                    utl_file.put_line(output_file,c1.emp_num||'|'||c1.emp_num||'|'||c1.emp_num||'|'||c1.pwd||'|'||c1.role||'|'||c1.first_name||'|'||c1.m_initial||'|'||c1.last_name||'|'||c1.emp_id||'|'||c1.email_address||'|'||c1.product||'|'||c1.force_pwd||'|'||c1.user_group_1||'|'||c1.user_group_2||'|'||c1.job_title||'|'||c1.department_id||'|'||c1.start_date||'|'||c1.end_date);
                ELSE
                    IF v_cnt = 5000 THEN
                        utl_file.fclose(output_file);
                        output_file := utl_file.fopen('/d01/oracle/prodappl/teletech/11.5.0/data/taleo/data_out',v_filename2,'W');
                        utl_file.put_line(output_file,'UserName1|UserName2|Identifier|Password|Role|FirstName|Initial|LastName|EmployeeNumberID|Email|Product|ForceNewPassword|UserGroupCustomerCode1|UserGroupCustomerCode2 |JobTitle|DepartmentNumber|StartDate|EndDate');
                   END IF;
                    utl_file.put_line(output_file,c1.emp_num||'|'||c1.emp_num||'|'||c1.emp_num||'|'||c1.pwd||'|'||c1.role||'|'||c1.first_name||'|'||c1.m_initial||'|'||c1.last_name||'|'||c1.emp_id||'|'||c1.email_address||'|'||c1.product||'|'||c1.force_pwd||'|'||c1.user_group_1||'|'||c1.user_group_2||'|'||c1.job_title||'|'||c1.department_id||'|'||c1.start_date||'|'||c1.end_date);
                  END IF;
       END LOOP;
ELSE
     OPEN c_last_run;
	FETCH c_last_run INTO v_last_run_dt;
      CLOSE c_last_run;
      IF v_last_run_dt IS NOT NULL THEN
            FOR c1 IN c_upd_user LOOP
                 v_cnt := v_cnt + 1;
                IF v_cnt < 5000 THEN
                    utl_file.put_line(output_file,c1.emp_num||'|'||c1.emp_num||'|'||c1.emp_num||'|'||c1.pwd||'|'||c1.role||'|'||c1.first_name||'|'||c1.m_initial||'|'||c1.last_name||'|'||c1.emp_id||'|'||c1.email_address||'|'||c1.product||'|'||c1.force_pwd||'|'||c1.user_group_1||'|'||c1.user_group_2||'|'||c1.job_title||'|'||c1.department_id||'|'||c1.start_date||'|'||c1.end_date);
                ELSE
                    IF v_cnt = 5000 THEN
                        utl_file.fclose(output_file);
                        output_file := utl_file.fopen('/d01/oracle/prodappl/teletech/11.5.0/data/taleo/data_out',v_filename2,'W');
                        utl_file.put_line(output_file,'UserName1|UserName2|Identifier|Password|Role|FirstName|Initial|LastName|EmployeeNumberID|Email|Product|ForceNewPassword|UserGroupCustomerCode1|UserGroupCustomerCode2 |JobTitle|DepartmentNumber|StartDate|EndDate');
                   END IF;
                    utl_file.put_line(output_file,c1.emp_num||'|'||c1.emp_num||'|'||c1.emp_num||'|'||c1.pwd||'|'||c1.role||'|'||c1.first_name||'|'||c1.m_initial||'|'||c1.last_name||'|'||c1.emp_id||'|'||c1.email_address||'|'||c1.product||'|'||c1.force_pwd||'|'||c1.user_group_1||'|'||c1.user_group_2||'|'||c1.job_title||'|'||c1.department_id||'|'||c1.start_date||'|'||c1.end_date);
                  END IF;
            END LOOP;
      ELSE
          FOR c1 IN c_user LOOP
                 v_cnt := v_cnt + 1;
                IF v_cnt < 5000 THEN
                    utl_file.put_line(output_file,c1.emp_num||'|'||c1.emp_num||'|'||c1.emp_num||'|'||c1.pwd||'|'||c1.role||'|'||c1.first_name||'|'||c1.m_initial||'|'||c1.last_name||'|'||c1.emp_id||'|'||c1.email_address||'|'||c1.product||'|'||c1.force_pwd||'|'||c1.user_group_1||'|'||c1.user_group_2||'|'||c1.job_title||'|'||c1.department_id||'|'||c1.start_date||'|'||c1.end_date);
                ELSE
                    IF v_cnt = 5000 THEN
                        utl_file.fclose(output_file);
                        output_file := utl_file.fopen('/d01/oracle/prodappl/teletech/11.5.0/data/taleo/data_out',v_filename2,'W');
                       utl_file.put_line(output_file,'UserName1|UserName2|Identifier|Password|Role|FirstName|Initial|LastName|EmployeeNumberID|Email|Product|ForceNewPassword|UserGroupCustomerCode1|UserGroupCustomerCode2 |JobTitle|DepartmentNumber|StartDate|EndDate');
                   END IF;
                    utl_file.put_line(output_file,c1.emp_num||'|'||c1.emp_num||'|'||c1.emp_num||'|'||c1.pwd||'|'||c1.role||'|'||c1.first_name||'|'||c1.m_initial||'|'||c1.last_name||'|'||c1.emp_id||'|'||c1.email_address||'|'||c1.product||'|'||c1.force_pwd||'|'||c1.user_group_1||'|'||c1.user_group_2||'|'||c1.job_title||'|'||c1.department_id||'|'||c1.start_date||'|'||c1.end_date);
                  END IF;
          END LOOP;
      END IF;
END IF; -- Mode end if
      utl_file.fclose(output_file);
EXCEPTION
	WHEN OTHERS THEN
                 utl_file.fclose(output_file);
END ttec_user_insert;
/
show errors;
/