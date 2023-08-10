create or replace PROCEDURE      tt_costing_int (
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

   errbuf                   OUT      VARCHAR2,
   retcode                  OUT      NUMBER,
   p_dummy                  IN       VARCHAR2,
   p_payroll_id             IN       NUMBER,
   p_consolidation_set_id   IN       NUMBER,
   p_date_from              IN       DATE,
   p_date_to                IN       DATE
)
IS
/* $Header: Tt_Costing_Int.prc 1.0 2008/08/01 BShanks $ */
/*== START ================================================================================================*\
  Author:  Bob Shanks
    Date:  August 01, 2008
    Desc:  This Procdure is used to customize the costing accounts before
           transfering to GL for all business groups.
  Modification History:

 Mod#  Person         Date     Comments
---------------------------------------------------------------------------
 1.0  Bob Shank     01-AUG-08 Customized for Philipines
 1.1  Kaushik Babu  02-DEC-08 Customizing code changes for PHL accounts as per WO 533490
                              the amounts are going to wrong accounts when Custom costing is run
                              Fixed the code to make the amount goes to correct account for Philipines 1517.
 1.2  Kaushik Babu  21-DEC-09  Fixed code to accommodate accounts for new set of books, Government Solutions - 43968
 1.3  Kaushik Babu  28-DEC-09 Fixed/Commented part of code, not to change agent training time/cost from D005 to D030
                              (inside account A5025) for US Operations  - TT 52578
 1.4  Elango Pandu  18-FEB-2010  Need to modify custom costing to set the accounts to 7XXX when the client is 5901 for PERCEPTA payroll
                                 request 91233.
 1.5  Christiane C. 28-APR-2010  For PERCEPTA payroll - Only the 5xxx expense accounts needed to be changed to 7xxx.
                                 Adding the above to the existing logic. (TTECH I#152462)
\*== END ==================================================================================================*/

   -- Variables used by Common Error Procedure
       --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
  c_application_code               cust.ttec_error_handling.application_code%TYPE
                                                                      := 'HR';
   c_interface                      cust.ttec_error_handling.INTERFACE%TYPE
                                                              := 'HR-CUST-01';
   c_program_name                   cust.ttec_error_handling.program_name%TYPE
                                                     := 'custom_payroll_cost';
   c_initial_status                 cust.ttec_error_handling.status%TYPE
                                                                 := 'INITIAL';
   c_warning_status                 cust.ttec_error_handling.status%TYPE
                                                                 := 'WARNING';
   c_failure_status                 cust.ttec_error_handling.status%TYPE
                                                                 := 'FAILURE';
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
  c_application_code               apps.ttec_error_handling.application_code%TYPE
                                                                      := 'HR';
   c_interface                      apps.ttec_error_handling.INTERFACE%TYPE
                                                              := 'HR-CUST-01';
   c_program_name                   apps.ttec_error_handling.program_name%TYPE
                                                     := 'custom_payroll_cost';
   c_initial_status                 apps.ttec_error_handling.status%TYPE
                                                                 := 'INITIAL';
   c_warning_status                 apps.ttec_error_handling.status%TYPE
                                                                 := 'WARNING';
   c_failure_status                 apps.ttec_error_handling.status%TYPE
                                                                 := 'FAILURE';
	  --END R12.2.10 Upgrade remediation

 
   skip_record                      EXCEPTION;
   g_payroll                        NUMBER                    := p_payroll_id;
   g_consolidation_set              NUMBER          := p_consolidation_set_id;
   g_start_date                     DATE                       := p_date_from;
   g_end_date                       DATE                         := p_date_to;
       --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023

   v_cost_allocation_keyflex_id     hr.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
                                                                      := NULL;
   v_new_allocation_keyflex_id      hr.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
                                                                      := NULL;
   v_offset_allocation_keyflex_id   hr.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
                                                                      := NULL;
   v_person_id                      hr.per_all_people_f.person_id%TYPE
                                                                      := NULL;
   v_assignment_id                  hr.per_all_assignments_f.assignment_id%TYPE
                                                                      := NULL;
   v_employee_number                hr.per_all_people_f.employee_number%TYPE
                                                                      := NULL;
   v_business_group                 hr.per_all_assignments_f.business_group_id%TYPE
                                                                      := NULL;
   v_cost_id                        hr.pay_costs.cost_id%TYPE         := NULL;
   v_cost_location                  hr.pay_cost_allocation_keyflex.segment1%TYPE
                                                                      := NULL;
   v_cost_client                    hr.pay_cost_allocation_keyflex.segment2%TYPE
                                                                      := NULL;
   v_cost_department                hr.pay_cost_allocation_keyflex.segment3%TYPE
                                                                      := NULL;
   v_cost_account                   hr.pay_cost_allocation_keyflex.segment4%TYPE
                                                                      := NULL;
   v_job_account                    hr.pay_cost_allocation_keyflex.segment4%TYPE
                                                                      := NULL;
   v_cost_future1                   hr.pay_cost_allocation_keyflex.segment5%TYPE
                                                                      := NULL;
   v_cost_future2                   hr.pay_cost_allocation_keyflex.segment6%TYPE
                                                                      := NULL;
   v_cost_id_flex_num               hr.pay_cost_allocation_keyflex.id_flex_num%TYPE
                                                                      := NULL;
   v_cost_summary_flag              hr.pay_cost_allocation_keyflex.summary_flag%TYPE
                                                                      := NULL;
   v_cost_enabled_flag              hr.pay_cost_allocation_keyflex.enabled_flag%TYPE
                                                                      := NULL;
   v_cost_run_result_id             NUMBER;
   v_cost_dist_run_result_id        NUMBER;
   v_element_name                   hr.pay_element_types_f.element_name%TYPE;
   v_bal_location                   hr.pay_cost_allocation_keyflex.segment1%TYPE
                                                                      := NULL;
   v_bal_client                     hr.pay_cost_allocation_keyflex.segment2%TYPE
                                                                      := NULL;
   v_bal_department                 hr.pay_cost_allocation_keyflex.segment3%TYPE
                                                                      := NULL;
   v_bal_account                    hr.pay_cost_allocation_keyflex.segment4%TYPE
                                                                      := NULL;
   v_bal_future1                    hr.pay_cost_allocation_keyflex.segment5%TYPE
                                                                      := NULL;
   v_bal_future2                    hr.pay_cost_allocation_keyflex.segment6%TYPE
                                                                      := NULL;
   v_bal_id_flex_num                hr.pay_cost_allocation_keyflex.id_flex_num%TYPE
                                                                      := NULL;
   v_bal_summary_flag               hr.pay_cost_allocation_keyflex.summary_flag%TYPE
                                                                      := NULL;
   v_bal_enabled_flag               hr.pay_cost_allocation_keyflex.enabled_flag%TYPE
                                                                      := NULL;
   v_bal_run_result_id              NUMBER;
   v_bal_dist_run_result_id         NUMBER;
   v_pre_payment_id                 hr.pay_assignment_actions.pre_payment_id%TYPE
                                                                      := NULL;
   v_assignment_action_id           hr.pay_assignment_actions.assignment_action_id%TYPE
                                                                      := NULL;
   v_payment_method_name            hr.pay_org_payment_methods_f.org_payment_method_name%TYPE
                                                                      := NULL;
   v_counter                        NUMBER                               := 0;
   v_insert                         NUMBER                               := 0;
   v_location_dff                   hr.pay_cost_allocation_keyflex.segment1%TYPE
                                                                      := NULL;

	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023

   v_cost_allocation_keyflex_id     apps.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
                                                                      := NULL;
   v_new_allocation_keyflex_id      apps.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
                                                                      := NULL;
   v_offset_allocation_keyflex_id   apps.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
                                                                      := NULL;
   v_person_id                      apps.per_all_people_f.person_id%TYPE
                                                                      := NULL;
   v_assignment_id                  apps.per_all_assignments_f.assignment_id%TYPE
                                                                      := NULL;
   v_employee_number                apps.per_all_people_f.employee_number%TYPE
                                                                      := NULL;
   v_business_group                 apps.per_all_assignments_f.business_group_id%TYPE
                                                                      := NULL;
   v_cost_id                        apps.pay_costs.cost_id%TYPE         := NULL;
   v_cost_location                  apps.pay_cost_allocation_keyflex.segment1%TYPE
                                                                      := NULL;
   v_cost_client                    apps.pay_cost_allocation_keyflex.segment2%TYPE
                                                                      := NULL;
   v_cost_department                apps.pay_cost_allocation_keyflex.segment3%TYPE
                                                                      := NULL;
   v_cost_account                   apps.pay_cost_allocation_keyflex.segment4%TYPE
                                                                      := NULL;
   v_job_account                    apps.pay_cost_allocation_keyflex.segment4%TYPE
                                                                      := NULL;
   v_cost_future1                   apps.pay_cost_allocation_keyflex.segment5%TYPE
                                                                      := NULL;
   v_cost_future2                   apps.pay_cost_allocation_keyflex.segment6%TYPE
                                                                      := NULL;
   v_cost_id_flex_num               apps.pay_cost_allocation_keyflex.id_flex_num%TYPE
                                                                      := NULL;
   v_cost_summary_flag              apps.pay_cost_allocation_keyflex.summary_flag%TYPE
                                                                      := NULL;
   v_cost_enabled_flag              apps.pay_cost_allocation_keyflex.enabled_flag%TYPE
                                                                      := NULL;
   v_cost_run_result_id             NUMBER;
   v_cost_dist_run_result_id        NUMBER;
   v_element_name                   apps.pay_element_types_f.element_name%TYPE;
   v_bal_location                   apps.pay_cost_allocation_keyflex.segment1%TYPE
                                                                      := NULL;
   v_bal_client                     apps.pay_cost_allocation_keyflex.segment2%TYPE
                                                                      := NULL;
   v_bal_department                 apps.pay_cost_allocation_keyflex.segment3%TYPE
                                                                      := NULL;
   v_bal_account                    apps.pay_cost_allocation_keyflex.segment4%TYPE
                                                                      := NULL;
   v_bal_future1                    apps.pay_cost_allocation_keyflex.segment5%TYPE
                                                                      := NULL;
   v_bal_future2                    apps.pay_cost_allocation_keyflex.segment6%TYPE
                                                                      := NULL;
   v_bal_id_flex_num                apps.pay_cost_allocation_keyflex.id_flex_num%TYPE
                                                                      := NULL;
   v_bal_summary_flag               apps.pay_cost_allocation_keyflex.summary_flag%TYPE
                                                                      := NULL;
   v_bal_enabled_flag               apps.pay_cost_allocation_keyflex.enabled_flag%TYPE
                                                                      := NULL;
   v_bal_run_result_id              NUMBER;
   v_bal_dist_run_result_id         NUMBER;
   v_pre_payment_id                 apps.pay_assignment_actions.pre_payment_id%TYPE
                                                                      := NULL;
   v_assignment_action_id           apps.pay_assignment_actions.assignment_action_id%TYPE
                                                                      := NULL;
   v_payment_method_name            apps.pay_org_payment_methods_f.org_payment_method_name%TYPE
                                                                      := NULL;
   v_counter                        NUMBER                               := 0;
   v_insert                         NUMBER                               := 0;
   v_location_dff                   apps.pay_cost_allocation_keyflex.segment1%TYPE
                                                                      := NULL;

	  --END R12.2.10 Upgrade remediation

   -- RECORD DECLARATION --
       --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
   TYPE keyflex_record IS RECORD (
      cost_allocation_keyflex_id   hr.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      concatenated_segments        hr.pay_cost_allocation_keyflex.concatenated_segments%TYPE,
      id_flex_num                  hr.pay_cost_allocation_keyflex.id_flex_num%TYPE,
      summary_flag                 hr.pay_cost_allocation_keyflex.summary_flag%TYPE,
      enabled_flag                 hr.pay_cost_allocation_keyflex.enabled_flag%TYPE,
      segment1                     hr.pay_cost_allocation_keyflex.segment1%TYPE,
      segment2                     hr.pay_cost_allocation_keyflex.segment2%TYPE,
      segment3                     hr.pay_cost_allocation_keyflex.segment3%TYPE,
      segment4                     hr.pay_cost_allocation_keyflex.segment4%TYPE,
      segment5                     hr.pay_cost_allocation_keyflex.segment5%TYPE,
      segment6                     hr.pay_cost_allocation_keyflex.segment6%TYPE
   );
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
   TYPE keyflex_record IS RECORD (
      cost_allocation_keyflex_id   apps.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      concatenated_segments        apps.pay_cost_allocation_keyflex.concatenated_segments%TYPE,
      id_flex_num                  apps.pay_cost_allocation_keyflex.id_flex_num%TYPE,
      summary_flag                 apps.pay_cost_allocation_keyflex.summary_flag%TYPE,
      enabled_flag                 apps.pay_cost_allocation_keyflex.enabled_flag%TYPE,
      segment1                     apps.pay_cost_allocation_keyflex.segment1%TYPE,
      segment2                     apps.pay_cost_allocation_keyflex.segment2%TYPE,
      segment3                     apps.pay_cost_allocation_keyflex.segment3%TYPE,
      segment4                     apps.pay_cost_allocation_keyflex.segment4%TYPE,
      segment5                     apps.pay_cost_allocation_keyflex.segment5%TYPE,
      segment6                     apps.pay_cost_allocation_keyflex.segment6%TYPE
   );
	  --END R12.2.10 Upgrade remediation



   -- variable added for PHL customization. BShanks, 23-Jun-2008
   v_job                            VARCHAR2 (100);
   v_keyflex_record                 keyflex_record;
       --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
   l_module_name                    cust.ttec_error_handling.module_name%TYPE
                                                                     := 'MAIN';
   l_label1                         cust.ttec_error_handling.label1%TYPE
                                                                     := 'MAIN';
   l_error_message                  cust.ttec_error_handling.error_message%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
  l_module_name                    apps.ttec_error_handling.module_name%TYPE
                                                                     := 'MAIN';
   l_label1                         apps.ttec_error_handling.label1%TYPE
                                                                     := 'MAIN';
   l_error_message                  apps.ttec_error_handling.error_message%TYPE;
	  --END R12.2.10 Upgrade remediation

 

