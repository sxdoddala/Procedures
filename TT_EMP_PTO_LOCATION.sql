create or replace PROCEDURE tt_emp_pto_location ( errbuf OUT VARCHAR2,
                                           retcode OUT NUMBER,p_location_id IN NUMBER,p_date IN DATE)
IS
/*

 Modified by Elango on May 17 2007 for adding pay bases in main query
 
 
 /************************************************************************************
        Program Name: TT_EMP_PTO_LOCATION 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI(ARGANO)            1.0      19-May-2023      R12.2 Upgrade Remediation
    ****************************************************************************************/
   CURSOR c_emp
   IS
      SELECT papf.full_name, papf.employee_number, paaf.assignment_id,
              loc.location_code, org.NAME org_name,
              sup.full_name supervisor_name,
			  sup.employee_number sup_number,
			  ptp.regular_payment_date,pps.date_start st_dt,paaf.payroll_id pay_id,papf.person_id,ppb.name sal_basis
         FROM per_all_people_f papf,
              per_all_assignments_f paaf,
              per_pay_bases ppb,
			  per_time_periods ptp,
              HR_LOCATIONS loc,
              HR_ORGANIZATION_UNITS org,
              per_all_people_f sup,
              --hr.per_periods_of_service pps     --code commented by RXNETHI,19/05/23
              apps.per_periods_of_service pps     --code added by RXNETHI,19/05/23
        WHERE papf.person_id = paaf.person_id
          AND paaf.pay_basis_id = ppb.pay_basis_id
          AND ppb.business_group_id = papf.business_group_id
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
	  --AND pps.date_start = (SELECT MAX(pps1.date_start) FROM hr.per_periods_of_service pps1   --code commented by RXNETHI,19/05/23
	  AND pps.date_start = (SELECT MAX(pps1.date_start) FROM apps.per_periods_of_service pps1   --code added by RXNETHI,19/05/23
				WHERE pps1.person_id = pps.person_id)
		ORDER BY sup.full_name, papf.full_name;

   l_pto_orcl pay_action_information.action_information6%TYPE;

   l_start_date		DATE;
   l_end_date		DATE;
   l_accrual_end_date	DATE;
   l_accrual		NUMBER;
   l_entitlement	NUMBER;
   v_error	        varchar2(200);
   v_error1	        varchar2(200);
   v_year 		VARCHAR2(10);
   v_boy_bal 	VARCHAR2(20);


   CURSOR c_element (p_assignment_id IN NUMBER)
   IS
      SELECT peef.element_entry_id, peef.effective_start_date,
              peef.effective_end_date, ptp.period_name
         FROM pay_element_entries_f peef, per_time_periods ptp
        WHERE peef.element_type_id = 3215                             -- 'PTO'
          AND peef.assignment_id = p_assignment_id
          AND ptp.payroll_id = 45
          AND ptp.start_date = peef.effective_start_date
          AND ptp.end_date = peef.effective_end_date
          --AND peef.effective_start_date BETWEEN TRUNC (SYSDATE, 'RR') AND SYSDATE
	--	  AND ptp.end_date >=  TRUNC (SYSDATE, 'RR')
	--	  AND ptp.start_date <= SYSDATE
		  AND ptp.end_date >=  TRUNC (p_date, 'RR')
		  AND ptp.start_date <= p_date
		  ORDER BY 2;

   CURSOR c_element_value (p_element_entry_id IN NUMBER, p_value_name VARCHAR2)
   IS
      (SELECT peev.screen_entry_value
         FROM pay_input_values_f piv, pay_element_entry_values_f peev
        WHERE peev.input_value_id = piv.input_value_id
          AND peev.element_entry_id = p_element_entry_id
          AND piv.element_type_id = 3215                              -- 'PTO'
          AND piv.NAME = p_value_name
          AND piv.NAME IN ('Hours', 'Entry Effective Date')
         -- AND TRUNC (SYSDATE) BETWEEN piv.effective_start_date
           AND TRUNC (p_date) BETWEEN piv.effective_start_date
                                  AND piv.effective_end_date);


  CURSOR c_pto_bal(p_person_id IN NUMBER) IS
   SELECT A.action_information6
     FROM  apps.pay_action_information A
     WHERE A.action_context_id = (SELECT b.action_context_id
                         FROM PAY_EMP_PAYSLIP_ACTION_INFO_V b
                         WHERE b.person_id =  p_person_id
                          AND b.effective_date = (SELECT MAX(c.effective_date)
		                                  FROM  PAY_EMP_PAYSLIP_ACTION_INFO_V c
                                                               WHERE c.person_id =  p_person_id)
                          AND b.check_count = (SELECT MAX(d.check_count)
		                               FROM PAY_EMP_PAYSLIP_ACTION_INFO_V d
		                               WHERE d.person_id =  p_person_id  AND d.effective_date = b.effective_date))
         AND A.action_information_category  = 'EMPLOYEE ACCRUALS'
         AND A.action_information4 = 'PTO' ;

    CURSOR c_boy_bal(p_assignment_id IN NUMBER,p_year IN VARCHAR2) IS
     SELECT /*+ index(pee pay_element_entries_f_n53)*/
	   pev.screen_entry_value carryover
     FROM  pay_accrual_plans pap
               ,pay_element_entry_values_f pev
	, pay_element_entry_values_f pev1
	,pay_input_values_f piv
	, pay_input_values_f piv1
	, pay_element_entries_f pee
    WHERE  pap.accrual_plan_id = 134   -- "TeleTech PTO" Accrual Plan Id
    AND pee.assignment_id = p_assignment_id
    AND pee.element_entry_id = pev.element_entry_id
    AND pee.element_entry_id = pev1.element_entry_id
    AND pev.input_value_id = pap.co_input_value_id
    AND pev1.input_value_id = pap.co_exp_date_input_value_id
    AND pap.co_input_value_id = piv.input_value_id
    AND pap.co_exp_date_input_value_id = piv1.input_value_id
    AND TRUNC(SYSDATE) BETWEEN  piv.effective_start_date AND piv.effective_end_date
    AND TRUNC(SYSDATE) BETWEEN piv1.effective_start_date AND piv1.effective_end_date
    AND pee.element_type_id = piv.element_type_id
    AND pee.element_type_id = piv1.element_type_id
    AND NVL(SUBSTR(pev1.screen_entry_value,1,4),TO_CHAR(SYSDATE,'YYYY'))  = p_year;


   l_hours                  VARCHAR2 (60);
   l_entry_effective_date   VARCHAR2 (60);
BEGIN

    v_year := NVL(TO_CHAR(p_date,'YYYY'),TO_CHAR(SYSDATE,'YYYY'));

    Fnd_File.PUT_LINE (  Fnd_File.output, 'Employee Full Name'
                               || '|'
                               || 'Employee Oracle ID'
                               || '|'
                               || 'BOY Balance'
                               || '|'
                               || 'PTO Balance'
                               || '|'
                               || 'Hours'
                               || '|'
                               || 'Entry Effective Date'
                               || '|'
                               || 'Period Name'
                               || '|'
                               || 'Location Code'
                               || '|'
                               || 'Organization'
                               || '|'
                               || 'Supervisor Name'
                               || '|'
                               || 'Supervisor Oracle ID'
                               || '|'
                               || 'Start Date'
                               || '|'
		  ||' Current Salary Basis'
                              );



   FOR r_emp IN c_emp
   LOOP
    BEGIN
      l_pto_orcl := NULL;
      OPEN c_pto_bal(r_emp.person_id);
	FETCH c_pto_bal INTO l_pto_orcl;
      CLOSE c_pto_bal;
     v_boy_bal := NULL;
      OPEN c_boy_bal(r_emp.assignment_id,v_year);
	FETCH c_boy_bal INTO v_boy_bal;
      CLOSE c_boy_bal;
      l_hours := NULL;
      FOR r_element IN c_element (r_emp.assignment_id)
      LOOP
       BEGIN
         l_hours := NULL;
         l_entry_effective_date := NULL;
         OPEN c_element_value (r_element.element_entry_id, 'Hours');
            FETCH c_element_value      INTO l_hours;
         CLOSE c_element_value;

         OPEN c_element_value (r_element.element_entry_id,'Entry Effective Date'   );
             FETCH c_element_value   INTO l_entry_effective_date;
         CLOSE c_element_value;

	    Fnd_File.PUT_LINE ( Fnd_File.output,  r_emp.full_name
                               || '|'
                               || r_emp.employee_number
                               || '|'
                               || v_boy_bal
                               || '|'
                               || l_pto_orcl
                               || '|'
                               || l_hours
                               || '|'
                               || l_entry_effective_date
                               || '|'
                               || r_element.period_name
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
                               || '|'
		  || r_emp.sal_basis
                              );
       EXCEPTION
  	WHEN OTHERS THEN
            v_error1 := SUBSTR(SQLERRM,1,150);
	    Fnd_File.PUT_LINE ( Fnd_File.output,'Inner Exception for assignment_id : '||r_emp.assignment_id||' Error : '||v_error1);
      END;
      END LOOP;
      IF l_hours IS NULL
      THEN
         Fnd_File.PUT_LINE ( Fnd_File.output,  r_emp.full_name
                               || '|'
                               || r_emp.employee_number
                               || '|'
                               || v_boy_bal
                               || '|'
                               || l_pto_orcl
                               || '|'
                               || ''        --l_hours
                               || '|'
                               || ''       --l_entry_effective_date
                               || '|'
                               || ''      --r_element.period_name
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
                               || '|'
		  || r_emp.sal_basis
                              );
      END IF;
    EXCEPTION
	WHEN OTHERS THEN
            v_error := SUBSTR(SQLERRM,1,150);
	    Fnd_File.PUT_LINE ( Fnd_File.output,'Error in Exception for person id : '||r_emp.person_id||' Error : '||v_error);
    END;
   END LOOP;

END tt_emp_pto_location;
/
show errors;
/