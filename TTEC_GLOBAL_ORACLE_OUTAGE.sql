create or replace PROCEDURE      TTEC_GLOBAL_ORACLE_OUTAGE(
      errcode            VARCHAR2,
      errbuff            VARCHAR2
)
/*== START ================================================================================================*\
Author: Diego Brus�s

Date: 14-NOV-12

Call From: TTEC_GLOBAL_ORACLE_OUTAGE

Desc: This procedure generates the Global Oracle Outage as an output file of the concurrent program.

Modification History:

Version    Date     Author      Description (Include Ticket#)
-------  --------  -----------  ------------------------------------------------------------------------------
   1.0  14-NOV-12  DRBRUSES     R#1834792  Alert - Global Oracle Outage
   1.1  12-JUN-13  DRBRUSES     R#2466771 Adding   "Fecha de Antiguedad" field
   1.2  19-JUN-13  DRBRUSES     I#2506009 Adding   Adding  Uniontown  site
   1.0  19-May-2023   MXKEERTHI(ARGANO)                  R12.2 Upgrade Remediation
\*== END ==================================================================================================*/



IS
    /** Declare local variables **/
      v_rec            VARCHAR2 (10000) := NULL;
      v_header         VARCHAR2 (1000) := NULL;
      v_error_step     VARCHAR2 (1000) := NULL;
      v_as_of_date     DATE := NULL;



 CURSOR c_outage
    IS
        SELECT   DISTINCT
        pbg.name Business_Group
       , papf.last_name Last_Name
       , papf.first_name First_Name
       , papf.employee_number Employee_Number
       , pj.name Job_Name
       , hla.location_code Site_Hr_Location
       , hl_asg_cat.meaning Assignment_Category
       , paaf.effective_start_date Assgmnt_Effective_Start_Date
       , papf_sup.full_name Supervisor_Name
       , papf_sup.employee_number Supervisor_Employee_Number
       , pcak.segment2 Client_Code
       , ffvv_cli_cost.description Client_Name
       , tepa.prj_cd Project_Code
       , tepa.project_desc Project_Description
       , tepa.prog_cd Program_Code
       , tepa.program_desc Program_Description
       , pp.phone_number Phone_Number
       , fnd_phones.meaning Phone_Type
       , CASE WHEN papf.business_group_id = 1633
              THEN t.meaning
              ELSE NULL END Old_Mexico_Detail_Cat
       , papf.middle_names Middle_Name
       , papf.sex Sex
       , papf.date_of_birth Date_Of_Birth
       , papf.email_address Email_Address
       , papf.original_date_of_hire Original_Date_Of_Hire
       , papf.town_of_birth Town_Of_Birth
       , papf.attribute1 Personal_Email
       , DECODE (papf.business_group_id, 1633, pa.address_line1 ||' '|| pa.address_line3 ||' '|| pa.address_line2, pa.address_line1 ||' '|| pa.address_line2 ||' '|| pa.address_line3) Address
       , pa.town_or_city Town_Or_City
       , pa.region_1 Region
       , pa.postal_code Postal_Code
       , DECODE(papf.business_group_id, 1633, (SELECT meaning
                                               FROM    hr_lookups
                                            WHERE   lookup_type     = 'PER_MX_STATE_CODES'
                                            AND     lookup_code     = pa.region_1

                                         ),
                fnd_state.meaning) State_Zone
       , DECODE(papf.business_group_id, 1633, paaf.ASS_ATTRIBUTE7, ' ') Shift_Type
       , paaf.ASS_ATTRIBUTE10 Fecha_Antiguedad    /* V 1.1 */
     --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
FROM     hr.per_all_people_f papf
       , apps.per_business_groups pbg
       , hr.per_all_assignments_f paaf
       , per_periods_of_service ppos
       , hr.hr_locations_all hla
       , hr.per_jobs pj
       , apps.hr_lookups hl_asg_cat
       , hr.per_all_people_f papf_sup
       , hr.per_all_assignments_f paaf_sup
       , hr.per_jobs pj_sup
       , hr.pay_cost_allocations_f pcaf
       , hr.pay_cost_allocation_keyflex pcak
       , apps.fnd_flex_values_vl ffvv_cli_cost
       , apps.fnd_flex_values_vl ffvv_loc_org
       , cust.ttec_emp_proj_asg tepa
       , hr.per_phones pp
       , apps.fnd_lookup_values fnd_phones
       , apps.fnd_lookup_values t
       , hr.per_addresses pa
       , apps.fnd_lookup_values fnd_state
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
FROM     apps.per_all_people_f papf
       , apps.per_business_groups pbg
       , apps.per_all_assignments_f paaf
       , per_periods_of_service ppos
       , apps.hr_locations_all hla
       , apps.per_jobs pj
       , apps.hr_lookups hl_asg_cat
       , apps.per_all_people_f papf_sup
       , apps.per_all_assignments_f paaf_sup
       , apps.per_jobs pj_sup
       , apps.pay_cost_allocations_f pcaf
       , apps.pay_cost_allocation_keyflex pcak
       , apps.fnd_flex_values_vl ffvv_cli_cost
       , apps.fnd_flex_values_vl ffvv_loc_org
       , apps.ttec_emp_proj_asg tepa
       , apps.per_phones pp
       , apps.fnd_lookup_values fnd_phones
       , apps.fnd_lookup_values t
       , apps.per_addresses pa
       , apps.fnd_lookup_values fnd_state
	  --END R12.2.10 Upgrade remediation
	   

