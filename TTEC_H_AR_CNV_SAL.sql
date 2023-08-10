create or replace PROCEDURE      ttec_h_ar_cnv_sal AS
 -- ---------------------------------------------------------------------
 -- ---------------------------------------------------------------------
 -- Author: IT-Convergence - Steven Hogan
 -- Creation Date	: November 29, 2004
 -- Description: Program to create Teletech Salary
 -- Updated by		:  Arun Jayaraman
 -- Update Date		:  12/06/04
 -- Update Made		:  Country specific and validations
 --   Modification Log
--       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
 --   IXPRAVEEN(ARGANO)            1.0     19-May-2023     R12.2 Upgrade Remediation

 -- ---------------------------------------------------------------------
 -- -------------------------------------------------------------------------------------------------------
 -- -------------------------------------------------------------------------------------------------------
 -- API Varibles definitions varibles...
 -- ---------------------------------------------------------------------
           v_validate                                           BOOLEAN;
           v_assignment_id                                     	PER_ALL_ASSIGNMENTS_F.assignment_id%TYPE;
           v_business_group_id                         		NUMBER(15) ;
           v_change_date                                       	DATE;
           v_next_sal_review_date                      		DATE;
           l_proposal_reason                                   	VARCHAR2(30);
           l_proposed_salary_n                                 	NUMBER;
           v_forced_ranking                                    	NUMBER;
           v_performance_review_id                     		NUMBER(15);
           v_attribute_category                                 VARCHAR2(30);
           v_attribute1                                         VARCHAR2(150);
           v_attribute20                                        VARCHAR2(150);
           v_multiple_components                                VARCHAR2(1) := 'N';
           v_approved                                           VARCHAR2(30);
           v_pay_proposal_id                                    NUMBER(15);
           v_object_version_number                              NUMBER(9);
           v_element_entry_id                                   NUMBER(15);
           v_inv_next_sal_date_warning                          BOOLEAN;
           v_proposed_salary_warning                            BOOLEAN;
           v_approved_warning                                   BOOLEAN;
           v_payroll_warning                                    BOOLEAN;
	   v_err_count					        NUMBER:= 0;

           v_process_total_count                                NUMBER:= 0;   -- # of rows read from your cursor for loop
           v_process_success_count                              NUMBER:= 0;   -- # of rows successful on API call
           v_process_failed_count                               NUMBER:= 0;   -- # of rows failed on API call
           l_paf_cnt                                            NUMBER:= 0;
           l_pay_cnt                                            NUMBER:= 0;


           l_validate                                        BOOLEAN      := FALSE ;
           l_business_group_id                               NUMBER(15)   ;
           l_sal_change_reason                               VARCHAR2(30) ;
           l_proposal_reason_code                            VARCHAR2(30) ;
           l_multiple_components                             VARCHAR2(30) := 'N';
           l_effective_date                                  DATE := NULL;
     -- --------------------------------------------------------------------------
     --        Error logs, flags and counter varibles...
     -- --------------------------------------------------------------------------
               l_count_of_10                           number          := 0  ;
               l_emp_count                             number          := 0  ;
               l_error_count                           number          := 0  ;
               l_upd_sal_count                         number          := 0  ;
               l_sal_err_flag                          boolean         := FALSE ;
               l_error                                 boolean         := FALSE ;
       -- -------------------------------------------------------------------------
      --       Log file parameters varibles...
      -- -------------------------------------------------------------------------
               e_log_file                              VARCHAR2(30) ;
               e_log_file_name                         VARCHAR2(20) :='HR_SAL_AR_log_file_';
               v_message_str                           VARCHAR2(200);
               e_open_log_file                         Utl_File.FILE_TYPE;

               l_error_message                         VARCHAR2(80) := NULL;

          SYSTEM_USER_CONST CONSTANT                   VARCHAR2(40) := 'TELETECH';
          MODULE_NAME_CONST CONSTANT                   VARCHAR2(40) := 'EMPLOYEE SALARY PROPOSAL';
          DEFAULT_CHANGE_REASON                                        VARCHAR2(30);
          DEFAULT_FREQUENCY                                            VARCHAR2(30) := 'M';
          RECORD_COMMIT_INTERVAL CONSTANT              NUMBER 	    := 100;
          G_SYSDATE                                    DATE 	    := SYSDATE;
          v_debug_flag                                 BOOLEAN	    := TRUE; -- Debug on / Debug off = FALSE
          g_error_message                              VARCHAR2(2000);
       -- ----------------------------------------------------------------------------
      -- -----------------------------------------------------------------------------------------------------------
  -- ========================================================================
  -- Cursor to get Employee Salary Proposal
  -- ==================================================
  CURSOR cSal is
     SELECT
                sal_t.rowid
               ,emp_t.assignment_id
               ,emp_t.hire_date
               ,sal_t.emp_num_legacy
               ,sal_t.business_groupname
	       ,sal_t.proposal_reason
	       ,sal_t.forced_ranking
	       ,sal_t.next_sal_review_date
               ,emp_t.new_employee_number
               ,papf.employee_number
               ,emp_t.national_identifier
               ,emp_t.last_name
               ,emp_t.first_name
               ,sal_t.change_date
               ,sal_t.proposed_salary_n
               ,emp_t.person_id
               ,paaf.pay_basis_id
               ,paaf.payroll_id
               ,paaf.effective_start_date