-----------------------------------------------------------------------------------------------------------------------
  -- CURSOR NAME          : GET_COST_LEVEL
  -- INCOMING PARAMETERS  : v_start_date, v_end_date, v_consolidation_set, v_payroll
  -- OUTGOING PARAMETERS  : None
  -- EXCEPTIONS           : None
  -- DESCRIPTION          : This cursor is used to retrieve the cost level rows from the HR.PAY_COST_ALLOCATION_KEYFLEX table
   CURSOR get_cost_level
   IS
      SELECT pc.cost_allocation_keyflex_id, ppa.business_group_id,
             paa.assignment_id, pc.cost_id, pcak.segment1, pcak.segment2,
             pcak.segment3, pcak.segment4, pcak.segment5, pcak.segment6,
             pcak.id_flex_num, pcak.summary_flag, pcak.enabled_flag,
             pc.run_result_id, pc.distributed_run_result_id
			     --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
         FROM hr.pay_cost_allocation_keyflex pcak,
             hr.pay_costs pc,
             hr.pay_assignment_actions paa,
             hr.pay_payroll_actions ppa
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
        FROM apps.pay_cost_allocation_keyflex pcak,
             apps.pay_costs pc,
             apps.pay_assignment_actions paa,
             apps.pay_payroll_actions ppa
	  --END R12.2.10 Upgrade remediation


       WHERE pc.assignment_action_id = paa.assignment_action_id
         AND pcak.cost_allocation_keyflex_id = pc.cost_allocation_keyflex_id
         AND ppa.payroll_action_id = paa.payroll_action_id
         AND ppa.effective_date BETWEEN g_start_date AND g_end_date
         AND ppa.action_type = 'C'
         AND UPPER (pc.balance_or_cost) = 'C'
         AND ppa.consolidation_set_id = g_consolidation_set
         AND ppa.payroll_id = g_payroll;

-----------------------------------------------------------------------------------------------------------------------
  -- CURSOR NAME          : GET_OFFSET_LEVEL
  -- INCOMING PARAMETERS  : v_start_date, v_end_date, v_consolidation_set, v_payroll
  -- OUTGOING PARAMETERS  : None
  -- EXCEPTIONS           : None
  -- DESCRIPTION          : This cursor is used to retrieve the offset level rows from the HR.PAY_COST_ALLOCATION_KEYFLEX table
   CURSOR get_offset_level
   IS
      SELECT pc.cost_allocation_keyflex_id, ppa.business_group_id,
             paa.assignment_id, pcak.segment1, pcak.segment2, pcak.segment3,
             pcak.segment4, pcak.segment5, pcak.segment6, pcak.id_flex_num,
             pcak.summary_flag, pcak.enabled_flag, pc.cost_id,
             paa.pre_payment_id, paa.assignment_action_id, pc.run_result_id,
             pc.distributed_run_result_id
			     --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
         FROM hr.pay_cost_allocation_keyflex pcak,
             hr.pay_costs pc,
             hr.pay_assignment_actions paa,
             hr.pay_payroll_actions ppa
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
        FROM apps.pay_cost_allocation_keyflex pcak,
             apps.pay_costs pc,
             apps.pay_assignment_actions paa,
             apps.pay_payroll_actions ppa
	  --END R12.2.10 Upgrade remediation


       WHERE pc.assignment_action_id = paa.assignment_action_id
         AND pcak.cost_allocation_keyflex_id = pc.cost_allocation_keyflex_id
         AND ppa.payroll_action_id = paa.payroll_action_id
         AND ppa.effective_date BETWEEN g_start_date AND g_end_date
         AND ppa.action_type = 'C'
         AND UPPER (pc.balance_or_cost) = 'B'
         AND ppa.consolidation_set_id = g_consolidation_set
         AND ppa.payroll_id = g_payroll;

