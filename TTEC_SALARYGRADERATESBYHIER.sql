CREATE
	OR replace PROCEDURE TTEC_salaryGradeRatesByHier (
	p_employee_number IN VARCHAR2
	,salary_cursor OUT SYS_REFCURSOR
	) AS

/************************************************************************************
        Program Name: TTEC_salaryGradeRatesByHier

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
   MXKEERTHI(ARGANO)  19-May-2023           1.0          R12.2 Upgrade Remediation
    ****************************************************************************************/
BEGIN
	OPEN salary_cursor
	FOR

	SELECT (LPAD('_', (LEVEL - 1) * 3, '_') || LEVEL) "Hierarchy"
		,hier.hier_top "Hierarchy Top"
		,hier.territory_short_name "Country"
		,hier.last_name "Last Name"
		,hier.first_name "First Name"
		,hier.middle_names "Middle Names"
		--,hier.national_identifier             "National Identifier/SSN"
		,hier.employee_number "EE#"
		--,hier.sex                             "Gender"
		--,hier.date_of_birth                   "Date Of Birth"
		,hier.date_start "Date Start"
		--,hier.assignment_number               "Assignment Number"
		--,hier.sup_employee_number             "Supervisor EE#"
		,hier.sup_full_name "Supervisor Full Name"
		,hier.location_code "HR Location"
		--,hier.attribute2                      "Location Code"
		--,hier.name                            "Organization"
		--,hier.emp_category                    "Employment Category"
		,hier.job_family "Job Family"
		,hier.job_code "Job Code"
		,hier.job_title "Job Title"
		--,hier.english_title_equivalent        "English Title Equivalent"
		--,hier.position                        "Position"
		--,hier.job_code_location               "Job Code.Location"
		--,hier.manager_level                   "Manager Level"
		--,hier.bonus_plan                      "Bonus Plan"
		--,hier.target_bonus                    "Target Bonus"
		,hier.GCA_level "GCA Level"
		,hier.GCA_sub_family "GCA Sub-Family"
		--,hier.assignment_status               "Assignment Status"
		--,hier.proj_assgt_client_code          "Proj Assgt - Client Code"
		--,hier.proj_assgt_client_desc          "Proj Assgt - Client Desc"
		--,hier.proj_assgt_program_code         "Proj Assgt - Program Code"
		--,hier.proj_assgt_program_desc         "Proj Assgt - Program Desc"
		--,hier.proj_assgt_project_code         "Proj Assgt - Project Code"
		--,hier.proj_assgt_project_desc         "Proj Assgt - Project Desc"
		--,hier.costing_location                "Costing Location"
		--,hier.costing_client                  "Costing Client"
		--,hier.costing_department              "Costing Department"
		--,hier.derived_location                "Derived Location"
		--,hier.derived_department              "Derived Department"
		--,hier.night_differential              "Night Differential"
		--,hier.paaf_normal_hours               "Normal Hours"
		--,hier.frequency_meaning               "Frequency"
		--,hier.hourly_salaried                 "Hourly Salaried"
		,hier.salary_change_reason "Salary Change Reason"
		,hier.salary_change_date "Salary Change Date"
		--,hier.prop_pay_annualization_factor   "Pay Annualization Factor"
		--,hier.hourly_salary_previous          "Hourly Salary (Previous)"
		,hier.annual_salary_previous "Annual Salary (Previous)"
		--,hier.hourly_salary_current           "Hourly Salary (Current)"
		,hier.annual_salary_current "Annual Salary (Current)"
		,hier.percentaje_of_increase "% of Increase"
		--,hier.days_at_current_job             "Days at Current Job"
		--,hier.months_at_current_job           "Months at Current Job"
		--,hier.years_at_current_job            "Years at Current Job"
		,hier.minimum_grade "Minimum"
		,hier.mid_value_grade "Mid-Value"
		,hier.maximum_grade "Maximum"
		,hier.recent_performance_date "Recent Performance Date"
		,hier.recent_performance_type "Recent Performance Type"
		,hier.recent_performance_rating "Recent Performance Rating"
		,(
			SELECT COUNT(DISTINCT asg.person_id) count_emp
			FROM apps.per_people_f ppl
				,
				--hr.per_all_assignments_f asg,   --Commented code by MXKEERTHI-ARGANO, 05/19/2023
				APPS.per_all_assignments_f asg
				,--code added by MXKEERTHI-ARGANO, 05/19/2023
				per_jobs pjs
				,(
					SELECT paaf.person_id
					--  FROM    hr.per_all_assignments_f paaf, --Commented code by MXKEERTHI-ARGANO, 05/19/2023
					FROM APPS.per_all_assignments_f paaf
						,--code added by MXKEERTHI-ARGANO, 05/19/2023
						apps.per_people_f papf
						,per_jobs pj
					WHERE papf.business_group_id != 0
						AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date
							AND paaf.effective_end_date
						AND paaf.job_id = pj.job_id
						AND paaf.person_id = papf.person_id
						AND papf.current_employee_flag = 'Y'
						AND TRUNC(SYSDATE) BETWEEN papf.effective_start_date
							AND papf.effective_end_date
					) sel
			WHERE ppl.business_group_id != 0
				AND ppl.current_employee_flag = 'Y'
				AND TRUNC(SYSDATE) BETWEEN ppl.EFFECTIVE_START_DATE
					AND ppl.effective_end_date
				AND ppl.person_id = asg.person_id
				AND TRUNC(SYSDATE) BETWEEN asg.effective_start_date
					AND asg.effective_end_date
				AND asg.primary_flag = 'Y'
				AND asg.job_id = pjs.job_id
				AND asg.supervisor_id = sel.person_id
				AND sel.person_id = hier.person_id
			) "Total Reports in the Hierarchy"
		,(
			SELECT COUNT(DISTINCT hier2.person_id) Total_reports
			FROM (
				SELECT papf.person_id
					,paaf.supervisor_id
				FROM apps.per_people_f papf
					,
					--  hr.per_all_assignments_f paaf  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
					APPS.per_all_assignments_f paaf --code added by MXKEERTHI-ARGANO, 05/19/2023
				WHERE papf.business_group_id <> 0
					AND (
						papf.current_employee_flag = 'Y'
						OR papf.current_npw_flag = 'Y'
						)
					AND (SYSDATE) BETWEEN papf.effective_start_date
						AND papf.effective_end_date
					AND paaf.person_id = papf.person_id
					AND (SYSDATE) BETWEEN paaf.effective_start_date
						AND paaf.effective_end_date
					AND paaf.primary_flag = 'Y'
					AND paaf.assignment_type IN (
						'E'
						,'C'
						)
				) hier2 CONNECT BY PRIOR hier2.person_id = hier2.supervisor_id START
			WITH hier2.person_id = hier.person_id
			) - 1 "Total Reports"
	FROM (
		SELECT DISTINCT papf.full_name hier_top
			,papf.person_id
			,paaf.supervisor_id
			,ft.territory_short_name
			,papf.last_name
			,papf.first_name
			,papf.middle_names
			,
			--papf.national_identifier,
			papf.employee_number
			,
			--papf.sex,
			--papf.date_of_birth,
			ppos.date_start
			,
			--paaf.assignment_number,
			--papf_sup.employee_number sup_employee_number,
			papf_sup.full_name sup_full_name
			,loc.location_code
			,
			--loc.attribute2,
			--org.name,
			--CASE WHEN papf.business_group_id = 1632
			--AND flv_emp_cat.meaning = 'Tiempo Completo-Regular'
			--THEN 'Fulltime-Regular'
			--ELSE flv_emp_cat.meaning
			--END emp_category,
			pj.attribute5 job_family
			,SUBSTR(pj.NAME, 1, INSTR(pj.NAME, '.') - 1) job_code
			,SUBSTR(pj.NAME, INSTR(pj.NAME, '.') + 1, 40) job_title
			,
			--pj.attribute8 english_title_equivalent,
			--NVL ((CASE WHEN pj.attribute8 = '0'
			--      THEN NULL
			--      ELSE pj.attribute8
			--      END),
			--      SUBSTR (pj.NAME, INSTR (pj.NAME, '.') + 1, 40)) position,
			--SUBSTR (pj.NAME, 1, INSTR (pj.NAME, '.') - 1) || '.' || loc.location_code job_code_location,
			--pj.attribute6 manager_level,
			--pj.attribute2 bonus_plan,
			--(pj.attribute3 / 100) target_bonus,
			pj.attribute20 GCA_level
			,pj.attribute10 GCA_sub_family
			,
			--(CASE WHEN papf.current_employee_flag IS NULL
			-- AND paaf.assignment_status_type_id = 1
			-- THEN 'Terminate Assignment'
			-- ELSE past.user_status
			-- END) assignment_status,
			--tepa.clt_cd proj_assgt_client_code,
			--tcln.desc_shrt proj_assgt_client_desc,
			--tepa.prog_cd proj_assgt_program_code,
			--tprg.desc_shrt proj_assgt_program_desc,
			--tepa.prj_cd proj_assgt_project_code,
			--tprj.desc_shrt proj_assgt_project_desc,
			--pcak.segment1 costing_location,
			--pcak.segment2 costing_client,
			--pcak.segment3 costing_department,
			--pcak_org.segment1 derived_location,
			--pcak_org.segment3 derived_department,
			--paaf.ass_attribute7 night_differential,
			--paaf.normal_hours paaf_normal_hours,
			--fnd_freq.meaning frequency_meaning,
			--DECODE (paaf.hourly_salaried_code,
			--       'H','Hourly',
			--       'S','Salaried',
			--            paaf.hourly_salaried_code) hourly_salaried,
			CASE 
				WHEN papf.business_group_id = 1761
					THEN hl1.meaning
				ELSE flv_sal.meaning
				END salary_change_reason
			,prop.change_date salary_change_date
			,
			--prop.pay_annualization_factor prop_pay_annualization_factor,
			--prop.hourly_prev hourly_salary_previous,
			prop.annual_prev annual_salary_previous
			,
			--prop.hourly hourly_salary_current,
			prop.annual annual_salary_current
			,CASE NVL(prop.proposed_salary_n_prev, 0)
				WHEN 0
					THEN 0
				ELSE ROUND(((NVL(prop.proposed_salary_n * prop.pay_annualization_factor, 0) * 100) / GREATEST(NVL(prop.proposed_salary_n_prev * prop.pay_annualization_factor_prev, 0), 1) - 100), 2)
				END percentaje_of_increase
			,
			--ROUND(apps.ttech_rt_utils_pk.f_job_length_assg (paaf.business_group_id,paaf.assignment_id,paaf.job_id),2) days_at_current_job,
			--ROUND(apps.ttech_rt_utils_pk.f_job_length_assg (paaf.business_group_id,paaf.assignment_id,paaf.job_id) / 365 * 12, 2) months_at_current_job,
			--ROUND(CAST(apps.ttech_rt_utils_pk.f_job_length_assg (paaf.business_group_id,paaf.assignment_id,paaf.job_id) / 365 AS NUMBER),2) years_at_current_job,
			CASE 
				WHEN pj.job_information3 = 'NEX'
					AND paaf.business_group_id IN (
						325
						,326
						)
					THEN ROUND(TO_NUMBER(tGrades.minimum) * 2080, - 3)
				WHEN pj.attribute9 = 'NEX'
					AND paaf.business_group_id IN (1517)
					THEN TRUNC(TO_NUMBER(tGrades.minimum) * 12, 2)
				ELSE TO_NUMBER(tGrades.minimum)
				END minimum_grade
			,CASE 
				WHEN pj.job_information3 = 'NEX'
					AND paaf.business_group_id IN (
						325
						,326
						)
					THEN ROUND(TO_NUMBER(tGrades.mid_value) * 2080, - 3)
				WHEN pj.attribute9 = 'NEX'
					AND paaf.business_group_id IN (1517)
					THEN TRUNC(TO_NUMBER(tGrades.mid_value) * 12, 2)
				ELSE TO_NUMBER(tGrades.mid_value)
				END mid_value_grade
			,CASE 
				WHEN pj.job_information3 = 'NEX'
					AND paaf.business_group_id IN (
						325
						,326
						)
					THEN ROUND(TO_NUMBER(tGrades.maximum) * 2080, - 3)
				WHEN pj.attribute9 = 'NEX'
					AND paaf.business_group_id IN (1517)
					THEN TRUNC(TO_NUMBER(tGrades.maximum) * 12, 2)
				ELSE TO_NUMBER(tGrades.maximum)
				END maximum_grade
			,NVL(pprv.review_date, '') recent_performance_date
			,NVL(pprv.event_type, '') recent_performance_type
			,NVL(pprv.rating_meaning, '') recent_performance_rating
		--START R12.2 Upgrade Remediation
		/*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
            FROM       hr.per_all_people_f papf,
                    hr.per_all_people_f papf_sup,
                    apps.fnd_territories_tl ft,
                    hr.per_all_assignments_f paaf,
                    hr.hr_locations_all loc,
                    hr.per_jobs pj,
	   */
		--code Added  by MXKEERTHI-ARGANO, 05/19/2023
		FROM APPS.per_all_people_f papf
			,APPS.per_all_people_f papf_sup
			,APPS.fnd_territories_tl ft
			,APPS.per_all_assignments_f paaf
			,APPS.hr_locations_all loc
			,APPS.per_jobs pj
			,
			--END R12.2.10 Upgrade remediation
			(
				SELECT pg.business_group_id
					,pgrf.minimum
					,pgrf.maximum
					,pgrf.mid_value
					,CASE 
						WHEN SUBSTR(pg.name, INSTR(pg.name, '.') + 1) LIKE '%\%'
							AND pg.business_group_id = 1632
							THEN CONCAT (
									'ARG-B.'
									,SUBSTR((SUBSTR(pg.name, INSTR(pg.name, '.') + 1)), INSTR((SUBSTR(pg.name, INSTR(pg.name, '.') + 1)), '.') + 1)
									)
						WHEN SUBSTR(pg.name, INSTR(pg.name, '.') + 1) LIKE '%\%'
							AND pg.business_group_id = 1633
							THEN CONCAT (
									'ARG-B.'
									,SUBSTR((SUBSTR(pg.name, INSTR(pg.name, '.') + 1)), INSTR((SUBSTR(pg.name, INSTR(pg.name, '.') + 1)), '.') + 1)
									)
						WHEN SUBSTR(pg.name, INSTR(pg.name, '.') + 1) LIKE '%\%'
							AND pg.business_group_id = 1839
							THEN CONCAT (
									'AUS-St.'
									,SUBSTR((SUBSTR(pg.name, INSTR(pg.name, '.') + 1)), INSTR((SUBSTR(pg.name, INSTR(pg.name, '.') + 1)), '.') + 1)
									)
						ELSE SUBSTR(pg.name, INSTR(pg.name, '.') + 1)
						END jobGrade
					,SUBSTR(pg.name, 1, INSTR(pg.name, '.') - 1) idLocGrade
				--START R12.2 Upgrade Remediation
				/*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
                      FROM  hr.pay_grade_rules_f pgrf,
                            hr.pay_grade_rules_f pgrf_min,
                            hr.per_grades pg,
	   */
				--code Added  by MXKEERTHI-ARGANO, 05/19/2023
				FROM APPS.pay_grade_rules_f pgrf
					,APPS.pay_grade_rules_f pgrf_min
					,APPS.per_grades pg
					,
					--END R12.2.10 Upgrade remediation
					apps.fnd_currencies_vl cur
				WHERE pg.business_group_id <> 0
					AND NVL(pg.date_to, '31-DEC-4712') = NVL((
							SELECT MAX(pg_sub.date_to)
							--FROM    hr.per_grades pg_sub   --Commented code by MXKEERTHI-ARGANO, 05/19/2023
							FROM APPS.per_grades pg_sub --code added by MXKEERTHI-ARGANO, 05/19/2023
							WHERE pg_sub.grade_id = pg.grade_id
							), '31-DEC-4712')
					AND pgrf.effective_end_date = (
						SELECT MAX(pgrf_sub.effective_end_date)
						--FROM    hr.pay_grade_rules_f pgrf_sub  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
						FROM APPS.pay_grade_rules_f pgrf_sub --code added by MXKEERTHI-ARGANO, 05/19/2023
						WHERE pgrf.grade_rule_id = pgrf_sub.grade_rule_id
						)
					AND pgrf_min.grade_or_spinal_point_id = pgrf.grade_or_spinal_point_id
					AND pgrf_min.effective_start_date = (
						SELECT MIN(pgrf_sub2.effective_start_date)
						--FROM    hr.pay_grade_rules_f pgrf_sub2--Commented code by MXKEERTHI-ARGANO, 05/19/2023
						FROM APPS.pay_grade_rules_f pgrf_sub2 --code added by MXKEERTHI-ARGANO, 05/19/2023
						WHERE pgrf_min.grade_rule_id = pgrf_sub2.grade_rule_id
						)
					AND pg.grade_id = pgrf.grade_or_spinal_point_id
					AND cur.currency_code(+) = pgrf.currency_code
				) tGrades
			,APPS.per_periods_of_service ppos
			,APPS.hr_all_organization_units org
			,APPS.pay_all_payrolls_f pap
			,APPS.per_assignment_status_types past
			,APPS.pay_cost_allocations_f pcaf
			,APPS.pay_cost_allocation_keyflex pcak
			,APPS.pay_cost_allocation_keyflex pcak_org
			,apps.fnd_lookup_values fnd_freq
			,apps.fnd_lookup_values flv_emp_cat
			,apps.fnd_lookup_values flv_sal
			,apps.fnd_lookup_values flv_assg_categ2
			,HR_LOOKUPS HL1
			,
			--ovprod_o.progs@COMPSYCH_ONEVIEW tprg,
			--ovprod_o.prjs@COMPSYCH_ONEVIEW tprj,
			--ovprod_o.clts@COMPSYCH_ONEVIEW tcln,
			--cust.ttec_emp_proj_asg tepa,
			per_performance_reviews_v pprv
			,(
				SELECT CASE ppb.pay_basis
						WHEN 'HOURLY'
							THEN ppp.proposed_salary_n
						ELSE ROUND(NVL(ppp.proposed_salary_n * ppb.pay_annualization_factor, 0) / -- annual conversion
								GREATEST(NVL(CASE 
											WHEN paaf_act.frequency IS NOT NULL
												AND paaf_act.normal_hours IS NOT NULL
												AND paaf_act.business_group_id <> 1633
												THEN CASE paaf_act.frequency
														WHEN 'W' -- Week
															THEN paaf_act.normal_hours * 52
														WHEN 'M' -- Month
															THEN paaf_act.normal_hours * 12
														WHEN 'D' -- Day
															THEN paaf_act.normal_hours * 260
														WHEN 'Y' -- Year
															THEN paaf_act.normal_hours * 1
														ELSE NVL(ppb_hs_country.pay_annualization_factor, 2080)
														END
											ELSE NVL(ppb_hs_country.pay_annualization_factor, 2080)
											END, 1) -- to avoid null division
									, 1) -- to avoid zero division
								, 2) -- round to two decimals
						END hourly
					,NVL(ppp.proposed_salary_n * ppb.pay_annualization_factor, 0) annual
					,CASE ppb_prev.pay_basis
						WHEN 'HOURLY'
							THEN ppp_prev.proposed_salary_n
						ELSE ROUND(NVL(ppp_prev.proposed_salary_n * ppb_prev.pay_annualization_factor, 0) / -- annual conversion
								GREATEST(NVL(CASE 
											WHEN paaf_prev.frequency IS NOT NULL
												AND paaf_prev.normal_hours IS NOT NULL
												AND paaf_prev.business_group_id <> 1633
												THEN CASE paaf_prev.frequency
														WHEN 'W' -- Week
															THEN paaf_prev.normal_hours * 52
														WHEN 'M' -- Month
															THEN paaf_prev.normal_hours * 12
														WHEN 'D' -- Day
															THEN paaf_prev.normal_hours * 260
														WHEN 'Y' -- Year
															THEN paaf_prev.normal_hours * 1
														ELSE NVL(ppb_hs_country.pay_annualization_factor, 2080)
														END
											ELSE NVL(ppb_hs_country.pay_annualization_factor, 2080)
											END, 1) --to avoid null division
									, 1) --to avoid zero division
								, 2) --round to two decimals
						END hourly_prev
					,NVL(ppp_prev.proposed_salary_n * ppb_prev.pay_annualization_factor, 0) annual_prev
					,ppp.proposed_salary_n proposed_salary_n
					,ppp_prev.proposed_salary_n proposed_salary_n_prev
					,ppp.assignment_id
					,ppp.change_date
					,ppb.pay_annualization_factor pay_annualization_factor
					,ppb_prev.pay_annualization_factor pay_annualization_factor_prev
					,ppp.proposal_reason
					,ppp.business_group_id
				FROM apps.per_pay_proposals ppp
				--START R12.2 Upgrade Remediation
				/*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
                       LEFT JOIN hr.per_all_assignments_f paaf_basis
                       ON paaf_basis.assignment_id = ppp.assignment_id
                       LEFT JOIN hr.per_all_assignments_f paaf_act
                       ON paaf_act.assignment_id = ppp.assignment_id
                       LEFT JOIN hr.per_pay_bases ppb
                       ON paaf_basis.pay_basis_id = ppb.pay_basis_id
                       LEFT JOIN apps.per_pay_proposals ppp_prev
                       ON ppp.assignment_id = ppp_prev.assignment_id
                       LEFT JOIN hr.per_all_assignments_f paaf_basis_prev
                       ON ppp_prev.assignment_id = paaf_basis_prev.assignment_id
                       LEFT JOIN hr.per_pay_bases ppb_prev
                       ON paaf_basis_prev.pay_basis_id = ppb_prev.pay_basis_id
                       LEFT JOIN hr.per_all_assignments_f paaf_prev
                       ON ppp_prev.assignment_id = paaf_prev.assignment_id

	   */
				--code Added  by MXKEERTHI-ARGANO, 05/19/2023
				LEFT JOIN APPS.per_all_assignments_f paaf_basis ON paaf_basis.assignment_id = ppp.assignment_id
				LEFT JOIN APPS.per_all_assignments_f paaf_act ON paaf_act.assignment_id = ppp.assignment_id
				LEFT JOIN APPS.per_pay_bases ppb ON paaf_basis.pay_basis_id = ppb.pay_basis_id
				LEFT JOIN apps.per_pay_proposals ppp_prev ON ppp.assignment_id = ppp_prev.assignment_id
				LEFT JOIN APPS.per_all_assignments_f paaf_basis_prev ON ppp_prev.assignment_id = paaf_basis_prev.assignment_id
				LEFT JOIN APPS.per_pay_bases ppb_prev ON paaf_basis_prev.pay_basis_id = ppb_prev.pay_basis_id
				LEFT JOIN APPS.per_all_assignments_f paaf_prev ON ppp_prev.assignment_id = paaf_prev.assignment_id
				--END R12.2.10 Upgrade remediation
				LEFT JOIN (
					SELECT DISTINCT ppb_c.business_group_id
						,ppb_c.pay_annualization_factor
					-- FROM   hr.per_pay_bases ppb_c   --Commented code by MXKEERTHI-ARGANO, 05/19/2023
					FROM APPS.per_pay_bases ppb_c --code added by MXKEERTHI-ARGANO, 05/19/2023
					WHERE ppb_c.pay_basis = 'HOURLY'
						AND ppb_c.pay_annualization_factor IN (
							SELECT MIN(ppb_csub.pay_annualization_factor)
							--FROM hr.per_pay_bases ppb_csub--Commented code by MXKEERTHI-ARGANO, 05/19/2023
							FROM APPS.per_pay_bases ppb_csub --code added by MXKEERTHI-ARGANO, 05/19/2023
							WHERE ppb_c.business_group_id = ppb_csub.business_group_id
								AND ppb_csub.pay_basis = 'HOURLY'
							)
					) ppb_hs_country ON ppp.business_group_id = ppb_hs_country.business_group_id
				WHERE ppp.business_group_id <> 0
					AND TRUNC(SYSDATE) BETWEEN ppp.change_date
						AND NVL(ppp.date_to, '31-DEC-4712')
					AND ppp.approved = 'Y'
					AND ppp.change_date BETWEEN paaf_basis.effective_start_date
						AND paaf_basis.effective_end_date
					AND TRUNC(SYSDATE) BETWEEN paaf_act.effective_start_date
						AND paaf_act.effective_end_date
					AND (ppp.change_date - 1) BETWEEN ppp_prev.change_date
						AND NVL(ppp_prev.date_to, '31-DEC-4712')
					AND ppp_prev.change_date BETWEEN paaf_basis_prev.effective_start_date
						AND paaf_basis_prev.effective_end_date
					AND ppp_prev.approved = 'Y'
					AND (ppp_prev.change_date - 1) BETWEEN paaf_prev.effective_start_date
						AND paaf_prev.effective_end_date
				) prop
		WHERE papf.business_group_id <> 0
			AND TRUNC(SYSDATE) BETWEEN papf.effective_start_date
				AND papf.effective_end_date
			AND papf.current_employee_flag = 'Y'
			AND papf.person_id = paaf.person_id
			AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date
				AND paaf.effective_end_date
			AND paaf.assignment_type = 'E'
			AND paaf.primary_flag = 'Y'
			AND paaf.job_id = pj.job_id(+)
			AND (
				loc.location_code = tGrades.jobGrade
				OR tGrades.jobGrade IS NULL
				)
			AND SUBSTR(pj.NAME, 1, INSTR(pj.NAME, '.') - 1) = tGrades.idLocGrade(+)
			AND pj.business_group_id = tGrades.business_group_id(+)
			AND paaf.location_id = loc.location_id(+)
			AND papf.person_id = ppos.person_id
			AND paaf.period_of_service_id = ppos.period_of_service_id
			AND paaf.organization_id = org.organization_id(+)
			AND paaf.payroll_id = pap.payroll_id(+)
			AND paaf.assignment_status_type_id = past.assignment_status_type_id(+)
			AND paaf.supervisor_id = papf_sup.person_id(+)
			AND TRUNC(SYSDATE) BETWEEN papf_sup.effective_start_date(+)
				AND papf_sup.effective_end_date(+)
			AND pcaf.assignment_id(+) = paaf.assignment_id
			AND TRUNC(SYSDATE) BETWEEN pcaf.effective_start_date(+)
				AND pcaf.effective_end_date(+)
			AND pcaf.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id(+)
			AND org.cost_allocation_keyflex_id = pcak_org.cost_allocation_keyflex_id(+)
			AND paaf.employment_category = flv_emp_cat.lookup_code(+)
			AND flv_emp_cat.lookup_type(+) = 'EMP_CAT'
			AND flv_emp_cat.security_group_id(+) = DECODE(paaf.business_group_id, 325, 2, 326, 3, 1761, 26, 1517, 22, 2287, 29, 1631, 23, 5054, 89, 1632, 24, 1633, 25, 1839, 28, 2311, 49, 2327, 69, 2328, 70, 1804, 27, 2)
			AND flv_emp_cat.LANGUAGE (+) = USERENV('LANG')
			/*------------------------------*/
			/*added to bring descriptions of the old job category */
			AND paaf.ass_attribute15 = flv_assg_categ2.lookup_code(+)
			AND flv_assg_categ2.lookup_type(+) = 'EMP_CAT'
			AND flv_assg_categ2.LANGUAGE (+) = 'ESA'
			AND flv_assg_categ2.security_group_id(+) = '25'
			/*------------------------------*/
			AND paaf.assignment_id = prop.assignment_id(+)
			AND prop.proposal_reason = flv_sal.lookup_code(+)
			AND flv_sal.lookup_type(+) = 'PROPOSAL_REASON'
			AND flv_sal.security_group_id(+) = DECODE(prop.business_group_id, 325, 2, 326, 3, 1761, 26, 1517, 22, 1631, 23, 1839, 28, 2)
			AND flv_sal.LANGUAGE (+) = USERENV('LANG')
			AND fnd_freq.lookup_code(+) = paaf.frequency
			AND fnd_freq.lookup_type(+) = 'FREQUENCY'
			AND flv_emp_cat.security_group_id(+) = DECODE(paaf.business_group_id, 325, 2, 326, 3, 1761, 26, 1517, 22, 2287, 29, 1631, 23, 5054, 89, 1632, 24, 1633, 25, 1839, 28, 2311, 49, 2327, 69, 2328, 70, 1804, 27, 2)
			AND fnd_freq.LANGUAGE (+) = USERENV('LANG')
			AND ft.territory_code(+) = loc.country
			AND ft.LANGUAGE (+) = USERENV('LANG')
			--AND papf.person_id = tepa.person_id(+)
			--AND tepa.clt_cd = tcln.gl_clt_cd(+)
			--AND tepa.prog_cd = tprg.prog_cd(+)
			--AND tepa.prj_cd = tprj.prj_cd(+)
			--AND TRUNC (SYSDATE) BETWEEN tepa.prj_strt_dt(+) AND  NVL (tepa.prj_end_dt(+), '31-DEC-4712')
			--AND TRUNC (SYSDATE) BETWEEN tprg.st_d(+) AND NVL (tprg.end_d(+), '31-DEC-4712')
			--AND TRUNC (SYSDATE) BETWEEN tprj.st_d(+) AND NVL (tprj.end_d(+), '31-DEC-4712')
			--AND TRUNC (SYSDATE) BETWEEN tcln.st_d(+) AND NVL (tcln.end_d(+), '31-DEC-4712')
			/* Salary Change Reason UK */
			AND HL1.LOOKUP_CODE(+) = prop.PROPOSAL_REASON
			AND HL1.LOOKUP_TYPE(+) = 'PROPOSAL_REASON'
			/* Performance Review */
			AND pprv.person_id(+) = paaf.person_id
			AND (
				pprv.review_date = (
					SELECT MAX(review_date)
					FROM per_performance_reviews_v pprv2
					WHERE pprv2.person_id(+) = paaf.person_id
					)
				OR pprv.review_date IS NULL
				)
		) hier CONNECT BY PRIOR hier.person_id = hier.supervisor_id START
	WITH hier.employee_number = p_employee_number
	ORDER SIBLINGS BY hier.employee_number;
END;
/
show errors;
/