FROM
				--START R12.2 Upgrade Remediation
				/*cust.ttec_h_ar_emp emp_t						-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
               ,cust.ttec_h_ar_asg asg_t
               ,cust.ttec_h_ar_sal sal_t
               ,hr.per_all_people_f papf
               ,hr.per_all_assignments_f paaf*/
			    apps.ttec_h_ar_emp emp_t						--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
               ,apps.ttec_h_ar_asg asg_t
               ,apps.ttec_h_ar_sal sal_t
               ,apps.per_all_people_f papf
               ,apps.per_all_assignments_f paaf
			   --END R12.2.12 Upgrade remediation
WHERE
               emp_t.emp_num_legacy = sal_t.emp_num_legacy
 AND           emp_t.emp_num_legacy = asg_t.emp_num_legacy
 AND           emp_t.status ='S'
 AND           asg_t.status ='S'
 AND           emp_t.new_employee_number is not null
 AND           (sal_t.status is null)
 AND           emp_t.person_id = papf.person_id
 AND           papf.person_id = paaf.person_id
 AND	      sal_t.proposed_salary_n is not null
		     order by emp_t.emp_num_legacy;

 --  -----------------------------------------------------------------------------------------------------
        BEGIN  -- process startup - initalization
     -- --------------------------------------------------------------------------------------------------
               --         Open Log file
               -- -----------------------------------------------
               e_open_log_file := ttec_conv_util.Open_Log_File(e_log_file_name);
               -- -----------------------------------------------
               -- ---------------------------------------------------------------------------------------------------
               -- ---------------------------------------------------------------------------------------------------
               -- Check to see if data has been loaded to emp temp
        /*       -- ------------------------------------------------------------
               BEGIN
                       SELECT  count(emp_t.assignment_id)
                       INTO l_emp_count
                       FROM cust.ttec_h_ar_emp emp_t, cust.ttec_h_ar_sal sal_t
                       WHERE emp_t.status = 'S'
                       AND emp_t.emp_num_legacy = sal_t.emp_num_legacy;
                       IF l_emp_count = 0 THEN
                                       l_error 	       := TRUE;
                                       l_error_message := ' - Please load data into temp tables with sqlloader';
                                       g_error_message := SQLERRM;
                                        apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                                        || ' - ' || g_error_message||' '||SYSTEM_USER_CONST);
                       END IF;
         END;
*/
                -- ---------------------------------------------------------
                -- ------------------------------------------------------------------------------------------------------------------------------
/*              -- ---------------------------------------------------------------------------------------------------------------------------------
               -- Get proposal_reason_code
               -- ---------------------------------
               SELECT           distinct (f.lookup_code)
               INTO            l_proposal_reason_code
               FROM            apps.fnd_lookup_values f
               WHERE           f.meaning = l_sal_change_reason
               AND             f.lookup_type='PROPOSAL_REASON'
               AND             f.enabled_flag='Y'
           --    AND             f.security_group_id=0;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                       l_sal_err_flag := TRUE ;
                       g_error_message := SQLERRM;
                                        l_error_message :=  'Message:Proposed Change Reason NOT FOUND!  ';
                               apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                                       ||' '||SYSTEM_USER_CONST);
*/
          -- -------------------------------------------------------------------------------------------------------------------------------

          -- --------------------------------------------------------------------------------------------------------------------------------------
    apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' Before starting LOOP ****'
                                       ||' '||SYSTEM_USER_CONST);
    -- --------------------------------------------------------------------------------------------------------------------------------------
    --         Validation process...
    -- --------------------------------------------------------------------------------------------------------------------------------------

 FOR xSal in cSal

