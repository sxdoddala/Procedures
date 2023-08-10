create or replace PROCEDURE ttec_carry_over ( errbuf OUT VARCHAR2,
                                           retcode OUT NUMBER,p_location_id IN NUMBER)
IS



 /************************************************************************************
        Program Name: TTEC_CARRY_OVER 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI(ARGANO)            1.0      19-May-2023      R12.2 Upgrade Remediation
    ****************************************************************************************/



  -- l_pto_orcl               NUMBER;
   l_pto_orcl pay_action_information.action_information6%TYPE;
   l_start_date		DATE;
   l_end_date		DATE;
   l_accrual_end_date	DATE;
   l_accrual		NUMBER;
   l_entitlement	NUMBER;
   v_error	        varchar2(200);
   v_error1	        varchar2(200);
   l_hours                  VARCHAR2 (60);
   l_entry_effective_date   VARCHAR2 (60);
   l_va_pl_ft_corp	NUMBER;
   l_va_pl_pt_corp	NUMBER;
   l_va_pl_ft_agent	NUMBER;
   l_va_pl_pt_agent	NUMBER;
   l_va_pl_ft_ga	NUMBER;
   l_va_pl_pt_ga	NUMBER;
   l_teletech_pto	NUMBER;


/*
SELECT accrual_plan_id,accrual_plan_name FROM  pay_accrual_plans
WHERE accrual_plan_name IN
('TeleTech PTO','Vacation Plan FT Agent','Vacation Plan FT CORP','Vacation Plan FT G_A',
'Vacation Plan PT Agent','Vacation Plan PT CORP','Vacation Plan PT G_A');

*/

   CURSOR c_emp
   IS
      SELECT papf.full_name, papf.employee_number, paaf.assignment_id,
              loc.location_code, org.NAME org_name,
              sup.full_name supervisor_name,
			  sup.employee_number sup_number,
			  ptp.regular_payment_date,pps.date_start st_dt,paaf.payroll_id pay_id,papf.person_id
         FROM per_all_people_f papf,
              per_all_assignments_f paaf,
			  per_time_periods ptp,
              HR_LOCATIONS loc,
              HR_ORGANIZATION_UNITS org,
              per_all_people_f sup,
              --hr.per_periods_of_service pps   --code commented by RXNETHI-ARGANO,19/05/23
              apps.per_periods_of_service pps   --code added by RXNETHI-ARGANO,19/05/23
        WHERE papf.person_id = paaf.person_id
          AND papf.current_employee_flag = 'Y'
		  AND paaf.payroll_id = ptp.payroll_id
		  AND TRUNC(SYSDATE) BETWEEN ptp.start_date AND ptp.end_date
          AND paaf.location_id = loc.location_id
          AND paaf.organization_id = org.organization_id
          AND paaf.supervisor_id = sup.person_id(+)
          AND TRUNC (SYSDATE) BETWEEN papf.effective_start_date
                                  AND papf.effective_end_date
          AND TRUNC (SYSDATE) BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
          AND TRUNC (SYSDATE) BETWEEN sup.effective_start_date(+)
		                          AND sup.effective_end_date(+)
          AND papf.business_group_id = 325
          AND paaf.location_id = NVL(p_location_id,paaf.location_id)  --622 'USA-Englewood (TTEC)'
          AND pps.person_id  = papf.person_id
	  --AND pps.date_start = (SELECT MAX(pps1.date_start) FROM hr.per_periods_of_service pps1   --code commented by RXNETHI-ARGANO,19/05/23
	  AND pps.date_start = (SELECT MAX(pps1.date_start) FROM apps.per_periods_of_service pps1   --code added by RXNETHI-ARGANO,19/05/23
				WHERE pps1.person_id = pps.person_id)
         -- AND paaf.payroll_id = 45                         --'Corporate (U4T)'
        --AND papf.employee_number = '3008824'
		ORDER BY sup.full_name, papf.full_name;

  CURSOR c_pto_bal(p_person_id IN NUMBER) IS
         SELECT a.action_information6
         FROM  apps.pay_action_information a
         WHERE a.action_context_id = (SELECT b.action_context_id
                                    FROM pay_emp_payslip_action_info_v b
		                            WHERE b.person_id = p_person_id
				                    AND b.effective_date = (SELECT MAX(c.effective_date)
							                              FROM  pay_emp_payslip_action_info_v c
	                                                      WHERE c.person_id = p_person_id)
				                    AND b.check_count = (SELECT MAX(d.check_count)
							                          FROM pay_emp_payslip_action_info_v d
							                          WHERE d.person_id = p_person_id AND d.effective_date = b.effective_date))
         AND a.action_information_category  = 'EMPLOYEE ACCRUALS'
         AND a.action_information4 = 'PTO' ;

BEGIN

    Fnd_File.PUT_LINE (  Fnd_File.output, 'Employee Full Name'
                               || '|'
                               || 'Employee Oracle ID'
                               || '|'
                               || 'PTO Balance'
                               || '|'
                               || 'Vacation Plan FT CORP'
                               || '|'
                               || 'Vacation Plan PT CORP'
                               || '|'
                               || 'Vacation Plan FT Agent'
                               || '|'
                               || 'Vacation Plan PT Agent'
                               || '|'
                               || 'Vacation Plan FT G_A'
                               || '|'
                               || 'Vacation Plan PT G_A'
                               || '|'
                               || 'TeleTech PTO');

   FOR r_emp IN c_emp
   LOOP
    BEGIN

      l_pto_orcl := NULL;

      OPEN c_pto_bal(r_emp.person_id);
	FETCH c_pto_bal INTO l_pto_orcl;
      CLOSE c_pto_bal;




	      l_va_pl_ft_corp := per_accrual_calc_functions.get_carry_over(
                                P_Assignment_ID    => r_emp.assignment_id
                               ,P_Plan_ID          => 62
                               ,P_Calculation_Date => '18-SEP-2006'
                               ,P_Start_Date       => '26-DEC-2005');

	      l_va_pl_pt_corp := per_accrual_calc_functions.get_carry_over(
                                P_Assignment_ID    => r_emp.assignment_id
                               ,P_Plan_ID          => 63
                               ,P_Calculation_Date => '18-SEP-2006'
                               ,P_Start_Date       => '26-DEC-2005');

	      l_va_pl_ft_agent := per_accrual_calc_functions.get_carry_over(
                                P_Assignment_ID    => r_emp.assignment_id
                               ,P_Plan_ID          => 47
                               ,P_Calculation_Date => '18-SEP-2006'
                               ,P_Start_Date       => '26-DEC-2005');

	      l_va_pl_pt_agent := per_accrual_calc_functions.get_carry_over(
                                P_Assignment_ID    => r_emp.assignment_id
                               ,P_Plan_ID          => 48
                               ,P_Calculation_Date => '18-SEP-2006'
                               ,P_Start_Date       => '26-DEC-2005');

	      l_va_pl_ft_ga := per_accrual_calc_functions.get_carry_over(
                                P_Assignment_ID    => r_emp.assignment_id
                               ,P_Plan_ID          => 49
                               ,P_Calculation_Date => '18-SEP-2006'
                               ,P_Start_Date       => '26-DEC-2005');

	      l_va_pl_pt_ga := per_accrual_calc_functions.get_carry_over(
                                P_Assignment_ID    => r_emp.assignment_id
                               ,P_Plan_ID          => 50
                               ,P_Calculation_Date => '18-SEP-2006'
                               ,P_Start_Date       => '26-DEC-2005');

	      l_teletech_pto := per_accrual_calc_functions.get_carry_over(
                                P_Assignment_ID    => r_emp.assignment_id
                               ,P_Plan_ID          => 134
                               ,P_Calculation_Date => '18-SEP-2006'
                               ,P_Start_Date       => '26-DEC-2005');



         Fnd_File.PUT_LINE ( Fnd_File.output,  r_emp.full_name
                               || '|'
                               || r_emp.employee_number
                               || '|'
                               || l_pto_orcl
                               || '|'
                               || l_va_pl_ft_corp
                               || '|'
                               || l_va_pl_pt_corp
                               || '|'
                               || l_va_pl_ft_agent
                               || '|'
                               || l_va_pl_pt_agent
                               || '|'
                               || l_va_pl_ft_ga
                               || '|'
                               || l_va_pl_pt_ga
                               || '|'
                               || l_teletech_pto
                               || '|'
                               || r_emp.location_code
                               || '|'
                               || r_emp.org_name
                               || '|'
                               || r_emp.supervisor_name
                               || '|'
                               || r_emp.sup_number
                               || '|'
                               || r_emp.st_dt
                              );

    EXCEPTION
	WHEN OTHERS THEN
            v_error := SUBSTR(SQLERRM,1,150);
	    Fnd_File.PUT_LINE ( Fnd_File.output,'Error in Exception for person id : '||r_emp.person_id||' Error : '||v_error);
    END;
   END LOOP;
END ttec_carry_over;
/
show errors;
/