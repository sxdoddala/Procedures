create or replace procedure TT_GROSS_TO_NET_REPORT
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

                          (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER,
						   P_BEGIN_DATE IN VARCHAR2,
						   P_END_DATE IN VARCHAR2
						   )  is

l_result_value  varchar2(60);
l_mandatory_flag varchar2(1);
    --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
 l_location   hr.pay_cost_allocation_keyflex.segment1%TYPE;
l_client     hr.pay_cost_allocation_keyflex.segment2%TYPE;
l_department hr.pay_cost_allocation_keyflex.segment3%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
l_location   apps.pay_cost_allocation_keyflex.segment1%TYPE;
l_client     apps.pay_cost_allocation_keyflex.segment2%TYPE;
l_department apps.pay_cost_allocation_keyflex.segment3%TYPE;
	  --END R12.2.10 Upgrade remediation


--l_begin_date  date:= to_date(P_BEGIN_DATE,'RRRR/MM/DD');
--l_end_date  date:= to_date(P_END_DATE,'RRRR/MM/DD');

-- Global Variables ---------------------------------------------------------------------------------
     --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
l_module_name   CUST.TTEC_error_handling.module_name%type := 'GROSS_TO_NET';


-- Variables used by Common Error Procedure
g_application_code          CUST.TTEC_error_handling.application_code%TYPE := 'HR';
g_interface                 CUST.TTEC_error_handling.interface%TYPE := 'GROSS';
g_program_name              CUST.TTEC_error_handling.program_name%TYPE := 'GROSS';
g_initial_status            CUST.TTEC_error_handling.status%TYPE := 'INITIAL';
g_warning_status            CUST.TTEC_error_handling.status%TYPE := 'WARNING';
g_failure_status            CUST.TTEC_error_handling.status%TYPE := 'FAILURE';
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
l_module_name   apps.TTEC_error_handling.module_name%type := 'GROSS_TO_NET';


-- Variables used by Common Error Procedure
g_application_code          apps.TTEC_error_handling.application_code%TYPE := 'HR';
g_interface                 apps.TTEC_error_handling.interface%TYPE := 'GROSS';
g_program_name              apps.TTEC_error_handling.program_name%TYPE := 'GROSS';
g_initial_status            apps.TTEC_error_handling.status%TYPE := 'INITIAL';
g_warning_status            apps.TTEC_error_handling.status%TYPE := 'WARNING';
g_failure_status            apps.TTEC_error_handling.status%TYPE := 'FAILURE';
	  --END R12.2.10 Upgrade remediation



