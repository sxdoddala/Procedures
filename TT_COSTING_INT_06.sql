create or replace PROCEDURE Tt_Costing_Int_06 (
/************************************************************************************
        Program Name: Tt_Costing_Int_06 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    MXKEERTHI(ARGANO)            1.0      29-JUN-2023      R12.2 Upgrade Remediation
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
--
-- Added changes for 2006. This code needs to go into a new Concurrent Manager
--
  -- Variables used by Common Error Procedure

	  
	  	  --START R12.2 Upgrade Remediation
	  /*
		Commented code by MXKEERTHI-ARGANO, 29/06/2023
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
   skip_record                      EXCEPTION;
   g_payroll                        NUMBER                    := p_payroll_id;
   g_consolidation_set              NUMBER          := p_consolidation_set_id;
   g_start_date                     DATE                       := p_date_from;
   g_end_date                       DATE                         := p_date_to;
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

   -- RECORD DECLARATION --
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

   v_keyflex_record                 keyflex_record;
   l_module_name                    cust.ttec_error_handling.module_name%TYPE
                                                                     := 'MAIN';
   l_label1                         cust.ttec_error_handling.label1%TYPE
                                                                     := 'MAIN';
   l_error_message                  cust.ttec_error_handling.error_message%TYPE;

	   */
	  --code Added  by MXKEERTHI-ARGANO, 29/06/2023
   c_application_code               APPS.ttec_error_handling.application_code%TYPE
                                                                      := 'HR';
   c_interface                      APPS.ttec_error_handling.INTERFACE%TYPE
                                                              := 'HR-CUST-01';
   c_program_name                   APPS.ttec_error_handling.program_name%TYPE
                                                     := 'custom_payroll_cost';
   c_initial_status                 APPS.ttec_error_handling.status%TYPE
                                                                 := 'INITIAL';
   c_warning_status                 APPS.ttec_error_handling.status%TYPE
                                                                 := 'WARNING';
   c_failure_status                 APPS.ttec_error_handling.status%TYPE
                                                                 := 'FAILURE';
   skip_record                      EXCEPTION;
   g_payroll                        NUMBER                    := p_payroll_id;
   g_consolidation_set              NUMBER          := p_consolidation_set_id;
   g_start_date                     DATE                       := p_date_from;
   g_end_date                       DATE                         := p_date_to;
   v_cost_allocation_keyflex_id     APPS.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
                                                                      := NULL;
   v_new_allocation_keyflex_id      APPS.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
                                                                      := NULL;
   v_offset_allocation_keyflex_id   APPS.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
                                                                      := NULL;
   v_person_id                      APPS.per_all_people_f.person_id%TYPE
                                                                      := NULL;
   v_assignment_id                  APPS.per_all_assignments_f.assignment_id%TYPE
                                                                      := NULL;
   v_employee_number                APPS.per_all_people_f.employee_number%TYPE
                                                                      := NULL;
   v_business_group                 APPS.per_all_assignments_f.business_group_id%TYPE
                                                                      := NULL;
   v_cost_id                        APPS.pay_costs.cost_id%TYPE         := NULL;
   v_cost_location                  APPS.pay_cost_allocation_keyflex.segment1%TYPE
                                                                      := NULL;
   v_cost_client                    APPS.pay_cost_allocation_keyflex.segment2%TYPE
                                                                      := NULL;
   v_cost_department                APPS.pay_cost_allocation_keyflex.segment3%TYPE
                                                                      := NULL;
   v_cost_account                   APPS.pay_cost_allocation_keyflex.segment4%TYPE
                                                                      := NULL;
   v_job_account                    APPS.pay_cost_allocation_keyflex.segment4%TYPE
                                                                      := NULL;
   v_cost_future1                   APPS.pay_cost_allocation_keyflex.segment5%TYPE
                                                                      := NULL;
   v_cost_future2                   APPS.pay_cost_allocation_keyflex.segment6%TYPE
                                                                      := NULL;
   v_cost_id_flex_num               APPS.pay_cost_allocation_keyflex.id_flex_num%TYPE
                                                                      := NULL;
   v_cost_summary_flag              APPS.pay_cost_allocation_keyflex.summary_flag%TYPE
                                                                      := NULL;
   v_cost_enabled_flag              APPS.pay_cost_allocation_keyflex.enabled_flag%TYPE
                                                                      := NULL;
   v_cost_run_result_id             NUMBER;
   v_cost_dist_run_result_id        NUMBER;
   v_element_name                   APPS.pay_element_types_f.element_name%TYPE;
   v_bal_location                   APPS.pay_cost_allocation_keyflex.segment1%TYPE
                                                                      := NULL;
   v_bal_client                     APPS.pay_cost_allocation_keyflex.segment2%TYPE
                                                                      := NULL;
   v_bal_department                 APPS.pay_cost_allocation_keyflex.segment3%TYPE
                                                                      := NULL;
   v_bal_account                    APPS.pay_cost_allocation_keyflex.segment4%TYPE
                                                                      := NULL;
   v_bal_future1                    APPS.pay_cost_allocation_keyflex.segment5%TYPE
                                                                      := NULL;
   v_bal_future2                    APPS.pay_cost_allocation_keyflex.segment6%TYPE
                                                                      := NULL;
   v_bal_id_flex_num                APPS.pay_cost_allocation_keyflex.id_flex_num%TYPE
                                                                      := NULL;
   v_bal_summary_flag               APPS.pay_cost_allocation_keyflex.summary_flag%TYPE
                                                                      := NULL;
   v_bal_enabled_flag               APPS.pay_cost_allocation_keyflex.enabled_flag%TYPE
                                                                      := NULL;
   v_bal_run_result_id              NUMBER;
   v_bal_dist_run_result_id         NUMBER;
   v_pre_payment_id                 APPS.pay_assignment_actions.pre_payment_id%TYPE
                                                                      := NULL;
   v_assignment_action_id           APPS.pay_assignment_actions.assignment_action_id%TYPE
                                                                      := NULL;
   v_payment_method_name            APPS.pay_org_payment_methods_f.org_payment_method_name%TYPE
                                                                      := NULL;
   v_counter                        NUMBER                               := 0;
   v_insert                         NUMBER                               := 0;
   v_location_dff                   APPS.pay_cost_allocation_keyflex.segment1%TYPE
                                                                      := NULL;

   -- RECORD DECLARATION --
   TYPE keyflex_record IS RECORD (
      cost_allocation_keyflex_id   APPS.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      concatenated_segments        APPS.pay_cost_allocation_keyflex.concatenated_segments%TYPE,
      id_flex_num                  APPS.pay_cost_allocation_keyflex.id_flex_num%TYPE,
      summary_flag                 APPS.pay_cost_allocation_keyflex.summary_flag%TYPE,
      enabled_flag                 APPS.pay_cost_allocation_keyflex.enabled_flag%TYPE,
      segment1                     APPS.pay_cost_allocation_keyflex.segment1%TYPE,
      segment2                     APPS.pay_cost_allocation_keyflex.segment2%TYPE,
      segment3                     APPS.pay_cost_allocation_keyflex.segment3%TYPE,
      segment4                     APPS.pay_cost_allocation_keyflex.segment4%TYPE,
      segment5                     APPS.pay_cost_allocation_keyflex.segment5%TYPE,
      segment6                     APPS.pay_cost_allocation_keyflex.segment6%TYPE
   );

   v_keyflex_record                 keyflex_record;
   l_module_name                    APPS.ttec_error_handling.module_name%TYPE
                                                                     := 'MAIN';
   l_label1                         APPS.ttec_error_handling.label1%TYPE
                                                                     := 'MAIN';
   l_error_message                  APPS.ttec_error_handling.error_message%TYPE;

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
		Commented code by MXKEERTHI-ARGANO, 29/06/2023
         FROM hr.pay_cost_allocation_keyflex pcak,
             hr.pay_costs pc,
             hr.pay_assignment_actions paa,
             hr.pay_payroll_actions ppa
	   */
	  --code Added  by MXKEERTHI-ARGANO, 29/06/2023
        FROM APPS.pay_cost_allocation_keyflex pcak,
             APPS.pay_costs pc,
             APPS.pay_assignment_actions paa,
             APPS.pay_payroll_actions ppa
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
		Commented code by MXKEERTHI-ARGANO, 29/06/2023
         FROM hr.pay_cost_allocation_keyflex pcak,
             hr.pay_costs pc,
             hr.pay_assignment_actions paa,
             hr.pay_payroll_actions ppa
	   */
	  --code Added  by MXKEERTHI-ARGANO, 29/06/2023
        FROM APPS.pay_cost_allocation_keyflex pcak,
             APPS.pay_costs pc,
             APPS.pay_assignment_actions paa,
             APPS.pay_payroll_actions ppa
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
      		--     l_assignment_id   IN       hr.per_all_assignments_f.assignment_id%TYPE, -- Commented code by SXDODDALA-ARGANO, 06/29/2023
     l_assignment_id   IN       APPS.per_all_assignments_f.assignment_id%TYPE,--  code Added by SXDODDALA-ARGANO, 06/29/2023

 
      l_end_date        IN       DATE,
      l_location_dff    OUT      HR_LOCATIONS.attribute2%TYPE
   )
   IS
   	  --START R12.2 Upgrade Remediation
	  /*
		Commented code by MXKEERTHI-ARGANO, 29/06/2023
       l_module_name     cust.ttec_error_handling.module_name%TYPE
                                                        := 'GET_LOCATION_DFF';
      l_label1          cust.ttec_error_handling.label1%TYPE
                                                         := 'v_assignment_id';
      l_error_message   cust.ttec_error_handling.error_message%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 29/06/2023
      l_module_name     APPS.ttec_error_handling.module_name%TYPE
                                                        := 'GET_LOCATION_DFF';
      l_label1          APPS.ttec_error_handling.label1%TYPE
                                                         := 'v_assignment_id';
      l_error_message   APPS.ttec_error_handling.error_message%TYPE;
	  --END R12.2.10 Upgrade remediation

   BEGIN
      SELECT hl.attribute2
        INTO l_location_dff
				--FROM hr.per_all_assignments_f paaf, HR_LOCATIONS hl-- Commented code by SXDODDALA-ARGANO, 06/29/2023
        FROM APPS.per_all_assignments_f paaf, HR_LOCATIONS hl--  code Added by SXDODDALA-ARGANO, 06/29/2023


       WHERE TRUNC (l_end_date) BETWEEN TRUNC (paaf.effective_start_date)
                                    AND TRUNC (paaf.effective_end_date)
         AND paaf.location_id = hl.location_id
         AND paaf.assignment_id = l_assignment_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_location_dff := NULL;
      WHEN OTHERS
      THEN
	  		-- cust.ttec_process_error (c_application_code, -- Commented code by SXDODDALA-ARGANO, 06/29/2023
         APPS.ttec_process_error (c_application_code,--  code Added by SXDODDALA-ARGANO, 06/29/2023
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
   IS
   	  --START R12.2 Upgrade Remediation
	  /*
		Commented code by MXKEERTHI-ARGANO, 29/06/2023
      l_module_name   cust.ttec_error_handling.module_name%TYPE;
      l_label1        cust.ttec_error_handling.label1%TYPE;
      l_reference1    cust.ttec_error_handling.reference1%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 29/06/2023
      l_module_name   APPS.ttec_error_handling.module_name%TYPE;
      l_label1        APPS.ttec_error_handling.label1%TYPE;
      l_reference1    APPS.ttec_error_handling.reference1%TYPE;
	  --END R12.2.10 Upgrade remediation

   BEGIN
      IF p_distributed_run_result_id IS NOT NULL
      THEN
         SELECT et.element_name
           INTO p_element_name
		   		--  FROM hr.pay_run_results rr, apps.pay_element_types_f et -- Commented code by SXDODDALA-ARGANO, 06/29/2023
           FROM APPS.pay_run_results rr, apps.pay_element_types_f et--  code Added by SXDODDALA-ARGANO, 06/29/2023


          WHERE TRUNC (SYSDATE) BETWEEN et.effective_start_date
                                    AND et.effective_end_date
            AND rr.run_result_id = p_distributed_run_result_id
            AND rr.element_type_id = et.element_type_id;
      ELSE
         SELECT et.element_name
           INTO p_element_name
		   		--  FROM hr.pay_run_results rr, apps.pay_element_types_f et  -- Commented code by SXDODDALA-ARGANO, 06/29/2023
           FROM APPS.pay_run_results rr, apps.pay_element_types_f et--  code Added by SXDODDALA-ARGANO, 06/29/2023


          WHERE TRUNC (SYSDATE) BETWEEN et.effective_start_date
                                    AND et.effective_end_date
            AND rr.run_result_id = p_run_result_id
            AND rr.element_type_id = et.element_type_id;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_module_name := 'GET ELEMENT';
         l_label1 := 'run_result_id';
         l_reference1 := NVL (p_distributed_run_result_id, p_run_result_id);
         cust.ttec_process_error (c_application_code,
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
   IS
   	  --START R12.2 Upgrade Remediation
	  /*
		Commented code by MXKEERTHI-ARGANO, 29/06/2023
       l_module_name   cust.ttec_error_handling.module_name%TYPE;
      l_label1        cust.ttec_error_handling.label1%TYPE;
      l_reference1    cust.ttec_error_handling.reference1%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 29/06/2023
      l_module_name   APPS.ttec_error_handling.module_name%TYPE;
      l_label1        APPS.ttec_error_handling.label1%TYPE;
      l_reference1    APPS.ttec_error_handling.reference1%TYPE;
	  --END R12.2.10 Upgrade remediation

   BEGIN
      SELECT pj.attribute7                                       --Account DFF
        INTO p_account
				--FROM hr.per_all_assignments_f paaf, hr.per_jobs pj -- Commented code by SXDODDALA-ARGANO, 06/29/2023
        FROM APPS.per_all_assignments_f paaf, APPS.per_jobs pj--  code Added by SXDODDALA-ARGANO, 06/29/2023
      WHERE paaf.assignment_id = p_assignment_id
         AND p_effective_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
         AND paaf.job_id = pj.job_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_module_name := 'GET JOB ACCOUNT';
         l_label1 := 'assignment_id';
         l_reference1 := p_assignment_id;
         p_account := NULL;
		 		--cust.ttec_process_error (c_application_code, -- Commented code by SXDODDALA-ARGANO, 06/29/2023
         APPS.ttec_process_error (c_application_code,--  code Added by SXDODDALA-ARGANO, 06/29/2023
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
   END;                                           -- PROCEDURE GET_JOB_ACCOUNT

--////////////////////////////////////////////////////////////////////////////////////////////////////////

   -- THIS PROCEDURE INSERTS AN ENTIRE NEW LINE IN THE PAY_COST_ALLOCATION_KEYFLEX TABLE INCLUDING THE COMPANY
-- AND TRADER FIELDS.  THIS IS NECESSARY SINCE THE COST_ALLOCATION_KEYFLEX_ID AT THE BALANCE(OR OFFSET) LEVEL
-- IS THE SAME COST_ALLOCATION_KEYFLEX_ID USED FOR THE DEFAULT ELEMENT ENTRY VALUE.
   PROCEDURE insert_keyflex_record (
      l_keyflex_record              IN       keyflex_record,
	  		--l_business_group              IN       hr.per_all_assignments_f.business_group_id%TYPE,  -- Commented code by SXDODDALA-ARGANO, 06/29/2023
      l_business_group              IN       APPS.per_all_assignments_f.business_group_id%TYPE,--  code Added by SXDODDALA-ARGANO, 06/29/2023
     p_new_allocation_keyflex_id   OUT      NUMBER
   )
   IS
      l_costflex_id     NUMBER          := NULL;
	  --START R12.2 Upgrade Remediation
	  /*
		Commented code by MXKEERTHI-ARGANO, 29/06/2023
      l_concatenated    hr.pay_cost_allocation_keyflex.concatenated_segments%TYPE
                                                                      := NULL;
      l_module_name     cust.ttec_error_handling.module_name%TYPE
                                                          := 'INSERT_KEYFLEX';
      l_label1          cust.ttec_error_handling.label1%TYPE
                                                          := 'keyflex_record';
      l_error_message   cust.ttec_error_handling.error_message%TYPE;
	   */
	  --code Added  by MXKEERTHI-ARGANO, 29/06/2023
      l_concatenated    APPS.pay_cost_allocation_keyflex.concatenated_segments%TYPE
                                                                      := NULL;
      l_module_name     APPS.ttec_error_handling.module_name%TYPE
                                                          := 'INSERT_KEYFLEX';
      l_label1          APPS.ttec_error_handling.label1%TYPE
                                                          := 'keyflex_record';
      l_error_message   APPS.ttec_error_handling.error_message%TYPE;
	  --END R12.2.10 Upgrade remediation	  := NULL;

   BEGIN
      l_costflex_id :=
         apps.Pay_Csk_Flex.get_cost_allocation_id
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

      UPDATE apps.pay_cost_allocation_keyflex
         SET concatenated_segments = l_concatenated
       WHERE cost_allocation_keyflex_id = l_costflex_id;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
	  		-- cust.ttec_process_error (c_application_code, -- Commented code by SXDODDALA-ARGANO, 06/29/2023
		         APPS.ttec_process_error (c_application_code,--  code Added by SXDODDALA-ARGANO, 06/29/2023
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
   PROCEDURE update_pay_costs (
   	  --START R12.2 Upgrade Remediation
	  /*
		Commented code by MXKEERTHI-ARGANO, 29/06/2023
       l_cost_allocation_keyflex_id   IN   hr.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      l_new_allocation_keyflex_id    IN   hr.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      l_cost_id                      IN   hr.pay_costs.cost_id%TYPE
	   */
	  --code Added  by MXKEERTHI-ARGANO, 29/06/2023
      l_cost_allocation_keyflex_id   IN   APPS.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      l_new_allocation_keyflex_id    IN   APPS.pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
      l_cost_id                      IN   APPS.pay_costs.cost_id%TYPE
	  --END R12.2.10 Upgrade remediation

   )
   IS
   BEGIN
   		--UPDATE hr.pay_costs-- Commented code by SXDODDALA-ARGANO, 06/29/2023
      UPDATE APPS.pay_costs--  code Added by SXDODDALA-ARGANO, 06/29/2023
        SET cost_allocation_keyflex_id = l_new_allocation_keyflex_id
       WHERE
             --COST_ALLOCATION_KEYFLEX_ID = l_cost_allocation_keyflex_id
              --AND
             cost_id = l_cost_id;

      COMMIT;
   END;
--///////////////////////////////////////////////////////////////////////*/
BEGIN
   apps.Fnd_File.put_line (2, 'Starting Custom Costing program');
   v_keyflex_record := NULL;
   g_consolidation_set := TO_NUMBER (g_consolidation_set);
   g_payroll := TO_NUMBER (g_payroll);

   OPEN get_cost_level;

   apps.Fnd_File.put_line (2, 'Starting Cost Level Loop');

   LOOP
      BEGIN
         FETCH get_cost_level
          INTO v_cost_allocation_keyflex_id, v_business_group,
               v_assignment_id, v_cost_id, v_cost_location, v_cost_client,
               v_cost_department, v_cost_account, v_cost_future1,
               v_cost_future2, v_cost_id_flex_num, v_cost_summary_flag,
               v_cost_enabled_flag, v_cost_run_result_id,
               v_cost_dist_run_result_id;

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
      IF v_cost_location IS NULL
      THEN
         get_location_dff (v_assignment_id, g_end_date, v_location_dff);
         v_keyflex_record.segment1 := v_location_dff;
         v_insert := 1;
      END IF;

      -- CANADA
      IF v_business_group = 326
      THEN
         IF    v_cost_account IN ('1032', '2915', '8100')
            OR (SUBSTR (v_cost_account, 1, 2) IN ('22', '24'))
         THEN
            IF v_cost_account NOT IN ('2204', '2470', '2471')
            THEN
               v_keyflex_record.segment1 := '05300';
               v_insert := 1;
            END IF;
         END IF;




         -- CA -  Newgen   ikonak 04/24/2003
         IF g_payroll IN (62, 139)
         THEN                                                 -- Newgen Canada
            v_keyflex_record.segment1 := '05150';
            v_insert := 1;
         END IF;



         -- Wasim changed costing account for 1031 to 1032
         IF g_payroll IN (62, 138, 139)
         THEN                                                 -- Newgen Cana\

            IF v_cost_account = '1031'
            THEN

               v_keyflex_record.segment4 := '1032';

               v_insert := 1;
            END IF;
         END IF;
      END IF;



      -- USA
      IF v_business_group = 325
      THEN
         -- Percepta Payroll
         IF g_payroll = 46
         THEN
            IF v_cost_account IN ('2915', '2415', '2440', '8100', '1032')
            THEN
               v_keyflex_record.segment1 := '11012';
               v_insert := 1;
            END IF;
		 ELSIF g_payroll = 280  THEN --DAC
		       IF v_cost_account IN ('2915','2415','2425','2426','2430','2410','1032')  THEN
         		   v_keyflex_record.segment1 := '01900';
				   v_insert := 1;
			   END IF;
         ELSE
         -- All other US Payrolls
         -- 12/16/2003  WO# 53160
            IF    v_cost_account IN
                            ('1032', '2915', '2415', '2425', '2426', '2430')
               OR (SUBSTR (v_cost_account, 1, 2) = '22')
            THEN
               v_keyflex_record.segment1 := '01002';
               v_insert := 1;
            END IF;

            IF v_cost_account IN ('2440', '8100')
            THEN
               v_keyflex_record.segment1 := '01001';
               v_insert := 1;
            END IF;
         END IF;

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
      END IF;

      -- Analyze Segment2 - Client
      IF    (v_cost_account = '8100')
         OR (v_cost_account >= 1000 AND v_cost_account <= 2999)
      THEN
         v_keyflex_record.segment2 := '0000';
         v_insert := 1;
      END IF;

      -- Analyze Segment3 - Department
      IF    (v_cost_account = '8100')
         OR (v_cost_account >= 1000 AND v_cost_account <= 2999)
      THEN
         v_keyflex_record.segment3 := '000';
         v_insert := 1;
      END IF;

      IF (v_cost_account = '5025') AND (v_business_group = 325)
      THEN
         v_keyflex_record.segment3 := '030';
         v_insert := 1;
      END IF;

      -- Analyze Segment4 - Account
      get_element (v_cost_run_result_id,
                   v_cost_dist_run_result_id,
                   v_element_name
                  );

      IF v_business_group = 325
      THEN
	     IF g_payroll =  280  THEN   --DAC  Payroll
		    IF v_element_name IN
               ('AOM Pay',
			    'AOM Trip Pay',
				'Bereavement Pay',
				'Bonus_Spot Pay',
				'Overtime Premium Pay',
				'Salary Non Exempt Straight',
				'Jury Pay',
				'Hourly Overtime 1',
				'Salary Pay',
				'Prior Month Commission Pay',
				'Referral Pay',
				'Holiday Pay',
				'Fitness Reimbursement Pay',
				'Retroactive Pay',
				'Language Skill Differential Pay',
				'Severance Pay',
				'Prior Month Leasing Commission Pay',
				'Military Leave Pay',
				'Other_Reg_Flat Pay',
				'Prize Non_Cash Pay',
				'Time Entry Wages Pay',
				'Shift Differential % Pay',
				'Prior Month SPIFF',
				'Relo_Bonus Pay',
				'PTO Pay',
				'PTO Payout Pay' ) THEN
				 get_job_account (v_assignment_id, SYSDATE, v_job_account);

             IF v_job_account IS NOT NULL
              THEN
               IF v_keyflex_record.segment4 IS NOT NULL
               THEN
                  IF v_job_account <> v_keyflex_record.segment4
                  THEN
                     v_keyflex_record.segment4 := v_job_account;
                     v_insert := 1;
                  END IF;
               ELSE
                  v_keyflex_record.segment4 := v_job_account;
                  v_insert := 1;
               END IF;
             END IF;
           END IF; --DAC elements

		 END IF;  --DAC payroll

         IF v_element_name IN
               ('Bereavement Pay',
                'Coaching',
                'Earnings Adjust',
                'Earnings Adjustment',
                'Jury Duty',
                'Other_Reg_Flat',
                'Other_Reg',
                'Other_Supp_Flat',
                'Other_Supp',
                'Personal Holiday Taken',
                'Regular Hours',
                'Retroactive Pay',
                'Severance_Flat',
                'Severance',
                'Training Assistant',
                'TT Time Entry Wages',
                'US Regular Salary',
                'Wage after Death_CYr_Flat',
                'Wages after Death_CYr',
                'Wage after Death_FYr_Flat',
                'Wages after Death_FYr',

                -- Wasim M added those Oct 12 2005
                'PTO Special Features',
                'Sick Bank Special Features',
                'Unpaid Absence Special Features',
                'Bereavement Special Features',
                'Holiday Pay Special Features',
                'Jury Special Features',
                'Home Leave Special Features'
               )
         THEN
            get_job_account (v_assignment_id, SYSDATE, v_job_account);

            IF v_job_account IS NOT NULL
            THEN
               IF v_keyflex_record.segment4 IS NOT NULL
               THEN
                  IF v_job_account <> v_keyflex_record.segment4
                  THEN
                     v_keyflex_record.segment4 := v_job_account;
                     v_insert := 1;
                  END IF;
               ELSE
                  v_keyflex_record.segment4 := v_job_account;
                  v_insert := 1;
               END IF;
            END IF;
         END IF;

         -- ikonak 07/02/03
         IF v_keyflex_record.segment4 = '1032'
         THEN
            v_keyflex_record.segment4 := '1038';
            v_insert := 1;
         END IF;
      ELSIF v_business_group = 326
      THEN
         IF v_element_name IN
               ('Bereavement Pay',
                'CND Regular Salary',
                'Jury Duty',
                'Lieu of Notice Pay',
                'Lieu of Notice Flat',
                'Lieu Day',
                'Regular Hours',
                'Regular Wages',
                'Retiring Allowance',
                'Retro Hourly',
                'Severance',
                'TT Time Entry Wages'
               )
         THEN
            get_job_account (v_assignment_id, SYSDATE, v_job_account);

            IF v_job_account IS NOT NULL
            THEN
            -- Wasim addded code to NOT overwrite segment4

    IF (v_keyflex_record.segment4 != '1032') THEN

               IF (v_keyflex_record.segment4 IS NOT NULL)
               THEN
                   IF v_job_account <> v_keyflex_record.segment4
                   THEN
                     v_keyflex_record.segment4 := v_job_account;
                     v_insert := 1;

                   END IF;
               ELSE
                  v_keyflex_record.segment4 := v_job_account;
                  v_insert := 1;
               END IF;
     END IF;
            END IF;
         END IF;
      END IF;

      --  For all business groups
      IF     (v_keyflex_record.segment2 = '0000')
         AND (SUBSTR (v_keyflex_record.segment4, 1, 1) = '5')
      THEN
         v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
         v_insert := 1;
      END IF;

      IF v_business_group IN (325, 326)
      THEN                             --  for US and CA
         --   change to 7
         IF SUBSTR (v_keyflex_record.segment4, 1, 1) = '5'
         THEN              --   change to 7
            IF     v_keyflex_record.segment3 IN
                      ('000',
                       '001',
                       '020',
                       '096',
                       '097',
                       '090',
                       '035',
                       '057',
                       '025',
                       '026',
                       '027',
                       '028',
                       '029',
                       '045',
                       '085',
                       '015'
                      )
               AND v_keyflex_record.segment1 IN
                      ('01002',
                       '01050',
					   '01900',  --DAC
                       '01001',
                       '01003',
                       '01010',
                       '01011',
                       '01015',
                       '01020',
                       '01049',
                       '01051',
                       '01059',
                       '01066',
                       '01068',
                       '01069',
                       '01070',
                       '01098',
                       '01110',
                       '01111',
                       '01115',
                       '01117',
                       '01122',
                       '01202',
                       '01249',
                       '01251',
                       '01252',
                       '01253',
                       '01254',
                       '01300',
                       '01310',
                       '01350',
                       '01351',
                       '01352',
                       '01353',
                       '01600',
                       '01650',
                       '01680',
                       '01271'
                      )
            THEN
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            ELSIF     v_keyflex_record.segment3 IN
                         ('014',
                          '019',
                          '021',
                          '080',
                          '095',
                          '041',
                          '016',
                          '051',
                          '060',
                          '091',
                          '040',
                          '050',
                          '055',
                          '058',
                          '075',
                          '070',
                          '022',
                          '024'
                         )
                  AND v_keyflex_record.segment1 IN ('01002','01050','01900'/* DAC */)
            THEN
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            ELSIF     v_keyflex_record.segment3 IN ('017', '018')
                  AND v_keyflex_record.segment1 IN ('01002','01900'/* DAC */)
            THEN
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            ELSIF     v_keyflex_record.segment3 = '024'
                  AND v_keyflex_record.segment1 IN
                         ('01001',
                          '01003',
                          '01010',
                          '01011',
                          '01015',
                          '01020',
                          '01049',
                          '01051',
                          '01059',
                          '01066',
                          '01068',
                          '01069',
                          '01070',
                          '01098',
                          '01110',
                          '01111',
                          '01115',
                          '01117',
                          '01122',
                          '01202',
                          '01249',
                          '01251',
                          '01252',
                          '01253',
                          '01254',
                          '01300',
                          '01310',
                          '01350',
                          '01351',
                          '01352',
                          '01353',
                          '01600',
                          '01650',
                          '01680',
                          '01271',
						  '01900'/* DAC */
                         )
            THEN
               v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            END IF;
         END IF;                                          ---  change to 7 end

         --   change to 5
         IF SUBSTR (v_keyflex_record.segment4, 1, 1) = '7'
         THEN                                                 --   change to 5
            IF     v_keyflex_record.segment3 IN
                      ('060', '091', '040', '050', '055', '058', '075',
                       '070')
               AND v_keyflex_record.segment1 IN
                      ('01001',
                       '01003',
                       '01010',
                       '01011',
                       '01015',
                       '01020',
                       '01049',
                       '01051',
                       '01059',
                       '01066',
                       '01068',
                       '01069',
                       '01070',
                       '01098',
                       '01110',
                       '01111',
                       '01115',
                       '01117',
                       '01122',
                       '01202',
                       '01249',
                       '01251',
                       '01252',
                       '01253',
                       '01254',
                       '01300',
                       '01310',
                       '01350',
                       '01351',
                       '01352',
                       '01353',
                       '01600',
                       '01650',
                       '01680',
                       '01271'
                      )
            THEN
               v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            ELSIF     v_keyflex_record.segment3 IN
                         ('005',
                          '006',
                          '007',
                          '008',
                          '010',
                          '012',
                          '030',
                          '056',
                          '065',
                          '066'
                         )
                  AND v_keyflex_record.segment1 IN
                         ('01050',
						  '01900', /* DAC */
                          '01001',
                          '01003',
                          '01010',
                          '01011',
                          '01015',
                          '01020',
                          '01049',
                          '01051',
                          '01059',
                          '01066',
                          '01068',
                          '01069',
                          '01070',
                          '01098',
                          '01110',
                          '01111',
                          '01115',
                          '01117',
                          '01122',
                          '01202',
                          '01249',
                          '01251',
                          '01252',
                          '01253',
                          '01254',
                          '01300',
                          '01310',
                          '01350',
                          '01351',
                          '01352',
                          '01353',
                          '01600',
                          '01650',
                          '01680',
                          '01271'
                         )
            THEN
               v_keyflex_record.segment4 :=
                                 '5' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            END IF;
         END IF;                                          --   change to 5 end

		 -- WASIM WO 181382  CHANGE CANADA ACCOUNTS 5XXX TO 7XXXX FOR DEPT 015 AND 035
         IF (v_business_group  = 326)  AND ( v_keyflex_record.segment3 IN ('015', '035') )
         THEN

             IF SUBSTR (v_keyflex_record.segment4, 1, 1) = '5'
         		 THEN                                                --   change to 7
                 v_keyflex_record.segment4 :=
                                 '7' || SUBSTR (v_keyflex_record.segment4, 2);
               v_insert := 1;
            END IF;
          END IF;          -- END WO 181382
      END IF;                                      --  business group 325, 326

      --  Validate and Update the new combination
      IF v_insert = 1
      THEN
         insert_keyflex_record (v_keyflex_record,
                                v_business_group,
                                v_new_allocation_keyflex_id
                               );
         update_pay_costs (v_cost_allocation_keyflex_id,
                           v_new_allocation_keyflex_id,
                           v_cost_id
                          );
         v_insert := 0;
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

   apps.Fnd_File.put_line (2, 'Ending Cost Level Loop');

   CLOSE get_cost_level;

   -- =============    OFFSET ACCOUNT SECTION   =================
   OPEN get_offset_level;

   apps.Fnd_File.put_line (2, 'Starting Offset Level Loop');

   LOOP
      BEGIN
         FETCH get_offset_level
          INTO v_cost_allocation_keyflex_id, v_business_group,
               v_assignment_id, v_bal_location, v_bal_client,
               v_bal_department, v_bal_account, v_bal_future1, v_bal_future2,
               v_bal_id_flex_num, v_bal_summary_flag, v_bal_enabled_flag,
               v_cost_id, v_pre_payment_id, v_assignment_action_id,
               v_bal_run_result_id, v_bal_dist_run_result_id;

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
   -- wasim added processing for payroll 139 138 and change of 1031 account to 1032 - Jan 2006
      IF v_business_group = 326 AND g_payroll IN (62, 139)
      THEN                                                    -- Newgen Canada
         v_keyflex_record.segment1 := '05150';
         v_insert := 1;
      END IF;
   IF v_business_group = 326
   THEN

        IF g_payroll IN (62, 138, 139)
           THEN                                                 -- Newgen Canada

             IF v_bal_account = '1031'
             THEN

                 v_keyflex_record.segment4 := '1032';

                 v_insert := 1;
              END IF;
          END IF;
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
		 ELSIF g_payroll = 280  THEN --DAC
		       IF v_bal_location IS NULL  THEN
         		   v_keyflex_record.segment1 := '01900';
				   v_insert := 1;
			   END IF;
         ELSE
            -- Rest of US
            -- 12/16/2003   WO# 53160
            IF v_keyflex_record.segment4 IN
                  ('2210',
                   '2220',
                   '2230',
                   '2240',
                   '2250',
                   '2260',
                   '2270',
                   '2280',
                   '2290',
                   '2425',
                   '2426',
                   '2430'
                  )
            THEN
               v_keyflex_record.segment1 := '01002';
               v_insert := 1;
            END IF;
         END IF;   --Payroll

         --  ikonak 020505
         --  Change location for US Newgen emloyees to 01220
         IF g_payroll = 85
         THEN    --  NEWGEN US
            IF v_keyflex_record.segment1 <> '01220'
            THEN
               v_keyflex_record.segment1 := '01220';
               v_insert := 1;
            END IF;
         END IF;
      END IF;

      --US

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

      IF v_insert = 1
      THEN
         insert_keyflex_record (v_keyflex_record,
                                v_business_group,
                                v_new_allocation_keyflex_id
                               );
         update_pay_costs (v_cost_allocation_keyflex_id,
                           v_new_allocation_keyflex_id,
                           v_cost_id
                          );
         v_insert := 0;
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

   apps.Fnd_File.put_line (2, 'Ending Offset Level Loop');

   CLOSE get_offset_level;

   apps.Fnd_File.put_line (2, 'End Custom Costing program');
EXCEPTION
   WHEN OTHERS
   THEN
   		--      cust.ttec_process_error (c_application_code, -- Commented code by SXDODDALA-ARGANO, 06/29/2023
      APPS.ttec_process_error (c_application_code,--  code Added by SXDODDALA-ARGANO, 06/29/2023
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