LOOP
 apps.ttec_conv_util.Stampln(E_open_log_file, MODULE_NAME_CONST||' '||
 'Message:****** Processing legacy EMPLOYEE '
 || xSal.emp_num_legacy ||
 ' ********'||SYSTEM_USER_CONST);

		  v_object_version_number	:= null ;
                  v_element_entry_id 		:= null ;
		  v_pay_proposal_id		:= null ;
	--	  v_inv_next_sal_date_warning   := null ;
        --        v_proposed_salary_warning     := null ;
        --        v_approved_warning            := null ;
        --        v_payroll_warning             := null ;
		  v_err_count			:= 0 ;
                  l_paf_cnt                     :=0;
                  l_pay_cnt                     :=0;

                  v_process_total_count         := v_process_total_count + 1;     -- # of rows read from your cursor for loop
		  l_proposed_salary_n		:= xSal.proposed_salary_n;
                  l_effective_date              := xSal.effective_start_date;

  	-- -----------------------------------------------------------------------------------------
        --      Check for business group id  -- for AR salary source data, business group name is provided
        --                                          and column name in cust.ttec_h_ar_sal table is business_groupname
        -- -----------------------------------------------------------------------------------------
-- xxx chaned to check it against per_business_groups and AR gets name  from source data in business_group_info column
IF (xSal.business_groupname is NOT null) THEN
BEGIN
               SELECT  business_group_id
                   INTO  l_business_group_id
                   FROM  per_business_groups a
                  WHERE a.name = xSal.business_groupname
                    AND trunc(l_effective_date) >= trunc(a.date_from)
                    AND (trunc(l_effective_date) <= trunc(a.date_to) OR a.date_to is null);

                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     v_err_count := v_err_count + 1;
                     l_business_group_id :=       NULL;
                     g_error_message := SQLERRM;
                     l_error_message := 'No Business group id ';
                     apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                     || '-'|| g_error_message||' '||SYSTEM_USER_CONST);
END;
END IF;
-- ppp
            -- --------------------------------------------------------------------
            -- Befor call api, check nuber of per_assignments_f rows -- it shoube 1, more than 1 you will have problem
            -- --------------------------------------------------------------------
/* commented for now..
BEGIN
               SELECT  count(*) paf_rows
                   INTO  l_paf_cnt
                   FROM  per_assignments_f
                  WHERE  person_id = xSal.person_id;

               IF (l_paf_cnt != 1) THEN
                   v_err_count := v_err_count + 1;
                   l_error_message := 'More than ONE  Assignment record exist, will not call api  ';
                   apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                   || '-'|| g_error_message||' '||SYSTEM_USER_CONST);
               END IF;

                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     v_err_count := v_err_count + 1;
                     g_error_message := SQLERRM;
                     l_error_message := 'No Assignment record exist, will not call api  ';
                     apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                     || '-'|| g_error_message||' '||SYSTEM_USER_CONST);
END;

            -- --------------------------------------------------------------------
            -- Befor call api, check nuber of per_pay_proposals  rows -- it shoube 0, more than 0 you will have problem
            -- --------------------------------------------------------------------
BEGIN
               SELECT  count(*) pay_rows
                   INTO  l_pay_cnt
                   FROM  per_pay_proposals
                  WHERE  assignment_id = xSal.assignment_id;

               IF (l_pay_cnt != 0) THEN
                   v_err_count := v_err_count + 1;
                   l_error_message := 'Salary record alrealy exist, will not call api   ';
                   apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                   || '-'|| g_error_message||' '||SYSTEM_USER_CONST);
               END IF;
END;
*/ -- commented for now...
-- ppp
-- xxx
	    -- --------------------------------------------------------------------
            -- Call API to insert proposed Salary
            -- --------------------------------------------------------------------

         IF (v_err_count=0) THEN

       BEGIN

                       l_emp_count := l_emp_count + 1;

               l_error := FALSE;
               l_sal_err_flag := FALSE;


apps.ttec_conv_util.Stampln(e_open_log_file, 'XISPLAY 1 ' ||
'v_pay_proposal_id=' || v_pay_proposal_id ||
'xSal.assignment_id=' || xSal.assignment_id ||
'l_business_group_id=' || l_business_group_id ||
'change date' ||  xsal.change_date
);

/*
--  ---------------------------- Deterimine if hire date has an effective payroll date -------------------------- yyy *******************************
--
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------
IF (trunc(xSal.hire_date) <  trunc(to_date('01-JAN-03'))) Then     -- Payroll effective date
   l_sal_err_flag := TRUE;
 apps.ttec_conv_util.Stampln(E_open_log_file, MODULE_NAME_CONST||' '||
 'PAY BASIS NOT VALID SKIPPING  *********** '
 || xSal.emp_num_legacy || 'person_id=' || xSal.person_id ||'Payroll ID = ' || xSal.payroll_id || ' Pay basis id = ' || xSal.pay_basis_id ||
 ' ********'||SYSTEM_USER_CONST);
END IF;
--  ---------------------------- bandage solution -------------------------- zzz
*/