-----------------------------------------------------------------------------------------------------
-- Cursor declarations ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
 CURSOR c_emp_result IS
   SELECT
              papf.full_name,
              papf.employee_number,
              asg.assignment_id,
              pya.business_group_id,
			  pya.payroll_id,
			  asg.location_id,
			  asg.organization_id,
     	      asa.assignment_action_id,
		      pya.effective_date,
			  pec.classification_name,
			  et.element_name,
			  et.reporting_name,  --description,
			  rr.run_result_id,
			  pya.action_type,
			  pya.consolidation_set_id
			       --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
 FROM   hr.pay_payroll_actions     pya,
         hr.pay_assignment_actions  asa,
         hr.per_all_assignments_f   asg,
         hr.per_all_people_f       papf,
	     hr.pay_run_results        rr,
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
FROM   apps.pay_payroll_actions     pya,
         apps.pay_assignment_actions  asa,
         apps.per_all_assignments_f   asg,
         apps.per_all_people_f       papf,
	     apps.pay_run_results        rr,
	  --END R12.2.10 Upgrade remediation

 
	     pay_element_types_f       et,
	     pay_element_classifications   pec
  WHERE
	pya.effective_date BETWEEN P_BEGIN_DATE and P_END_DATE
    --AND  pya.action_type  <> 'B'  -- B = Balance adjustment
	AND    pya.action_type in ('Q','R','V')
    AND    pya.payroll_action_id    = asa.payroll_action_id
    AND    asa.assignment_id = asg.assignment_id
    AND    pya.effective_date BETWEEN asg.effective_start_date  AND asg.effective_end_date
    AND    asg.person_id = papf.person_id
    AND    pya.effective_date BETWEEN papf.effective_start_date  AND  papf.effective_end_date
    and    asa.assignment_action_id = rr.assignment_action_id
    and    rr.element_type_id = et.element_type_id
	and    pya.effective_date BETWEEN et.effective_start_date  AND et.effective_end_date
    and    et.classification_id = pec.classification_id
     ;

  /************************************************************************************/
  /*                                  GET_RESULT_VALUE                                 */
  /************************************************************************************/
    PROCEDURE get_result_value
                     (p_run_result_id IN NUMBER, p_effective_date IN DATE,
                      p_mandatory_flag OUT VARCHAR2, p_result_value OUT VARCHAR2) IS

		CURSOR cur_result is
	  SELECT rrv.result_value, piv.mandatory_flag
	    FROM pay_input_values_f piv,
		 --  hr.pay_run_result_values rrv --Commented code by MXKEERTHI-ARGANO, 05/19/2023
		     apps.pay_run_result_values rrv  --code added by MXKEERTHI-ARGANO, 05/19/2023
      WHERE rrv.run_result_id = p_run_result_id
           AND p_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
           AND piv.uom = 'M'
		   AND piv.name ='Pay Value'
	       --AND rrv.result_value <> '0'
	       AND rrv.input_value_id = piv.input_value_id ;

    BEGIN
       open cur_result;
	   fetch cur_result into p_result_value , p_mandatory_flag;
	   close cur_result;


    EXCEPTION

             WHEN OTHERS THEN
				dbms_output.put_line(p_run_result_id);
				p_result_value := 0;
    END;

  /***********************End Result Value****************************/

  /************************************************************************************/
  /*                                  GET_EMP_COSTING                                 */
  /************************************************************************************/
    PROCEDURE get_emp_costing
                     (p_assignment_id IN NUMBER, p_effective_date IN DATE,
                      p_location OUT VARCHAR2, p_client OUT VARCHAR2,
					  p_department OUT VARCHAR2  ) IS

	CURSOR cur_cost is
	  SELECT cost.segment1 override_location,
			 cost.segment2 override_client,
			 cost.segment3 override_dept
	    FROM
             apps.pay_cost_allocations_f      pcaf,
             apps.pay_cost_allocation_keyflex cost
       WHERE
         pcaf.assignment_id = p_assignment_id
         and pcaf.cost_allocation_keyflex_id = cost.cost_allocation_keyflex_id
         and p_effective_date between pcaf.effective_start_date and pcaf.effective_end_date;

    BEGIN
       open cur_cost;
	   fetch cur_cost into p_location, p_client, p_department;
	   close cur_cost;


    EXCEPTION

             WHEN OTHERS THEN
				dbms_output.put_line(p_assignment_id);
    END;

  /***********************End Costing****************************/

  /************************************************************************************/
  /*                                  GET_LOCATION                                 */
  /************************************************************************************/
    PROCEDURE get_location
                     (p_location_id IN NUMBER, p_effective_date IN DATE,
                      p_location OUT VARCHAR2  ) IS

	CURSOR cur_loc is
	  SELECT loc.attribute2
	    FROM
		 --  hr.hr_locations_all loc --Commented code by MXKEERTHI-ARGANO, 05/19/2023
             apps.hr_locations_all loc --code added by MXKEERTHI-ARGANO, 05/19/2023
      WHERE
         loc.location_id = p_location_id
		 AND NVL(loc.inactive_date, p_effective_date +1) >= p_effective_date;

    BEGIN
       open cur_loc;
	   fetch cur_loc into p_location;
	   close cur_loc;

    EXCEPTION

             WHEN OTHERS THEN
				dbms_output.put_line(p_location_id);
    END;

  /***********************End Location****************************/

  /************************************************************************************/
  /*                                  GET_DEPARTMENT                                 */
  /************************************************************************************/
    PROCEDURE get_department
                     (p_organization_id IN NUMBER, p_department OUT VARCHAR2  ) IS

	CURSOR cur_dept is
	  SELECT cost_org.concatenated_segments override_dept
	    FROM
		     --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
           hr.hr_all_organization_units     org,
		   hr.pay_cost_allocation_keyflex cost_org
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
           apps.hr_all_organization_units     org,
		   apps.pay_cost_allocation_keyflex cost_org
	  --END R12.2.10 Upgrade remediation
      WHERE
           org.ORGANIZATION_ID = p_organization_id
		   AND org.COST_ALLOCATION_KEYFLEX_ID = cost_org.COST_ALLOCATION_KEYFLEX_ID;

    BEGIN
       open cur_dept;
	   fetch cur_dept into  p_department;
	   close cur_dept;


    EXCEPTION

             WHEN OTHERS THEN
				dbms_output.put_line(p_organization_id);
    END;

  /***********************End Department****************************/