WHERE    papf.business_group_id <> 0
     /* Active employees as of certain date */
     AND TRUNC(SYSDATE) BETWEEN papf.effective_start_date
                           AND  papf.effective_end_date
     AND papf.current_employee_flag = 'Y' /* Active employees */
     AND pbg.business_group_id = papf.business_group_id
     /* Assignment */
     AND paaf.person_id = papf.person_id
     AND paaf.assignment_type = 'E' /* Assignment Type: Employee */
     AND paaf.primary_flag = 'Y' /* Primary Assignment in case there are more than one */
     AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date
                           AND  paaf.effective_end_date
     /* Period of Service */
     AND ppos.person_id = papf.person_id
     AND ppos.period_of_service_id = paaf.period_of_service_id
     /* HR Location / Site and Country */
     AND hla.location_id(+) = paaf.location_id
     /* Job */
     AND pj.job_id(+) = paaf.job_id
     /* Assignment Category */
     AND hl_asg_cat.lookup_code(+) = paaf.employment_category
     AND hl_asg_cat.lookup_type(+) = 'EMP_CAT'
     /* Supervisor */
     AND papf_sup.person_id(+) = paaf.supervisor_id
     AND TRUNC(SYSDATE) BETWEEN papf_sup.effective_start_date(+)
                           AND  papf_sup.effective_end_date(+)
     AND paaf_sup.person_id(+) = papf_sup.person_id
     AND TRUNC(SYSDATE) BETWEEN paaf_sup.effective_start_date(+)
                           AND  paaf_sup.effective_end_date(+)
     AND pj_sup.job_id(+) = paaf_sup.job_id
     /* Costing (Location.Client.Department in Assignment Form)*/
     AND pcaf.assignment_id(+) = paaf.assignment_id
     AND TRUNC(SYSDATE) BETWEEN pcaf.effective_start_date(+)
                           AND  pcaf.effective_end_date(+)
     AND pcak.cost_allocation_keyflex_id(+) = pcaf.cost_allocation_keyflex_id
     AND ffvv_cli_cost.flex_value(+) = pcak.segment2
     AND ffvv_cli_cost.flex_value_set_id(+) = '1002611'
     /* Default Location Description */
     AND ffvv_loc_org.flex_value(+) = hla.attribute2
     AND ffvv_loc_org.flex_value_set_id(+) = '1002610'
     /* Project Assignment (Custom Table) */
     AND tepa.person_id(+) = papf.person_id
     AND TRUNC(SYSDATE) BETWEEN tepa.prj_strt_dt(+) AND tepa.prj_end_dt(+)
     AND PP.PARENT_TABLE(+) = 'PER_ALL_PEOPLE_F'
     AND PP.PARENT_ID(+) = PAPF.PERSON_ID
     AND fnd_phones.lookup_type(+) = 'PHONE_TYPE'
     AND fnd_phones.lookup_code(+) = pp.phone_type
     AND fnd_phones.language(+) = USERENV ('LANG')
     AND fnd_phones.enabled_flag(+) = 'Y'
     AND fnd_phones.security_group_id(+) = 2
     AND paaf.ass_attribute15 = t.lookup_code(+)
     AND t.lookup_type(+) = 'EMP_CAT'
     AND t.language(+) = 'ESA'
     AND t.security_group_id(+) = '25'
     AND hla.location_code IN ('USA-Morgantown',
                               'USA-Kalispell',
                               'MEX-Guadalajara (CA) 03110',
                               'MEX-Guadalajara 03115',
                               'PHL - BRANCH - Quezon',
                               'PHL-Quezon',
                               'USA-Englewood (TTEC)',
                               'USA-Uniontown') /* V 1.2 */
     AND pa.person_id(+) = papf.person_id
     AND pa.primary_flag(+) = 'Y'
     AND fnd_state.lookup_code(+) = pa.region_2
     AND (TRUNC(SYSDATE) BETWEEN pa.DATE_FROM AND  pa.DATE_TO OR pa.DATE_TO is null)
     AND fnd_state.LANGUAGE(+) = USERENV ('LANG')
     AND fnd_state.lookup_type(+) = 'IGF_AP_STATE_CODES'
     AND fnd_state.enabled_flag(+) = 'Y';

