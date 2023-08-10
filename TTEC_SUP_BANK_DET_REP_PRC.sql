create or replace PROCEDURE ttec_sup_bank_det_rep_prc(
        errbuf    OUT VARCHAR2,
        retcode   OUT NUMBER,
		p_org_id  IN  NUMBER,
		p_vendor_id IN NUMBER)
IS



/************************************************************************************
        Program Name: TTEC_SUP_BANK_DET_REP_PRC 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI(ARGANO)            1.0      19-May-2023      R12.2 Upgrade Remediation
    ****************************************************************************************/



cursor get_sup_bank
IS
SELECT
      sup.segment1 Supplier_Number
     , sup.vendor_name
     , ss.vendor_site_code
     , eba.bank_account_num supplier_bank_account_num
     ,eba.bank_account_name supplier_bank_account_name,
      eba.bank_account_type,
     ext_branch.bank_branch_name branch_name,
     ext_branch.branch_number branch_num,
     ext_bank.bank_name bank_name,
     ext_bank.bank_number bank_number
	 ,ppf.employee_number
     ,ppf.full_name employee_name
	 ,nvl(ppf.current_employee_flag, 'N') ACTIVE_EMPLOYEE
     ,pea.segment1 employee_bank_account_name
     ,pea.segment2 employee_account_type
     ,pea.segment3 employee_account_number
     ,pea.segment4 employee_transit_code
     ,pea.segment5 employee_bank_name
     ,pea.segment6 employee_bank_branch
  FROM ap_suppliers sup
     , ap_supplier_sites_all       ss
     , iby_external_payees_all epa
     , iby_pmt_instr_uses_all  piu
     , iby_ext_bank_accounts   eba
     , per_all_people_f ppf
     , iby_ext_banks_v ext_bank
    -- , iby_pmt_instr_uses_all ipi
     , iby_ext_bank_branches_v ext_branch
 --    , apps.iby_account_owners owners
     , pay_personal_payment_methods_f pppm
     , per_all_assignments_f paaf
     , PAY_EXTERNAL_ACCOUNTS PEA
 WHERE sup.vendor_id     = ss.vendor_id
   AND ss.vendor_site_id = epa.supplier_site_id(+)
   AND epa.ext_payee_id  = piu.ext_pmt_party_id (+)
   AND piu.instrument_id = eba.ext_bank_account_id(+)
   and eba.branch_id = ext_branch.branch_party_id(+)
   AND eba.bank_id = ext_bank.bank_party_id(+)
--   AND epa.payee_party_id      = owners.account_owner_party_id
 --  AND owners.ext_bank_account_id = piu.instrument_id
   AND sup.vendor_type_lookup_code = 'EMPLOYEE'
   AND sup.employee_id is not null
   AND ppf.person_id = sup.employee_id
 --  AND ipi.instrument_id = eba.ext_bank_account_id
--   AND  epa.ext_payee_id = ipi.ext_pmt_party_id
   AND pppm.assignment_id        = paaf.assignment_id
   AND pea.external_account_id = pppm.external_account_id
   AND paaf.person_id            = ppf.person_id
   AND (sup.vendor_id = p_vendor_id or p_vendor_id is null)
   AND pea.segment2 = 'C'
   AND pppm.amount IS NULL
   AND NVL (pppm.percentage, 100) =
                     (SELECT MAX (NVL (percentage, 100))
                        /*
						START R12.2 Upgrade Remediation
						code commented by RXNETHI-ARGANO,19/05/23
						FROM hr.pay_personal_payment_methods_f a,
                             hr.pay_external_accounts b
						*/
						--code added by RXNETHI-ARGANO
						FROM apps.pay_personal_payment_methods_f a,
                             apps.pay_external_accounts b
						--END R12.2 Upgrade Remediation
                       WHERE a.assignment_id = pppm.assignment_id
                         AND a.external_account_id = b.external_account_id
                         AND a.amount IS NULL
                         AND b.segment2 = 'C'
                         AND TRUNC (SYSDATE) BETWEEN a.effective_start_date
                                                 AND a.effective_end_date)
   AND NVL(ss.INACTIVE_DATE,SYSDATE+1) >= SYSDATE
   AND  NVL(sup.END_DATE_ACTIVE,SYSDATE+1) >= SYSDATE
   AND  trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
   AND  trunc(sysdate) between paaf.effective_start_date and paaf.effective_end_date
   AND  trunc(sysdate) between pppm.effective_start_date and pppm.effective_end_date
   AND (ss.org_id = p_org_id or p_org_id is null)
   and piu.end_date is null
UNION
select NULL Supplier_Number
     , NULL vendor_name
     , NULL vendor_site_code
     , NULL supplier_bank_account_num
     , NULL supplier_bank_account_name,
       NULL bank_account_type,
         NULL branch_name,
         NULL branch_num,
         NULL bank_name,
         NULL bank_number,
     ppf.employee_number,
     ppf.full_name
	 ,nvl(ppf.current_employee_flag, 'N') ACTIVE_EMPLOYEE
     ,pea.segment1 employee_bank_account_name
     ,pea.segment2 employee_account_type
     ,pea.segment3 employee_account_number
     ,pea.segment4 employee_transit_code
     ,pea.segment5 employee_bank_name
     ,pea.segment6 employee_bank_branch
