create or replace PROCEDURE tt_hierarchy_report ( /************************************************************************************
        Program Name: TTEC_PO_TSG_INTERFACE 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
   MXKEERTHI(ARGANO)  19-May-2023           1.0          R12.2 Upgrade Remediation
    ****************************************************************************************/

ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER,
p_mgr_person_id IN NUMBER) IS

CURSOR c_hier (p_person_id IN NUMBER) IS
(SELECT ROWNUM ||'|'||
	   LPAD(LEVEL||' - '||tehv.full_name,LENGTH(tehv.full_name) + (LEVEL * 2) + 5,'_')  ||'|'||
	   tehv.full_name  ||'|'||
	   haou.NAME  ||'|'||
       ppos.date_start ||'|'||
	   ffv_dep.description ||'|'||
	   hla.location_code  ||'|'||
	   ffv_loc.description  ||'|'||
	   sup.full_name  ||'|'||
	   pj.NAME  full_record
FROM apps.TTEC_EMP_HIERARCHY_V tehv
 --INNER JOIN hr.per_periods_of_service ppos ON  ppos.person_id = tehv.person_id  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
INNER JOIN apps.per_periods_of_service ppos ON  ppos.person_id = tehv.person_id  --code added by MXKEERTHI-ARGANO, 05/19/2023
      AND (ppos.actual_termination_date IS NULL OR ppos.actual_termination_date > SYSDATE)
	   --INNER JOIN hr.per_all_assignments_f paaf ON paaf.person_id = tehv.person_id --Commented code by MXKEERTHI-ARGANO, 05/19/2023
INNER JOIN apps.per_all_assignments_f paaf ON paaf.person_id = tehv.person_id --code added by MXKEERTHI-ARGANO, 05/19/2023
     AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
	  --INNER JOIN hr.hr_locations_all hla ON  hla.location_id = paaf.location_id  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
INNER JOIN apps.hr_locations_all hla ON  hla.location_id = paaf.location_id  --code added by MXKEERTHI-ARGANO, 05/19/2023

 --LEFT OUTER JOIN hr.per_all_people_f sup ON sup.person_id = paaf.supervisor_id --Commented code by MXKEERTHI-ARGANO, 05/19/2023
LEFT OUTER JOIN apps.per_all_people_f sup ON sup.person_id = paaf.supervisor_id --code added by MXKEERTHI-ARGANO, 05/19/2023
     AND sup.current_employee_flag = 'Y'
      AND sup.business_group_id <> 0
      AND TRUNC(SYSDATE) BETWEEN sup.EFFECTIVE_start_DATE AND sup.EFFECTIVE_END_DATe
    --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
 INNER JOIN hr.hr_all_organization_units haou ON haou.organization_id = paaf.organization_id
LEFT JOIN hr.pay_cost_allocations_f pcaf ON pcaf.assignment_id = paaf.assignment_id
     AND TRUNC(SYSDATE) BETWEEN pcaf.effective_start_date AND pcaf.effective_end_date
LEFT JOIN hr.pay_cost_allocation_keyflex pcak ON pcak.COST_ALLOCATION_KEYFLEX_ID = pcaf.COST_ALLOCATION_KEYFLEX_ID
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
INNER JOIN apps.hr_all_organization_units haou ON haou.organization_id = paaf.organization_id
LEFT JOIN apps.pay_cost_allocations_f pcaf ON pcaf.assignment_id = paaf.assignment_id
     AND TRUNC(SYSDATE) BETWEEN pcaf.effective_start_date AND pcaf.effective_end_date
LEFT JOIN apps.pay_cost_allocation_keyflex pcak ON pcak.COST_ALLOCATION_KEYFLEX_ID = pcaf.COST_ALLOCATION_KEYFLEX_ID
	  --END R12.2.10 Upgrade remediation
	  

LEFT JOIN apps.FND_FLEX_VALUES_VL ffv_loc ON ffv_loc.flex_value = pcak.segment1
     AND ffv_loc.flex_value_set_id = '1002610'
LEFT JOIN apps.FND_FLEX_VALUES_VL ffv_dep ON ffv_dep.flex_value = pcak.segment3
     AND ffv_dep.flex_value_set_id = '1002612'
	  --INNER JOIN hr.per_jobs pj ON  pj.job_id = paaf.job_id  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
INNER JOIN apps.per_jobs pj ON  pj.job_id = paaf.job_id --code added by MXKEERTHI-ARGANO, 05/19/2023

--WHERE tehv.business_group_id IN (325,326)
START WITH --tehv.full_name = 'Tuchman, Kenneth'
tehv.person_id = p_person_id
CONNECT BY PRIOR emp = mgr  );



BEGIN

Fnd_File.put_line(2, 'Chart seq'||'|'||
	   'Orgchart' ||'|'||
	   'Employee Name' ||'|'||
	   'Current Organization' ||'|'||
       'Hire Date' ||'|'||
	   'Derived Department' ||'|'||
	   'Current Location' ||'|'||
	   'Derived Location' ||'|'||
	   'Supervisor' ||'|'||
	   'Job');

FOR r_hier IN c_hier (p_mgr_person_id) LOOP
    Fnd_File.put_line(2,r_hier.full_record);
END LOOP;

END;
/
show errors;
/