-----------------------------------------------------------------------------------------------------------------------
  -- PROCEDURE NAME       : GET_LOCATION_DFF
  -- INCOMING PARAMETERS  : v_person_id, v_end_date
  -- OUTGOING PARAMETERS  : v_sec_code_jobs
  -- EXCEPTIONS           : NO_DATE_FOUND, OTHERS
  -- DESCRIPTION          : This procedure retrieves the segment1 value from the location_dff for a specific employee.
   PROCEDURE get_location_dff (
       --l_assignment_id   IN       hr.per_all_assignments_f.assignment_id%TYPE,  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
      l_assignment_id   IN       apps.per_all_assignments_f.assignment_id%TYPE,  --code added by MXKEERTHI-ARGANO, 05/19/2023
     l_end_date        IN       DATE,
      l_location_dff    OUT      hr_locations.attribute2%TYPE
   )
   IS
       --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
      l_module_name     cust.ttec_error_handling.module_name%TYPE
                                                        := 'GET_LOCATION_DFF';
      l_label1          cust.ttec_error_handling.label1%TYPE
                                                         := 'v_assignment_id';
      l_error_message   cust.ttec_error_handling.error_message%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
      l_module_name     apps.ttec_error_handling.module_name%TYPE
                                                        := 'GET_LOCATION_DFF';
      l_label1          Apps.ttec_error_handling.label1%TYPE
                                                         := 'v_assignment_id';
      l_error_message   apps.ttec_error_handling.error_message%TYPE;
	  --END R12.2.10 Upgrade remediation


   BEGIN
      --
      SELECT hl.attribute2
        INTO l_location_dff
		 -- FROM hr.per_all_assignments_f paaf, hr_locations hl --Commented code by MXKEERTHI-ARGANO, 05/19/2023
        FROM apps.per_all_assignments_f paaf, hr_locations hl --code added by MXKEERTHI-ARGANO, 05/19/2023


       WHERE TRUNC (l_end_date) BETWEEN TRUNC (paaf.effective_start_date)
                                    AND TRUNC (paaf.effective_end_date)
         AND paaf.location_id = hl.location_id
         AND paaf.assignment_id = l_assignment_id;
   --
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_location_dff := NULL;
      WHEN OTHERS
      THEN
	   -- cust.ttec_process_error (c_application_code, --Commented code by MXKEERTHI-ARGANO, 05/19/2023
         apps.ttec_process_error (c_application_code, --code added by MXKEERTHI-ARGANO, 05/19/2023
                                 c_interface,
                                  c_program_name,
                                  l_module_name,
                                  c_failure_status,
                                  SQLCODE,
                                  SQLERRM,
                                  l_label1,
                                  l_label1
                                 );
         RAISE;
   --
   END;                                          -- PROCEDURE GET_LOCATION_DFF

-----------------------------------------------------------------------------------------------------------------------
  -- PROCEDURE NAME       : GET_ELEMENT
  -- INCOMING PARAMETERS  : distributed_run_result_id, run_result_id
  -- OUTGOING PARAMETERS  : Element
  -- EXCEPTIONS           : NO_DATE_FOUND, OTHERS
  -- DESCRIPTION          : This procedure retrieves element for the assignment
   PROCEDURE get_element (
      p_run_result_id               IN       NUMBER,
      p_distributed_run_result_id   IN       NUMBER,
      p_element_name                OUT      VARCHAR2
   )
        --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
    IS
      l_module_name   cust.ttec_error_handling.module_name%TYPE;
      l_label1        cust.ttec_error_handling.label1%TYPE;
      l_reference1    cust.ttec_error_handling.reference1%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
   IS
      l_module_name   apps.ttec_error_handling.module_name%TYPE;
      l_label1        apps.ttec_error_handling.label1%TYPE;
      l_reference1    apps.ttec_error_handling.reference1%TYPE;
	  --END R12.2.10 Upgrade remediation


   BEGIN
      --
      IF p_distributed_run_result_id IS NOT NULL
      THEN
         --
         SELECT et.element_name
           INTO p_element_name
		    --FROM hr.pay_run_results rr, apps.pay_element_types_f et--Commented code by MXKEERTHI-ARGANO, 05/19/2023
          FROM apps.pay_run_results rr, apps.pay_element_types_f et  --code added by MXKEERTHI-ARGANO, 05/19/2023
         WHERE TRUNC (SYSDATE) BETWEEN et.effective_start_date
                                    AND et.effective_end_date
            AND rr.run_result_id = p_distributed_run_result_id
            AND rr.element_type_id = et.element_type_id;
      --
      ELSE
         --
         SELECT et.element_name
           INTO p_element_name
		    --FROM hr.pay_run_results rr, apps.pay_element_types_f et   --Commented code by MXKEERTHI-ARGANO, 05/19/2023
           FROM apps.pay_run_results rr, apps.pay_element_types_f et --code added by MXKEERTHI-ARGANO, 05/19/2023
          WHERE TRUNC (SYSDATE) BETWEEN et.effective_start_date
                                    AND et.effective_end_date
            AND rr.run_result_id = p_run_result_id
            AND rr.element_type_id = et.element_type_id;
      --
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_module_name := 'GET ELEMENT';
         l_label1 := 'run_result_id';
         l_reference1 := NVL (p_distributed_run_result_id, p_run_result_id);
		  --cust.ttec_process_error (c_application_code,--Commented code by MXKEERTHI-ARGANO, 05/19/2023
         apps.ttec_process_error (c_application_code, --code added by MXKEERTHI-ARGANO, 05/19/2023
                                 c_interface,
                                  c_program_name,
                                  l_module_name,
                                  c_failure_status,
                                  SQLCODE,
                                  SQLERRM,
                                  l_label1,
                                  l_reference1
                                 );
       --RAISE;
   --
   END;                                               -- PROCEDURE GET_ELEMENT

-----------------------------------------------------------------------------------------------------------------------
  -- PROCEDURE NAME       : GET_JOB_ACCOUNT
  -- INCOMING PARAMETERS  : assignment_id,  effective_date
  -- OUTGOING PARAMETERS  : Account
  -- EXCEPTIONS           : OTHERS
  -- DESCRIPTION          : This procedure retrieves account from job
   PROCEDURE get_job_account (
      p_assignment_id    IN       NUMBER,
      p_effective_date   IN       DATE,
      p_account          OUT      VARCHAR2
   )
        --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
   IS
      l_module_name   cust.ttec_error_handling.module_name%TYPE;
      l_label1        cust.ttec_error_handling.label1%TYPE;
      l_reference1    cust.ttec_error_handling.reference1%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
   IS
      l_module_name   apps.ttec_error_handling.module_name%TYPE;
      l_label1        apps.ttec_error_handling.label1%TYPE;
      l_reference1    apps.ttec_error_handling.reference1%TYPE;
	  --END R12.2.10 Upgrade remediation


   BEGIN
      --
      SELECT pj.attribute7                                       --Account DFF
        INTO p_account
		 -- FROM hr.per_all_assignments_f paaf, hr.per_jobs pj --Commented code by MXKEERTHI-ARGANO, 05/19/2023
        FROM apps.per_all_assignments_f paaf, hr.per_jobs pj --code added by MXKEERTHI-ARGANO, 05/19/2023
      WHERE paaf.assignment_id = p_assignment_id
         AND p_effective_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
         AND paaf.job_id = pj.job_id;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         l_module_name := 'GET JOB ACCOUNT';
         l_label1 := 'assignment_id';
         l_reference1 := p_assignment_id;
         p_account := NULL;
		  --cust.ttec_process_error (c_application_code, --Commented code by MXKEERTHI-ARGANO, 05/19/2023
         apps.ttec_process_error (c_application_code,--code added by MXKEERTHI-ARGANO, 05/19/2023
                                 c_interface,
                                  c_program_name,
                                  l_module_name,
                                  c_failure_status,
                                  SQLCODE,
                                  SQLERRM,
                                  l_label1,
                                  l_reference1
                                 );
       --RAISE;
   --
   END;                                           -- PROCEDURE GET_JOB_ACCOUNT

--
-- This fuction retrieves the actual job title for each individual
--  based on the assignment_id.  This value is used for the PHL payroll
--  data to determine the correct account code prefix.
-- Bob Shanks, 19-Jun-2008
-- using Get_Job_Account procedure above, leaving for future reference.
-- BShanks
   FUNCTION getjob (p_assignment_id IN NUMBER)
      RETURN VARCHAR
   IS
        --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
      l_module_name   cust.ttec_error_handling.module_name%TYPE;
      l_label1        cust.ttec_error_handling.label1%TYPE;
      l_reference1    cust.ttec_error_handling.reference1%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
      l_module_name   apps.ttec_error_handling.module_name%TYPE;
      l_label1        apps.ttec_error_handling.label1%TYPE;
      l_reference1    apps.ttec_error_handling.reference1%TYPE;
	  --END R12.2.10 Upgrade remediation


      v_job_name      VARCHAR2 (100);
      v_job_group     VARCHAR2 (100);
      v_return        VARCHAR2 (30);
   BEGIN
      --
      SELECT NAME, pj.attribute6
        INTO v_job_name, v_job_group
        FROM per_jobs pj, per_all_assignments_f paaf
       WHERE paaf.assignment_id = p_assignment_id
         AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
         AND pj.job_id = paaf.job_id;

      --
      IF SUBSTR (v_job_name, 1, 5) IN
              ('10012', '10013', '10014', '10015', '10016', '10017', '10018')
      THEN
         -- Admin
         v_return := 'Admin';
      --
      ELSIF UPPER (v_job_group) LIKE 'NON-MANAGER%'
      THEN
         -- Agent
         v_return := 'Agent';
      --
      ELSE
         -- Supervisor
         v_return := 'Supervisor';
      --
      END IF;

      --
      RETURN (v_return);
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         l_module_name := 'GET JOB';
         l_label1 := 'assignment_id';
         l_reference1 := p_assignment_id;
		  --cust.ttec_process_error (c_application_code, --Commented code by MXKEERTHI-ARGANO, 05/19/2023
        apps.ttec_process_error (c_application_code,--code added by MXKEERTHI-ARGANO, 05/19/2023
                                 c_interface,
                                  c_program_name,
                                  l_module_name,
                                  c_failure_status,
                                  SQLCODE,
                                  SQLERRM,
                                  l_label1,
                                  l_reference1
                                 );
   --
   END getjob;

--////////////////////////////////////////////////////////////////////////////////////////////////////////
-- THIS PROCEDURE INSERTS AN ENTIRE NEW LINE IN THE PAY_COST_ALLOCATION_KEYFLEX TABLE INCLUDING THE COMPANY
-- AND TRADER FIELDS.  THIS IS NECESSARY SINCE THE COST_ALLOCATION_KEYFLEX_ID AT THE BALANCE(OR OFFSET) LEVEL
-- IS THE SAME COST_ALLOCATION_KEYFLEX_ID USED FOR THE DEFAULT ELEMENT ENTRY VALUE.
   PROCEDURE insert_keyflex_record (
      l_keyflex_record              IN       keyflex_record,
	   --l_business_group              IN       hr.per_all_assignments_f.business_group_id%TYPE, --Commented code by MXKEERTHI-ARGANO, 05/19/2023
      l_business_group              IN       apps.per_all_assignments_f.business_group_id%TYPE, --code added by MXKEERTHI-ARGANO, 05/19/2023
     p_new_allocation_keyflex_id   OUT      NUMBER
   )
   IS
      l_costflex_id     NUMBER                                        := NULL;
	       --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
       l_concatenated    hr.pay_cost_allocation_keyflex.concatenated_segments%TYPE
                                                                      := NULL;
      l_module_name     cust.ttec_error_handling.module_name%TYPE
                                                          := 'INSERT_KEYFLEX';
      l_label1          cust.ttec_error_handling.label1%TYPE
                                                          := 'keyflex_record';
      l_error_message   cust.ttec_error_handling.error_message%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
      l_concatenated    apps.pay_cost_allocation_keyflex.concatenated_segments%TYPE
                                                                      := NULL;
      l_module_name     apps.ttec_error_handling.module_name%TYPE
                                                          := 'INSERT_KEYFLEX';
      l_label1          apps.ttec_error_handling.label1%TYPE
                                                          := 'keyflex_record';
      l_error_message   apps.ttec_error_handling.error_message%TYPE;
	  --END R12.2.10 Upgrade remediation


   BEGIN
      l_costflex_id :=
         apps.pay_csk_flex.get_cost_allocation_id
            (p_business_group_id               => l_business_group,
                                                         --put your bg id here
             p_cost_allocation_keyflex_id      => l_keyflex_record.id_flex_num,
                                                      --really the id_flex_num
             p_concatenated_segments           => NULL,
             p_segment1                        => l_keyflex_record.segment1,
             p_segment2                        => l_keyflex_record.segment2,
             p_segment3                        => l_keyflex_record.segment3,
             p_segment4                        => l_keyflex_record.segment4,
             p_segment5                        => l_keyflex_record.segment5,
             p_segment6                        => l_keyflex_record.segment6,
             p_segment7                        => NULL,
             p_segment8                        => NULL,
             p_segment9                        => NULL,
             p_segment10                       => NULL,
             p_segment11                       => NULL,
             p_segment12                       => NULL,
             p_segment13                       => NULL,
             p_segment14                       => NULL,
             p_segment15                       => NULL,
             p_segment16                       => NULL,
             p_segment17                       => NULL,
             p_segment18                       => NULL,
             p_segment19                       => NULL,
             p_segment20                       => NULL,
             p_segment21                       => NULL,
             p_segment22                       => NULL,
             p_segment23                       => NULL,
             p_segment24                       => NULL,
             p_segment25                       => NULL,
             p_segment26                       => NULL,
             p_segment27                       => NULL,
             p_segment28                       => NULL,
             p_segment29                       => NULL,
             p_segment30                       => NULL
            );
      p_new_allocation_keyflex_id := l_costflex_id;
      l_concatenated :=
            l_keyflex_record.segment1
         || '.'
         || l_keyflex_record.segment2
         || '.'
         || l_keyflex_record.segment3
         || '.'
         || l_keyflex_record.segment4
         || '.'
         || l_keyflex_record.segment5
         || '.'
         || l_keyflex_record.segment6;

      /* BS Fnd_File.put_line(Fnd_File.LOG,'Insert_Keyflex_Record, l_concat>'
         || l_concatenated || '<, l_costflex_id >' || l_costflex_id || '<.'); */
		  --gl.GL_SETS_OF_BOOKS bk   --Commented code by MXKEERTHI-ARGANO, 05/19/2023
     UPDATE apps.pay_cost_allocation_keyflex  --code added by MXKEERTHI-ARGANO, 05/19/2023

 
         SET concatenated_segments = l_concatenated
       WHERE cost_allocation_keyflex_id = l_costflex_id;

      --
      COMMIT;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
	   -- cust.ttec_process_error (c_application_code,--Commented code by MXKEERTHI-ARGANO, 05/19/2023
         apps.ttec_process_error (c_application_code, --code added by MXKEERTHI-ARGANO, 05/19/2023
                                 c_interface,
                                  c_program_name,
                                  l_module_name,
                                  c_failure_status,
                                  SQLCODE,
                                  SQLERRM,
                                  l_label1,
                                  l_label1
                                 );
         RAISE;
   END;

--///////////////////////////////////////////////////////////////////////
     --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
    PROCEDURE update_pay_costs (
      l_cost_allocation_keyflex_id   IN   hr.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      l_new_allocation_keyflex_id    IN   hr.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      l_cost_id                      IN   hr.pay_costs.cost_id%TYPE
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
   PROCEDURE update_pay_costs (
      l_cost_allocation_keyflex_id   IN   apps.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      l_new_allocation_keyflex_id    IN   apps.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      l_cost_id                      IN   apps.pay_costs.cost_id%TYPE
	  --END R12.2.10 Upgrade remediation

   )
   IS
   BEGIN
      /* BS Fnd_File.put_line(Fnd_File.LOG,'Update_Pay_Costs, l_alloc_keyflex_id >'
         || l_cost_allocation_keyflex_id || '<.');
      Fnd_File.put_line(Fnd_File.LOG,''); */ -- insert blank line after record
	   -- UPDATE hr.pay_costs --Commented code by MXKEERTHI-ARGANO, 05/19/2023
      UPDATE apps.pay_costs--code added by MXKEERTHI-ARGANO, 05/19/2023
         SET cost_allocation_keyflex_id = l_new_allocation_keyflex_id
       WHERE
                --COST_ALLOCATION_KEYFLEX_ID = l_cost_allocation_keyflex_id
             --AND
             cost_id = l_cost_id;

      --
      COMMIT;
   --
   END;
--///////////////////////////////////////////////////////////////////////*/
BEGIN
   --
   apps.fnd_file.put_line (2, 'Starting Custom Costing program');
   --Fnd_File.put_line(Fnd_File.LOG,'Starting Custom Costing program');
   v_keyflex_record := NULL;
   g_consolidation_set := TO_NUMBER (g_consolidation_set);
   g_payroll := TO_NUMBER (g_payroll);

   OPEN get_cost_level;

   --
   apps.fnd_file.put_line (2, 'Starting Cost Level Loop');
   fnd_file.put_line (fnd_file.LOG, 'Starting Cost Level Loop');

   LOOP
      BEGIN
         FETCH get_cost_level
          INTO v_cost_allocation_keyflex_id, v_business_group,
               v_assignment_id, v_cost_id, v_cost_location, v_cost_client,
               v_cost_department, v_cost_account, v_cost_future1,
               v_cost_future2, v_cost_id_flex_num, v_cost_summary_flag,
               v_cost_enabled_flag, v_cost_run_result_id,
               v_cost_dist_run_result_id;

         IF get_cost_level%NOTFOUND
         THEN
            fnd_file.put_line (fnd_file.LOG,
                                  'No records found in get_cost_level '
                               || 'cursor.'
                              );
            NULL;
         END IF;

         EXIT WHEN get_cost_level%NOTFOUND;
      END;

      --================== COST ACCOUNT SECTION ==========================
      v_insert := 0;
      -------NEW ----------------------- := ORIGINAL-----------------------
      v_keyflex_record.segment1 := v_cost_location;
      v_keyflex_record.segment2 := v_cost_client;
      v_keyflex_record.segment3 := v_cost_department;
      v_keyflex_record.segment4 := v_cost_account;
      v_keyflex_record.segment5 := v_cost_future1;
      v_keyflex_record.segment6 := v_cost_future2;
      v_keyflex_record.id_flex_num := v_cost_id_flex_num;
      v_keyflex_record.summary_flag := v_cost_summary_flag;
      v_keyflex_record.enabled_flag := v_cost_enabled_flag;

      -- Analyze Segment1 - Location
      --Fnd_File.put_line(Fnd_File.LOG,'Step 1,v_business_group>'||v_business_group||'<');
      IF v_cost_location IS NULL
      THEN
         --
         get_location_dff (v_assignment_id, g_end_date, v_location_dff);
         v_keyflex_record.segment1 := v_location_dff;
         v_insert := 1;
      --
      END IF;

      -- CANADA
      IF v_business_group = 326
      THEN
         --
         IF    v_cost_account IN ('1032', '2915', '8100')
            OR (SUBSTR (v_cost_account, 1, 2) IN ('22', '24'))
         THEN
            --
            IF v_cost_account NOT IN ('2204', '2470', '2471')
            THEN
               --
               v_keyflex_record.segment1 := '05300';
               v_insert := 1;
            --
            END IF;
         --
         END IF;

         -- CA -  Newgen   ikonak 04/24/2003
         IF g_payroll = 62
         THEN                                                 -- Newgen Canada
            --
            v_keyflex_record.segment1 := '05150';
            v_insert := 1;
         --
         END IF;
      --
      END IF;                                                 -- end of Canada

      -- USA
      IF v_business_group = 325
      THEN
         --
         IF g_payroll = 46
         THEN                                             -- Percepta Payroll
            --
            -- start of modification for ticket #415398
             -- change for Percepta payroll costing.  Need to change location
             -- 01002 to 11012. Added eval of cost_location to existing code
             -- below.  Also added messaging to show value before and after
             -- processing.  No other changes identified by Leslie Tew.
             --  Bob Shanks, 2/26/2008
             -- More accounts added per comment from Leslie on results of
             --  initial test.  Added accounts 2410, 2411, 2412, 2413, 2414,
             --  2426, 2427 per her comment.
             --  Bob Shanks, 3/3/2008
             -- Added more codes based on third comment from user. BShanks
            fnd_file.put_line (fnd_file.LOG,
                                  'Percepta In>'
                               || v_cost_location
                               || '.'
                               || v_cost_client
                               || '.'
                               || v_cost_department
                               || '.'
                               || v_cost_account
                              );

            --
            IF (   (v_cost_location = '01002')
                OR (v_cost_account IN
                       ('1032', '2220', '2230', '2250', '2260', '2270',
                        '2280', '2410', '2411', '2412', '2413', '2414',
                        '2415', '2425', '2426', '2427', '2430', '2440',
                        '2915', '8100')
                   )
               )
            THEN
               --
               v_keyflex_record.segment1 := '11012';
               v_insert := 1;
            --
            END IF;

            --
            fnd_file.put_line (fnd_file.LOG,
                                  'Percepta Out>'
                               || v_keyflex_record.segment1
                               || '.'
                               || v_keyflex_record.segment2
                               || '.'
                               || v_keyflex_record.segment3
                               || '.'
                               || v_keyflex_record.segment4
                              );
         -- end of modification for #415398, BShanks
         --

         -- All other US Payrolls
         -- 12/16/2003  WO# 53160
         ELSE
            --
            IF    v_cost_account IN
                            ('1032', '2915', '2415', '2425', '2426', '2430')
               OR (SUBSTR (v_cost_account, 1, 2) = '22')
            THEN
               --
               v_keyflex_record.segment1 := '01002';
               v_insert := 1;
            --
            END IF;

            IF v_cost_account IN ('2440', '8100')
            THEN
               --
               v_keyflex_record.segment1 := '01001';
               v_insert := 1;
            --
            END IF;
         --
         END IF;

         --  ikonak 020505
         --  Change location for US Newgen emloyees to 01220
         IF g_payroll = 85
         THEN                                                    --  NEWGEN US
            --
            IF v_keyflex_record.segment1 <> '01220'
            THEN
               --
               v_keyflex_record.segment1 := '01220';
               v_insert := 1;
            --
            END IF;
         --
         END IF;

         -- Version 1.2 <Start>
         IF g_payroll = 137
         THEN                                      --  Government Solutions US
            --
            IF v_keyflex_record.segment1 <> '07020'
            THEN
               --
               v_keyflex_record.segment1 := '07020';
               v_insert := 1;
            --
            END IF;
         END IF;
      -- Version 1.2 <End>
      --
      END IF;                                                    -- end of USA

      -- Analyze Segment2 - Client
      IF    (v_cost_account = '8100')
         OR (v_cost_account >= 1000 AND v_cost_account <= 2999)
      THEN
         --
         v_keyflex_record.segment2 := '0000';
         v_insert := 1;
      --
      END IF;

      -- Analyze Segment3 - Department
      IF    (v_cost_account = '8100')
         OR (v_cost_account >= 1000 AND v_cost_account <= 2999)
      THEN
         --
         v_keyflex_record.segment3 := '000';
         v_insert := 1;
      --
      END IF;

      --Revision 1.3 <Starts>
        /*IF (v_cost_account = '5025') AND (v_business_group = 325) THEN
          --
          v_keyflex_record.segment3 := '030';
          v_insert := 1;
          --
        END IF;*/
      --Revision 1.3 <Ends>
        -- Analyze Segment4 - Account
      get_element (v_cost_run_result_id,
                   v_cost_dist_run_result_id,
                   v_element_name
                  );

      IF v_business_group = 325
      THEN                                           -- Teletech Holdings - US
         --
         IF v_element_name IN
               ('Bereavement Pay', 'Coaching', 'Earnings Adjust',
                'Earnings Adjustment', 'Jury Duty', 'Other_Reg_Flat',
                'Other_Reg', 'Other_Supp_Flat', 'Other_Supp',
                'Personal Holiday Taken', 'Regular Hours', 'Retroactive Pay',
                'Severance_Flat', 'Severance', 'Training Assistant',
                'TT Time Entry Wages', 'US Regular Salary',
                'Wage after Death_CYr_Flat', 'Wages after Death_CYr',
                'Wage after Death_FYr_Flat', 'Wages after Death_FYr',

                -- Wasim M added those Oct 12 2005
                'PTO Special Features', 'Sick Bank Special Features',
                'Unpaid Absence Special Features',
                'Bereavement Special Features',
                'Holiday Pay Special Features', 'Jury Special Features',
                'Home Leave Special Features')
         THEN
            --
            get_job_account (v_assignment_id, SYSDATE, v_job_account);

            --
            IF v_job_account IS NOT NULL
            THEN
               --
               IF v_keyflex_record.segment4 IS NOT NULL
               THEN
                  --
                  IF v_job_account <> v_keyflex_record.segment4
                  THEN
                     --
                     v_keyflex_record.segment4 := v_job_account;
                     v_insert := 1;
                  --
                  END IF;
               --
               ELSE
                  --
                  v_keyflex_record.segment4 := v_job_account;
                  v_insert := 1;
               --
               END IF;
            --
            END IF;
         --
         END IF;

         -- ikonak 07/02/03
         IF v_keyflex_record.segment4 = '1032'
         THEN
            --
            v_keyflex_record.segment4 := '1038';
            v_insert := 1;
         --
         END IF;
      ELSIF v_business_group = 326
      THEN
         --
         IF v_element_name IN
               ('Bereavement Pay', 'CND Regular Salary', 'Jury Duty',
                'Lieu of Notice Pay', 'Lieu of Notice Flat', 'Lieu Day',
                'Regular Hours', 'Regular Wages', 'Retiring Allowance',
                'Retro Hourly', 'Severance', 'TT Time Entry Wages')
         THEN
            --
            get_job_account (v_assignment_id, SYSDATE, v_job_account);

            --
            IF v_job_account IS NOT NULL
            THEN
               --
               IF v_keyflex_record.segment4 IS NOT NULL
               THEN
                  --
                  IF v_job_account <> v_keyflex_record.segment4
                  THEN
                     --
                     v_keyflex_record.segment4 := v_job_account;
                     v_insert := 1;
                  --
                  END IF;
               --
               ELSE
                  --
                  v_keyflex_record.segment4 := v_job_account;
                  v_insert := 1;
               --
               END IF;
            --
            END IF;
         --
         END IF;
      END IF;

      --  For all business groups
      IF     (v_keyflex_record.segment2 = '0000')
         AND (SUBSTR (v_keyflex_record.segment4, 1, 1) = '5')
      THEN
         --
         v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
         v_insert := 1;
      --
      END IF;

      IF v_business_group IN (325, 326)
      THEN                                                   --  for US and CA
         --   change to 7
         IF SUBSTR (v_keyflex_record.segment4, 1, 1) = '5'
         THEN                                                --   change to 7
            IF     v_keyflex_record.segment3 IN
                      ('000', '001', '020', '096', '097', '090', '035',
                       '057', '025', '026', '027', '028', '029', '045',
                       '085', '015')
               AND v_keyflex_record.segment1 IN
                      ('01002', '01050', '01001', '01003', '01010', '01011',
                       '01015', '01020', '01049', '01051', '01059', '01066',
                       '01068', '01069', '01070', '01098', '01110', '01111',
                       '01115', '01117', '01122', '01202', '01249', '01251',
                       '01252', '01253', '01254', '01300', '01310', '01350',
                       '01351', '01352', '01353', '01600', '01650', '01680',
                       '01271')
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            ELSIF     v_keyflex_record.segment3 IN
                         ('014', '019', '021', '080', '095', '041', '016',
                          '051', '060', '091', '040', '050', '055', '058',
                          '075', '070', '022', '024')
                  AND v_keyflex_record.segment1 IN ('01002', '01050')
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            ELSIF     v_keyflex_record.segment3 IN ('017', '018')
                  AND v_keyflex_record.segment1 = '01002'
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            ELSIF     v_keyflex_record.segment3 = '024'
                  AND v_keyflex_record.segment1 IN
                         ('01001', '01003', '01010', '01011', '01015',
                          '01020', '01049', '01051', '01059', '01066',
                          '01068', '01069', '01070', '01098', '01110',
                          '01111', '01115', '01117', '01122', '01202',
                          '01249', '01251', '01252', '01253', '01254',
                          '01300', '01310', '01350', '01351', '01352',
                          '01353', '01600', '01650', '01680', '01271')
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            END IF;
         --
         END IF;                                          ---  change to 7 end

         --   change to 5
         IF SUBSTR (v_keyflex_record.segment4, 1, 1) = '7'
         THEN                                                 --   change to 5
            --
            IF     v_keyflex_record.segment3 IN
                      ('060', '091', '040', '050', '055', '058', '075',
                       '070')
               AND v_keyflex_record.segment1 IN
                      ('01001', '01003', '01010', '01011', '01015', '01020',
                       '01049', '01051', '01059', '01066', '01068', '01069',
                       '01070', '01098', '01110', '01111', '01115', '01117',
                       '01122', '01202', '01249', '01251', '01252', '01253',
                       '01254', '01300', '01310', '01350', '01351', '01352',
                       '01353', '01600', '01650', '01680', '01271')
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            ELSIF     v_keyflex_record.segment3 IN
                         ('005', '006', '007', '008', '010', '012', '030',
                          '056', '065', '066')
                  AND v_keyflex_record.segment1 IN
                         ('01050', '01001', '01003', '01010', '01011',
                          '01015', '01020', '01049', '01051', '01059',
                          '01066', '01068', '01069', '01070', '01098',
                          '01110', '01111', '01115', '01117', '01122',
                          '01202', '01249', '01251', '01252', '01253',
                          '01254', '01300', '01310', '01350', '01351',
                          '01352', '01353', '01600', '01650', '01680',
                          '01271')
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            END IF;
         --
         END IF;                                          --   change to 5 end

         -- Change added for ticket #292417, Added conditional for DAC
         -- payroll costing modification.  BShanks, 16-Oct-2007
         IF v_business_group = 325 AND g_payroll = 280
         THEN
            /*Fnd_File.put_line(Fnd_File.LOG,'DAC In >'
                             ||v_keyflex_record.segment1||'.'
                             ||v_keyflex_record.segment2||'.'
                             ||v_keyflex_record.segment3||'.'
                             ||v_keyflex_record.segment4||'.'
                             ||v_keyflex_record.segment5||'.'
                             ||v_keyflex_record.segment6); */

            --Fnd_File.put_line(Fnd_File.LOG,'Inside 1st cond');
            -- seg1 evaluation
            IF v_keyflex_record.segment1 = '01002'
            THEN
               --
               v_keyflex_record.segment1 := '01900';
               v_insert := 1;
            --
            ELSIF     v_keyflex_record.segment1 IN ('01900', '01901')
                  AND v_keyflex_record.segment2 != '0000'
            THEN
               -- chg seg1 to '01901' in either case
               v_keyflex_record.segment1 := '01901';
               v_insert := 1;
            --
            ELSIF     v_keyflex_record.segment1 = '01900'
                  AND v_keyflex_record.segment2 = '0000'
            THEN
               -- ensure seg1 is '01900'
               v_keyflex_record.segment1 := '01900';
               v_insert := 1;
            --
            ELSIF     v_keyflex_record.segment1 = '01901'
                  AND v_keyflex_record.segment2 = '0000'
            THEN
               -- chg seg1 to '01900
               v_keyflex_record.segment1 := '01900';
               v_insert := 1;
            --
            END IF;                                           -- segment1 eval

            -- New set of requirements for DAC, rec'd 04-Dec-2007
            -- Segment2 eval to reset segment1, 10
            IF     v_keyflex_record.segment2 = '9500'
               AND v_keyflex_record.segment1 != '01900'
            THEN
               -- chg segment1 to '01900'
               v_keyflex_record.segment1 := '01900';
               v_insert := 1;
            --
            END IF;

            -- reset segment4 based on initial value
            IF v_keyflex_record.segment4 IN ('7000', '7030')
            THEN
               --
               v_keyflex_record.segment4 := '7010';
               v_insert := 1;
            --
            ELSIF v_keyflex_record.segment4 = '5030'
            THEN
               --
               v_keyflex_record.segment4 := '5010';
               v_insert := 1;
            --
            END IF;

            -- End of new requirements addition, BShanks
            -- Eval segment 3 and change segment 4 as necessary
            IF     SUBSTR (v_keyflex_record.segment4, 1, 1) = '7'
               AND v_keyflex_record.segment3 IN
                                          ('008', '010', '030', '065', '068')
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            ELSIF     SUBSTR (v_keyflex_record.segment4, 1, 1) = '5'
                  AND v_keyflex_record.segment3 IN
                                                 ('015', '045', '060', '085')
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            END IF;                                          -- segment 4 eval

            -- Segment3 subset with or without client
            IF     v_keyflex_record.segment3 IN
                                          ('050', '055', '058', '074', '075')
               AND v_keyflex_record.segment2 = '0000'
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            ELSIF     v_keyflex_record.segment3 IN ('020')
                  AND v_keyflex_record.segment2 != '0000'
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            ELSIF     v_keyflex_record.segment3 IN
                                          ('050', '055', '058', '074', '075')
                  AND v_keyflex_record.segment2 != '0000'
            THEN
               --
               v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            END IF;                 -- Segment3 subset with and without client
         /*Fnd_File.put_line(Fnd_File.LOG,'DAC Out>'
                          ||v_keyflex_record.segment1||'.'
                          ||v_keyflex_record.segment2||'.'
                          ||v_keyflex_record.segment3||'.'
                          ||v_keyflex_record.segment4||'.'
                          ||v_keyflex_record.segment5||'.'
                          ||v_keyflex_record.segment6); */
         END IF;                                           -- DAC modification
      -- end of modification for ticket #292417
      END IF;                                      --  business group 325, 326

      -- Elango added the following for request 91233
      -- Need to modify custom costing to set the accounts to 7XXX when the client is 5901 for PERCEPTA payroll.
      IF     g_payroll = 46
         AND v_cost_client = 5901
         AND (SUBSTR (v_keyflex_record.segment4, 1, 1) = '5')       /* Version 1.5 */
      THEN
         v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
         v_insert := 1;
      END IF;

       -- Modification for PHL Payroll, 16-Jun-2008, BShanks
      -- revision 1.1 <Start>
      IF v_business_group = 1517
      THEN
         fnd_file.put_line (fnd_file.LOG,
                               'PHL In >'
                            || v_keyflex_record.segment1
                            || '.'
                            || v_keyflex_record.segment2
                            || '.'
                            || v_keyflex_record.segment3
                            || '.'
                            || v_keyflex_record.segment4
                            || '.'
                            || v_keyflex_record.segment5
                            || '.'
                            || v_keyflex_record.segment6
                           );

         -- PHL Non-Mgmt Payroll
         IF g_payroll = 401
         THEN                                                     --'Non-Mgmt'
            -- Revision 1.1 <Starts>
            IF     v_keyflex_record.segment1 != '01090'
               AND v_keyflex_record.segment4 IN ('5030', '5010')
            THEN
               IF v_keyflex_record.segment3 IN ('005', '010')
               THEN
                  v_keyflex_record.segment4 := '5000';
                  v_insert := 1;
               ELSIF v_keyflex_record.segment3 IN
                                          ('015', '016', '035', '085', '094')
               THEN
                  v_keyflex_record.segment4 := '7010';
                  v_insert := 1;
               ELSE
                  v_keyflex_record.segment4 := '5010';
                  v_insert := 1;
               END IF;
            ELSIF     v_keyflex_record.segment2 = '9500'
                  AND v_keyflex_record.segment4 != '7030'
            THEN
               IF v_keyflex_record.segment3 IN
                     ('000', '001', '004', '013', '014', '015', '016', '019',
                      '020', '021', '022', '024', '025', '026', '027', '028',
                      '029', '035', '041', '043', '044', '045', '046', '057',
                      '071', '080', '085', '090', '091', '094', '095', '096',
                      '097')
               THEN
                  -- set account code to start with a '7'
                  v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
                  v_keyflex_record.segment2 := '0000';
                  v_insert := 1;
               ELSIF v_keyflex_record.segment3 IN
                       ('006', '007', '008', '066', '009', '012', '030',
                        '040', '050', '052', '055', '056', '058', '060',
                        '064', '065', '070', '072', '073', '075')
               THEN
                  -- set account code to start with a '5'
                  v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
                  --v_keyflex_record.segment2 := '0000';
                  v_insert := 1;
               END IF;                                      -- dept evaluation
            ELSIF     v_keyflex_record.segment1 = '01090'
                  AND v_keyflex_record.segment2 = '0875'
                  AND v_keyflex_record.segment4 != '7030'
            THEN
               -- Evaluate dept to set account
               IF v_keyflex_record.segment3 IN
                     ('000', '001', '004', '013', '014', '015', '016', '019',
                      '020', '021', '022', '024', '025', '026', '027', '028',
                      '029', '035', '040', '041', '043', '044', '045', '046',
                      '057', '064', '071', '080', '085', '090', '091', '094',
                      '095', '096', '097', '006', '007', '009', '010', '012',
                      '050', '052', '055', '058', '060', '070', '072', '073',
                      '075')
               THEN
                  -- set account code to start with a '7'
                  v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
                  v_insert := 1;
               --
               ELSIF v_keyflex_record.segment3 IN
                                          ('008', '030', '066', '065', '056')
               THEN
                  -- set account code to start with a '5'
                  v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
                  v_insert := 1;
               --
               END IF;                                      -- dept evaluation
            ELSIF     v_keyflex_record.segment1 = '01090'
                  AND v_keyflex_record.segment4 != '7030'
            THEN
               IF v_keyflex_record.segment3 IN ('035', '085')
               THEN
                  -- set account code to start with a '7'
                  v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
                  v_insert := 1;
               ELSIF v_keyflex_record.segment3 IN ('065', '005')
               THEN
                  v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
                  v_insert := 1;
               END IF;
            ELSIF     v_keyflex_record.segment1 = '01090'
                  AND v_keyflex_record.segment2 NOT IN ('0000', '0875')
                  AND v_keyflex_record.segment4 != '7030'
            THEN
               -- use existing code to retrieve per_jobs.attribute7
               get_job_account (v_assignment_id, SYSDATE, v_job_account);
               --
               v_keyflex_record.segment4 := v_job_account;
               v_insert := 1;
            END IF;                                 -- Non-Mgmt sub-processing
         -- Revision 1.1 <Ends>
         END IF;                                       -- PHL Non-Mgmt Payroll

         -- PHL Mgmt Payroll
         IF g_payroll = 400
         THEN
            --
            IF     v_keyflex_record.segment1 = '01060'
               AND v_keyflex_record.segment2 = '0000'
               AND v_keyflex_record.segment3 = '000'
               AND v_keyflex_record.segment4 != '7030'
            THEN
               -- no change to account coding
               NULL;
            --
            ELSIF     v_keyflex_record.segment1 = '01060'
                  AND v_keyflex_record.segment2 = '0000'
                  AND v_keyflex_record.segment3 != '000'
                  AND v_keyflex_record.segment4 != '7030'
            THEN
               -- evaluate department to set account
               IF v_keyflex_record.segment3 IN
                     ('008', '040', '041', '044', '045', '055', '065', '071',
                      '085', '094')
               THEN
                  -- set account code to start with a '7'
                  v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
                  v_insert := 1;
               --
               ELSE
                  -- set account code to start with a '5'
                  v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
                  v_insert := 1;
               --
               END IF;                         -- mgmt payroll, dept code eval
            --
            ELSIF     v_keyflex_record.segment1 = '01090'
                  AND v_keyflex_record.segment2 = '0875'
                  AND v_keyflex_record.segment3 IN
                         ('000', '001', '004', '013', '014', '015', '016',
                          '019', '020', '021', '022', '024', '025', '026',
                          '027', '028', '029', '035', '040', '041', '043',
                          '044', '045', '046', '052', '057', '064', '071',
                          '080', '085', '090', '091', '094', '095', '096',
                          '097')
                  AND v_keyflex_record.segment4 != '7030'
            THEN
               -- set account code to start with a '7'
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            ELSIF v_keyflex_record.segment3 IN ('042', '085', '094')
            THEN
               --
               v_keyflex_record.segment2 := '0000';
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            --
            END IF;                                 -- All Mgmt sub-processing
         --
         END IF;                                           -- PHL Mgmt Payroll

         --
         -- Other locations
         IF     v_keyflex_record.segment1 NOT IN ('01060', '01090')
            AND v_keyflex_record.segment2 = '0000'
            AND v_keyflex_record.segment4 != '7030'
            AND v_insert = 0
         THEN
            -- set account code to start with a '7'
            v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
            v_insert := 1;
         --
         ELSIF     v_keyflex_record.segment1 NOT IN ('01060', '01090')
               AND v_keyflex_record.segment2 != '0000'
               AND v_keyflex_record.segment4 != '7030'
               AND v_insert = 0
         THEN
            -- set account code to start with a '5'
            v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
            v_insert := 1;
         --
         END IF;                              -- Other location sub-processing

         --
         -- segment 4 specific
         IF v_keyflex_record.segment4 = '7030'
         THEN
            -- set to '7010'
            v_keyflex_record.segment4 := '7010';
            v_insert := 1;
         --
         END IF;                                         -- segment 4 specific

         fnd_file.put_line (fnd_file.LOG,
                               'PHL Out>'
                            || v_keyflex_record.segment1
                            || '.'
                            || v_keyflex_record.segment2
                            || '.'
                            || v_keyflex_record.segment3
                            || '.'
                            || v_keyflex_record.segment4
                            || '.'
                            || v_keyflex_record.segment5
                            || '.'
                            || v_keyflex_record.segment6
                           );
      END IF;                                     -- PHL Payroll modifications

      --  Validate and Update the new combination
      IF v_insert = 1
      THEN
         --
         insert_keyflex_record (v_keyflex_record,
                                v_business_group,
                                v_new_allocation_keyflex_id
                               );
         --
         update_pay_costs (v_cost_allocation_keyflex_id,
                           v_new_allocation_keyflex_id,
                           v_cost_id
                          );
         --
         v_insert := 0;
      --
      END IF;

      v_cost_allocation_keyflex_id := NULL;
      v_new_allocation_keyflex_id := NULL;
      v_person_id := NULL;
      v_cost_location := NULL;
      v_cost_client := NULL;
      v_cost_department := NULL;
      v_cost_account := NULL;
      v_cost_future1 := NULL;
      v_cost_future2 := NULL;
      v_cost_id_flex_num := NULL;
      v_cost_summary_flag := NULL;
      v_cost_enabled_flag := NULL;
      v_business_group := NULL;
      v_cost_id := NULL;
      v_keyflex_record := NULL;
      v_insert := 0;
      v_location_dff := NULL;
      v_element_name := NULL;
      v_job_account := NULL;
   END LOOP;

   apps.fnd_file.put_line (2, 'Ending Cost Level Loop');

   --Fnd_File.put_line(Fnd_File.LOG,'Ending Cost Level Loop');
   CLOSE get_cost_level;

   -- =============    OFFSET ACCOUNT SECTION   =================
   OPEN get_offset_level;

   apps.fnd_file.put_line (2, 'Starting Offset Level Loop');

   LOOP
      BEGIN
         FETCH get_offset_level
          INTO v_cost_allocation_keyflex_id, v_business_group,
               v_assignment_id, v_bal_location, v_bal_client,
               v_bal_department, v_bal_account, v_bal_future1, v_bal_future2,
               v_bal_id_flex_num, v_bal_summary_flag, v_bal_enabled_flag,
               v_cost_id, v_pre_payment_id, v_assignment_action_id,
               v_bal_run_result_id, v_bal_dist_run_result_id;

         IF get_offset_level%NOTFOUND
         THEN
            fnd_file.put_line (fnd_file.LOG,
                                  'No records found in '
                               || 'get_offset_level cursor.'
                              );
         END IF;

         EXIT WHEN get_offset_level%NOTFOUND;
      END;

      v_insert := 0;                             -- initial insert/change flag
      v_keyflex_record.segment1 := v_bal_location;
      v_keyflex_record.segment2 := v_bal_client;
      v_keyflex_record.segment3 := v_bal_department;
      v_keyflex_record.segment4 := v_bal_account;
      v_keyflex_record.segment5 := v_bal_future1;
      v_keyflex_record.segment6 := v_bal_future2;
      v_keyflex_record.id_flex_num := v_bal_id_flex_num;
      v_keyflex_record.summary_flag := v_bal_summary_flag;
      v_keyflex_record.enabled_flag := v_bal_enabled_flag;

      -- Analyze Location
       -- CANADA
      IF v_keyflex_record.segment1 IS NULL AND v_business_group = 326
      THEN
         v_keyflex_record.segment1 := '05300';
         v_insert := 1;
      END IF;

      -- CA -  Newgen   ikonak 04/24/2003
      IF v_business_group = 326 AND g_payroll = 62
      THEN                                                    -- Newgen Canada
         v_keyflex_record.segment1 := '05150';
         v_insert := 1;
      END IF;

      --US
      IF v_business_group = 325
      THEN
         -- US - Percepta
         IF g_payroll = 46
         THEN
            IF (   SUBSTR (v_keyflex_record.segment1, 1, 1) != '1'
                OR v_keyflex_record.segment1 IS NULL
               )
            THEN
               v_keyflex_record.segment1 := '11012';
               v_insert := 1;
            END IF;
         ELSE
             -- Rest of US
            -- 12/16/2003   WO# 53160
            IF v_keyflex_record.segment4 IN
                  ('2210', '2220', '2230', '2240', '2250', '2260', '2270',
                   '2280', '2290', '2425', '2426', '2430')
            THEN
               v_keyflex_record.segment1 := '01002';
               v_insert := 1;
            END IF;
         END IF;                                                     --Payroll

         --  ikonak 020505
         --  Change location for US Newgen emloyees to 01220
         IF g_payroll = 85
         THEN                                                    --  NEWGEN US
            IF v_keyflex_record.segment1 <> '01220'
            THEN
               v_keyflex_record.segment1 := '01220';
               v_insert := 1;
            END IF;
         END IF;

         -- Version 1.2 <Start>
         IF g_payroll = 137
         THEN                                      --  Government Solutions US
            --
            IF v_keyflex_record.segment1 <> '07020'
            THEN
               --
               v_keyflex_record.segment1 := '07020';
               v_insert := 1;
            --
            END IF;
         END IF;
      -- Version 1.2 <End>
      END IF;                                                             --US

      -- Analyze Account
      -- US Change Wells Fargo to Bank Of America   (ikonak 07/02/03)
      IF v_business_group = 325
      THEN
         IF v_keyflex_record.segment4 = '1032'
         THEN
            v_keyflex_record.segment4 := '1038';
            v_insert := 1;
         END IF;
      END IF;

      -- Change added for ticket #292417, Added conditional for DAC
      -- payroll costing modification.  BShanks, 16-Oct-2007
      /*Fnd_File.put_line(Fnd_File.LOG,'Entering modification, seg1 >'
                         ||v_keyflex_record.segment1||'<, seg2 >'
                         ||v_keyflex_record.segment2||'<, seg3 >'
                         ||v_keyflex_record.segment3||'<, seg4 >'
                         ||v_keyflex_record.segment4||'<.'); */
      --
      IF v_business_group = 325 AND g_payroll = 280
      THEN
         -- seg1 evaluation
         IF v_keyflex_record.segment1 = '01002'
         THEN
            --
            v_keyflex_record.segment1 := '01900';
            v_insert := 1;
         --
         ELSIF     v_keyflex_record.segment1 IN ('01900', '01901')
               AND v_keyflex_record.segment2 != '0000'
         THEN
            -- chg seg1 to '01901' in either case
            v_keyflex_record.segment1 := '01901';
            v_insert := 1;
         --
         ELSIF     v_keyflex_record.segment1 = '01900'
               AND v_keyflex_record.segment2 = '0000'
         THEN
            -- ensure seg1 is '01900'
            v_keyflex_record.segment1 := '01900';
            v_insert := 1;
         --
         ELSIF     v_keyflex_record.segment1 = '01901'
               AND v_keyflex_record.segment2 = '0000'
         THEN
            -- chg seg1 to '01900'
            v_keyflex_record.segment1 := '01900';
            v_insert := 1;
         --
         END IF;                                              -- segment1 eval

         --
         -- New set of requirements for DAC, rec'd 04-Dec-2007
         -- Segment2 eval to reset segment1, 10
         IF v_keyflex_record.segment2 = '9500'
         THEN
            -- chg segment1 to '01900'
            v_keyflex_record.segment1 := '01900';
            v_insert := 1;
         --
         END IF;

         -- reset segment4 based on initial value
         IF v_keyflex_record.segment4 IN ('7000', '7030')
         THEN
            --
            v_keyflex_record.segment4 := '7010';
            v_insert := 1;
         --
         ELSIF v_keyflex_record.segment4 = '5030'
         THEN
            --
            v_keyflex_record.segment4 := '5010';
            v_insert := 1;
         --
         END IF;

         -- End of new requirements addition, BShanks
         -- Eval segment 3 and change segment 4 as necessary
         IF     SUBSTR (v_keyflex_record.segment4, 1, 1) = '7'
            AND v_keyflex_record.segment3 IN
                                          ('008', '010', '030', '065', '068')
         THEN
            --
            v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
            v_insert := 1;
         --
         ELSIF     SUBSTR (v_keyflex_record.segment4, 1, 1) = '5'
               AND v_keyflex_record.segment3 IN ('015', '045', '060', '085')
         THEN
            --
            v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
            v_insert := 1;
         --
         END IF;                                             -- segment 4 eval

         --
         -- Segment3 subset with or without client
         IF     v_keyflex_record.segment3 IN
                                          ('050', '055', '058', '074', '075')
            AND v_keyflex_record.segment2 = '0000'
         THEN
            --
            v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
            v_insert := 1;
         --
         ELSIF     v_keyflex_record.segment3 IN
                                          ('050', '055', '058', '074', '075')
               AND v_keyflex_record.segment2 != '0000'
         THEN
            --
            v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
            v_insert := 1;
         --
         END IF;                    -- Segment3 subset with and without client
      /*Fnd_File.put_line(Fnd_File.LOG,'Exiting modification, seg1 >'
                       ||v_keyflex_record.segment1||'<, seg2 >'
                       ||v_keyflex_record.segment2||'<, seg3 >'
                       ||v_keyflex_record.segment3||'<, seg4 >'
                       ||v_keyflex_record.segment4||'<.'); */
      END IF;                                              -- DAC modification

      IF v_insert = 1
      THEN
         --
         insert_keyflex_record (v_keyflex_record,
                                v_business_group,
                                v_new_allocation_keyflex_id
                               );
         --
         update_pay_costs (v_cost_allocation_keyflex_id,
                           v_new_allocation_keyflex_id,
                           v_cost_id
                          );
         --
         v_insert := 0;
      --
      END IF;

      v_cost_allocation_keyflex_id := NULL;
      v_new_allocation_keyflex_id := NULL;
      v_person_id := NULL;
      v_bal_location := NULL;
      v_bal_client := NULL;
      v_bal_department := NULL;
      v_bal_account := NULL;
      v_bal_future1 := NULL;
      v_bal_future2 := NULL;
      v_bal_id_flex_num := NULL;
      v_bal_summary_flag := NULL;
      v_bal_enabled_flag := NULL;
      v_business_group := NULL;
      v_cost_id := NULL;
      v_employee_number := NULL;
      v_pre_payment_id := NULL;
      v_assignment_action_id := NULL;
      v_keyflex_record := NULL;
      v_location_dff := NULL;
      v_payment_method_name := NULL;
      v_element_name := NULL;
      v_job_account := NULL;
   END LOOP;

   apps.fnd_file.put_line (2, 'Ending Offset Level Loop');

   CLOSE get_offset_level;

   apps.fnd_file.put_line (2, 'End Custom Costing program');
EXCEPTION
   WHEN OTHERS
   THEN
    --cust.ttec_process_error (c_application_code,  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
     apps.ttec_process_error (c_application_code, --code added by MXKEERTHI-ARGANO, 05/19/2023
                              c_interface,
                               c_program_name,
                               l_module_name,
                               c_failure_status,
                               SQLCODE,
                               SQLERRM,
                               l_label1,
                               l_label1
                              );
      RAISE;
END;
/
show errors;
/