from apps.ap_cards_all apc,apps.per_all_people_f ppf,apps.per_all_assignments_f paaf,
apps.pay_personal_payment_methods_f pppm,apps.PAY_EXTERNAL_ACCOUNTS PEA
where (apc.org_id = p_org_id or p_org_id is null)
and apc.employee_id = ppf.person_id
and ppf.person_id = paaf.person_id
AND  trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
AND  trunc(sysdate) between paaf.effective_start_date and paaf.effective_end_date
AND  trunc(sysdate) between pppm.effective_start_date and pppm.effective_end_date
and  nvl(ppf.current_employee_flag, 'N') = 'Y'
and apc.inactive_date is null
AND pppm.assignment_id        = paaf.assignment_id
AND pea.external_account_id = pppm.external_account_id
AND (ppf.person_id = p_vendor_id or p_vendor_id is null)
AND pea.segment2 = 'C'
AND pppm.amount IS NULL
AND NVL (pppm.percentage, 100) =
                     (SELECT MAX (NVL (percentage, 100))
                        /*
						START R12.2 Upgrade Remediation
						code commented by RXNETHI-ARGANO,19/05/23
						FROM hr.pay_personal_payment_methods_f a,
                             hr.pay_external_accounts b
                        */
						--code added by RXNETHI-ARGANO,19/05/23
						FROM apps.pay_personal_payment_methods_f a,
                             apps.pay_external_accounts b
						--END R12.2 Upgrade Remediation
					   WHERE a.assignment_id = pppm.assignment_id
                         AND a.external_account_id = b.external_account_id
                         AND a.amount IS NULL
                         AND b.segment2 = 'C'
                         AND TRUNC (SYSDATE) BETWEEN a.effective_start_date
                                                 AND a.effective_end_date)
and not exists (select 1 from apps.ap_suppliers where employee_id = ppf.person_id and vendor_type_lookup_code = 'EMPLOYEE' and END_DATE_ACTIVE is null);
l_output varchar2(4000);
l_heading   VARCHAR2(1000);
BEGIN
fnd_file.put_line(
            fnd_file.log,
            'Report to display Supplier Bank Details'
        );
         l_heading := 'SUPPLIER NUMBER'
         || '|'
         || 'SUPPLIER NAME'
         || '|'
         || 'SUPPLIER SITE'
         || '|'
         || 'SUPPLIER BANK ACCOUNT NUM'
         || '|'
         || 'SUPPLIER BANK ACCOUNT NAME'
		 || '|'
         || 'SUPPLIER BANK ACCOUNT TYPE'
		 || '|'
		 || 'SUPPLIER BANK BRANCH'
		 || '|'
		 || 'SUPPLIER BANK BRANCH NUM'
		 || '|'
		 || 'SUPPLIER BANK NAME'
		 || '|'
		 || 'SUPPLIER BANK NUM'
		 || '|'
		 || 'EMPLOYEE NUM'
		 || '|'
		 || 'EMPLOYEE NAME'
		 || '|'
		 || 'ACTIVE EMPLOYEE'
		 || '|'
		 || 'EMPLOYEE BANK ACCT NAME'
		 || '|'
		 || 'EMPLOYEE ACCOUNT TYPE'
		 || '|'
		 || 'EMPLOYEE TRANSIT CODE'
		 || '|'
		 || 'EMPLOYEE BANK NAME'
		 || '|'
		 || 'EMPLOYEE BANK BRANCH';
        fnd_file.put_line(
            fnd_file.output,
            l_heading
        );
FOR rec_get_bank in get_sup_bank
LOOP
BEGIN
l_output := NULL;
l_output := rec_get_bank.Supplier_Number
            ||'|'||
		    rec_get_bank.vendor_name
			|| '|'||
			rec_get_bank.vendor_site_code
			|| '|'||
			rec_get_bank.supplier_bank_account_num
			|| '|'||
			rec_get_bank.supplier_bank_account_name
			|| '|'||
			rec_get_bank.bank_account_type
		    || '|'||
			 rec_get_bank.branch_name
			 || '|'||
			 rec_get_bank.branch_num
			 || '|'||
			rec_get_bank.bank_name
			|| '|'||
			 rec_get_bank.bank_number
			 || '|'||
			 rec_get_bank.employee_number
			 || '|'||
			 rec_get_bank.employee_name
			 || '|'||
			 rec_get_bank.active_employee
			 || '|'||
			 rec_get_bank.employee_bank_account_name
			 || '|'||
			 rec_get_bank.employee_account_type
			 || '|'||
			 rec_get_bank.employee_account_number
			 || '|'||
			 rec_get_bank.employee_transit_code
			 || '|'||
			 rec_get_bank.employee_bank_name
			 || '|'||
			 rec_get_bank.employee_bank_branch;

			 fnd_file.put_line(
                    fnd_file.output,
                    l_output
                );
EXCEPTION
WHEN OTHERS THEN
fnd_file.put_line(  fnd_file.log, 'Error :' || sqlerrm(sqlcode)  );
END;
END LOOP;
END;
/
show errors;
/