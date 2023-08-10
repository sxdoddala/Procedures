create or replace PROCEDURE ttec_atelka_delete_element   IS


/*
-- Program Name: ttec_atelka_delete_element
--
-- Description:  This program  removes element entries for Atelka employees
--
-- Called From:
--
-- Input/Output Parameters:
--
--
--
-- Tables Modified:  N/A
--
--
-- Created By:  Elango Pandurangan
-- Date:13-Feb-2018
--
-- Modification Log:
-- Developer        Date        Description
--  MXKEERTHI(ARGANO)  19-May-2023           1.0          R12.2 Upgrade Remediation
-- ----------       --------    --------------------------------------------------------------------


*/


  v_err VARCHAR2(200);


  v_effective_date      DATE := '27-JAN-2018';
  v_effective_start_date             DATE;
  v_effective_end_date               DATE;
  v_delete_warning                   BOOLEAN;

      CURSOR c1 IS
        SELECT  papf.employee_number,petf.element_name,peef.element_entry_id element_entry_id,peef.object_version_number object_version_number
        FROM  apps.per_all_people_f papf,
		    --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
             hr.per_all_assignments_f paaf,
              hr.pay_element_entries_f peef,
              hr.pay_element_types_f petf,
              hr.pay_input_values_f pivf,
             hr.pay_element_entry_values_f peevf
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
             apps.per_all_assignments_f paaf,
              apps.pay_element_entries_f peef,
              apps.pay_element_types_f petf,
              apps.pay_input_values_f pivf,
             apps.pay_element_entry_values_f peevf
	  --END R12.2.10 Upgrade remediation

 
        WHERE paaf.payroll_id = 782
        AND peef.element_type_id IN (882,15619,860,857,5806,5803,885)  -- Basic Life for 882 ,Child Optnl Life 15619,Dental for  860, Health Care for 857,Enhanced Dental for  5806,Enhanced Health for 5803,LTD for 885
        AND papf.person_id = paaf.person_id
        AND paaf.assignment_id = peef.assignment_id
        AND peef.element_type_id = petf.element_type_id
        AND petf.element_type_id = pivf.element_type_id
        AND peef.element_entry_id = peevf.element_entry_id
        AND pivf.input_value_id = peevf.input_value_id
        AND pivf.name IN ('Pay Value')
        AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
        AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
        AND SYSDATE BETWEEN peef.effective_start_date AND peef.effective_end_date
        AND SYSDATE BETWEEN petf.effective_start_date AND petf.effective_end_date
        AND SYSDATE BETWEEN pivf.effective_start_date AND pivf.effective_end_date
        AND SYSDATE BETWEEN peevf.effective_start_date AND peevf.effective_end_date
        AND peevf.screen_entry_value IS NOT NULL;
        --AND PAPF.EMPLOYEE_NUMBER = '1045177'; --'1044214';


   BEGIN

     FOR v1 in C1  LOOP


      BEGIN
      pay_element_entry_api.delete_element_entry
                         (p_validate                   => FALSE,
                          p_datetrack_delete_mode      => 'ZAP',
                          p_effective_date             => v_effective_date,
                          p_element_entry_id           => v1.element_entry_id,
                          p_object_version_number      => v1.object_version_number,
                          p_effective_start_date       => v_effective_start_date ,
                          p_effective_end_date         => v_effective_end_date ,
                          p_delete_warning             => v_delete_warning
                         );
       EXCEPTION
          WHEN OTHERS THEN
               v_err := SUBSTR(SQLERRM,1,100);

              INSERT INTO ttec_atelka_log A VALUES ('Failure for '||V1.EMPLOYEE_NUMBER||'Error is '||v_err);
       END;
          INSERT INTO ttec_atelka_log A VALUES ('Success  Emp# '||V1.EMPLOYEE_NUMBER||' Element Name '||v1.element_name);

      END LOOP;

   EXCEPTION
      WHEN OTHERS
      THEN
      INSERT INTO ttec_atelka_log A VALUES ('Failure in main level');
END ttec_atelka_delete_element;
/
show errors;
/