apps.ttec_conv_util.Stampln(e_open_log_file, 'XISPLAY  2' ||
'xsal.change_date=' || xsal.change_date || 'xsal.effective_start_date=' || xsal.effective_start_date ||
'xSal.proposal_reason=' || xSal.proposal_reason || ' l_proposed_salary_n=' || l_proposed_salary_n  || ' Legacy Emp number ' ||  xSal.emp_num_legacy
);

               IF (NOT l_error  AND NOT l_sal_err_flag) THEN
                       apps.hr_maintain_proposal_api.insert_salary_proposal
                       (
			       p_validate                               => l_validate,
                               p_pay_proposal_id                       	=> v_pay_proposal_id,
                               p_assignment_id                         	=> xSal.assignment_id,
                               p_business_group_id             		=> l_business_group_id,
                               p_change_date                           	=> l_effective_date, -- xsal.effective_start_date
                        --     p_next_sal_review_date          		=> xSal.next_sal_review_date,
                               p_proposal_reason                        => xSal.proposal_reason,
                               p_proposed_salary_n             		=> l_proposed_salary_n,
                        --     p_forced_ranking                        	=> xSal.forced_ranking,
                               p_performance_review_id         		=> v_performance_review_id,
                        --       p_attribute_category                     => null,
                        --       p_attribute1                             => null,
                        --       p_attribute20                            => null,
                               p_multiple_components           		=> l_multiple_components,
                               p_approved                              	=> 'Y',
                               p_object_version_number         		=> v_object_version_number,
                               p_element_entry_id                      	=> v_element_entry_id ,
                               p_inv_next_sal_date_warning     		=> v_inv_next_sal_date_warning,
                               p_proposed_salary_warning       		=> v_proposed_salary_warning,
                               p_approved_warning              		=> v_approved_warning,
                               p_payroll_warning                        => v_payroll_warning
                       );

                     IF (v_pay_proposal_id is not null OR sqlcode = 0) THEN
                       BEGIN
                                  v_process_success_count   := v_process_success_count + 1;   -- # of rows successful on API call
                                  apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '||
                                   'Pay proposal created for employee '|| xSal.last_name || 'v_element_entry_id =' ||v_element_entry_id
                                       || 'v_pay_proposal_id=' || v_pay_proposal_id
                                       ||' '||SYSTEM_USER_CONST);

                                       l_upd_sal_count := l_upd_sal_count + 1;
                                       l_count_of_10   := l_count_of_10+1;

				 --UPDATE cust.ttec_h_ar_sal			-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
				 UPDATE apps.ttec_h_ar_sal              --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
                                 SET
                                       pay_proposal_id                         = v_pay_proposal_id,
                                       object_version_number                   = v_object_version_number,
                                       element_entry_id                        = v_element_entry_id,
                                       status                                  = 'S'
				 WHERE
                                       rowid   =       xSal.rowid;

				EXCEPTION

				      WHEN OTHERS THEN

				       l_sal_err_flag := TRUE ;
                                       --v_err_count :=v_err_count+1;
                                       --v_err_up_count := v_err_up_count +1;
                                       g_error_message := SQLERRM;
                                       l_error_message :=  'ERROR while update ttec_h_ar_sal temporary talbe ';
                                               apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                                       || xSal.emp_num_legacy ||' - '|| g_error_message||' '||SYSTEM_USER_CONST);

                       END;
               ELSE
                         v_process_failed_count := v_process_failed_count +1; -- # of rows failed on API call
                         l_error_message :=  'Pay proposal failed for employee  ';
                         g_error_message := SQLERRM;
                         apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                         || xSal.emp_num_legacy ||' - '|| g_error_message||' '||SYSTEM_USER_CONST);

                        UPDATE cust.ttec_h_ar_sal
                        SET   status  = 'F'
                      WHERE   rowid   = xSal.rowid;
               END IF;  -- for if v_pay_proposal_id is not null check
          END IF; -- for (NOT l_error  AND NOT l_sal_err_flag) check
        END;
      END IF; -- for (v_err_count=0) check
    END LOOP;
  --   COMMIT;
        apps.ttec_conv_util.Stampln(e_open_log_file, 'Total # of record processed: ' || v_process_total_count );
        apps.ttec_conv_util.Stampln(e_open_log_file, 'Total # of record successful: ' || v_process_success_count );
        apps.ttec_conv_util.Stampln(e_open_log_file, 'Total # of record faild: ' || v_process_failed_count );
   ttec_conv_util.Close_Log_File(e_open_log_file);
 END;
/
show errors;
/