BEGIN

      v_error_step   := 'Step 1: Create header';

      v_as_of_date := TO_CHAR (TRUNC(SYSDATE), 'DD-MON-YYYY');

      /** Log header **/
      apps.fnd_file.put_line (fnd_file.log,'TeleTech HR Report Name: TTEC Global Oracle Outage - As of: ' || v_as_of_date);

      /** Create header for the output **/

      v_header       :=
            'As Of Date'
         || '|'
         || 'Business Group'
         || '|'
         || 'Last Name'
         || '|'
         || 'First Name'
         || '|'
         || 'Employee Number'
         || '|'
         || 'Job Name'
         || '|'
         || 'Site / Hr Location'
         || '|'
         || 'Assignment Category'
         || '|'
         || 'Assgmnt - Effective Start Date'
         || '|'
         || 'Supervisor Name'
         || '|'
         || 'Supervisor Employee Number'
         || '|'
         || 'Client Code'
         || '|'
         || 'Client Name'
         || '|'
         || 'Project Code'
         || '|'
         || 'Program Description'
         || '|'
         || 'Program Code'
         || '|'
         || 'Project Description'
         || '|'
         || 'Phone Number'
         || '|'
         || 'Phone Type'
         || '|'
         || 'Old Mexico Detail Cat'
         || '|'
         || 'Middle Name'
         || '|'
         || 'Sex'
         || '|'
         || 'Date Of Birth'
         || '|'
         || 'Email Address'
         || '|'
         || 'Original Date Of Hire'
         || '|'
         || 'Town Of Birth'
         || '|'
         || 'Personal Email'
         || '|'
         || 'Address'
         || '|'
         || 'Town Or City'
         || '|'
         || 'Region'
         || '|'
         || 'Postal Code'
         || '|'
         || 'State / Zone'
         || '|'
         || 'Shift Type'
         || '|'
         || 'Fecha de Antiguedad';

      apps.fnd_file.put_line (fnd_file.output, v_header);


      v_error_step   := 'Step 2: End create header, entering Loop';

      /** Loop Records **/
      FOR r_emp IN c_outage LOOP

         v_error_step   := 'Step 3: Inside Loop';

         v_rec :=   v_as_of_date
                 || '|'
                 || r_emp.Business_Group
                 || '|'
                 || r_emp.Last_Name
                 || '|'
                 || r_emp.First_Name
                 || '|'
                 || r_emp.Employee_Number
                 || '|'
                 || r_emp.Job_Name
                 || '|'
                 || r_emp.Site_Hr_Location
                 || '|'
                 || r_emp.Assignment_Category
                 || '|'
                 || r_emp.Assgmnt_Effective_Start_Date
                 || '|'
                 || r_emp.Supervisor_Name
                 || '|'
                 || r_emp.Supervisor_Employee_Number
                 || '|'
                 || r_emp.Client_Code
                 || '|'
                 || r_emp.Client_Name
                 || '|'
                 || r_emp.Project_Code
                 || '|'
                 || r_emp.Program_Description
                 || '|'
                 || r_emp.Program_Code
                 || '|'
                 || r_emp.Project_Description
                 || '|'
                 || r_emp.Phone_Number
                 || '|'
                 || r_emp.Phone_Type
                 || '|'
                 || r_emp.Old_Mexico_Detail_Cat
                 || '|'
                 || r_emp.Middle_Name
                 || '|'
                 || r_emp.Sex
                 || '|'
                 || r_emp.Date_Of_Birth
                 || '|'
                 || r_emp.Email_Address
                 || '|'
                 || r_emp.Original_Date_Of_Hire
                 || '|'
                 || r_emp.Town_Of_Birth
                 || '|'
                 || r_emp.Personal_Email
                 || '|'
                 || r_emp.Address
                 || '|'
                 || r_emp.Town_Or_City
                 || '|'
                 || r_emp.Region
                 || '|'
                 || r_emp.Postal_Code
                 || '|'
                 || r_emp.State_Zone
                 || '|'
                 || r_emp.Shift_Type
                 || '|'
                 || r_emp.Fecha_Antiguedad;

         apps.fnd_file.put_line (fnd_file.output, v_rec);
      END LOOP;

EXCEPTION

    WHEN OTHERS
      THEN
         fnd_file.put_line (fnd_file.LOG, 'Operation fails on ' || v_error_step);

    END TTEC_GLOBAL_ORACLE_OUTAGE;
    /
    show errors;
    /