BEGIN
    dbms_output.put_line(to_char(sysdate,'DD-MON-RRRR-HH24-MI-SS'));

	--execute immediate 'truncate table tt_gross_to_net';
	delete from tt_gross_to_net where report_type = 'GTN';
	commit;



    FOR rec_emp_result IN  c_emp_result LOOP

	 BEGIN
	     l_mandatory_flag := null;
		 l_result_value := '0';
		 l_location  := null;
		 l_client    := null;
		 l_department := null;

		 get_result_value
	        (rec_emp_result.RUN_RESULT_ID, rec_emp_result.effective_date,
			l_mandatory_flag, l_result_value);

	     if l_result_value <> '0' then

		   get_emp_costing
             (rec_emp_result.assignment_id, rec_emp_result.effective_date,
              l_location, l_client, l_department);

		   if l_location is null and rec_emp_result.location_id is not null then
		     get_location
             (rec_emp_result.location_id,rec_emp_result.effective_date,
			 l_location );
		   end if;

		   if l_department is null and rec_emp_result.organization_id is not null then
		     get_department
             (rec_emp_result.organization_id,
			 l_department);
		   end if;



          insert into tt_gross_to_net
		   values
		   (rec_emp_result.FULL_NAME,
            rec_emp_result.EMPLOYEE_NUMBER,
            l_LOCATION,
            l_CLIENT,
            l_DEPARTMENT,
            rec_emp_result.CLASSIFICATION_NAME,
            rec_emp_result.ELEMENT_NAME,
            l_RESULT_VALUE,
            rec_emp_result.EFFECTIVE_DATE,
            rec_emp_result.ASSIGNMENT_ACTION_ID,
            rec_emp_result.REPORTING_NAME,
            rec_emp_result.RUN_RESULT_ID,
            l_MANDATORY_FLAG,
			rec_emp_result.business_group_id,
            rec_emp_result.ACTION_TYPE,
			'GTN',
			rec_emp_result.consolidation_set_id,
			rec_emp_result.payroll_id);

			commit;

		  end if;  -- result value <> 0

	  EXCEPTION
	       when others then
		       dbms_output.put_line(rec_emp_result.EMPLOYEE_NUMBER);
			   dbms_output.put_line(sqlerrm);

      END;

    END LOOP;

	commit;

    dbms_output.put_line(to_char(sysdate,'DD-MON-RRRR-HH24-MI-SS'));


EXCEPTION
  WHEN OTHERS THEN
   --  CUST.TTEC_PROCESS_ERROR (g_application_code, g_interface, g_program_name, l_module_name,--Commented code by MXKEERTHI-ARGANO, 05/19/2023
        apps.TTEC_PROCESS_ERROR (g_application_code, g_interface, g_program_name, l_module_name,--code added by MXKEERTHI-ARGANO, 05/19/2023
                         'FAILURE', SQLCODE, SQLERRM);
		COMMIT;
		RAISE;

END;
/
show errors;
/