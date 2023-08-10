create or replace PROCEDURE TTEC_DELETE_EMPLOYEE_BENEFIT (errbuf                 OUT VARCHAR2,
                                                          retcode                OUT NUMBER,
                                                          p_employee_number      IN NUMBER,
                                                          p_validate             IN VARCHAR2
                                                          )
IS

/***********************************************************************************
     Program Name: TTEC_DELETE_EMPLOYEE_BENEFIT

     Description : This program is designed for INC5462746. It deletes all the benefit enrollment records of the employee whose employee_number is entered by User.
                   Its useful in case any corrupt / incorrect benefit data is inserted in the tables.

     Called By   : TTEC Delete Employee Benefit

     Created by  : Arpita Shukla & Tulika Saxena

     Date        : December 14, 2019
	    Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    IXPRAVEEN(ARGANO)            1.0     19-May-2023     R12.2 Upgrade Remediation

*/

v_person_id per_all_people_f.person_id%type;
t1  Number;
t2  Number;
t3  Number;
t4  Number;
t5  Number;
t6  Number;
t7  Number;
t8  Number;
t9  Number;
t10 Number;
t11 Number;
t12 Number;
t13 Number;
t14 Number;
t15 Number;
t16 Number;
t17 Number;
t18 Number;
t19 Number;
t20 Number;
t21 Number;
t22 Number;
t23 Number;


begin

select person_id into v_person_id
from per_all_people_f
where employee_number = p_employee_number
and trunc(sysdate) between effective_start_date and effective_end_date;

select count(*)
into t1
--from hr.PAY_ELEMENT_ENTRIES_F					-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
from apps.PAY_ELEMENT_ENTRIES_F                 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
where assignment_id in
(select assignment_id
from per_all_assignments_f
where person_id = v_person_id)
and creator_type = 'F' and creator_id in
--START R12.2 Upgrade Remediation
/*(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id			-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id			--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));

select count(*)
into t2
--from ben.ben_prtt_prem_by_mo_f			-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
from apps.ben_prtt_prem_by_mo_f              --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
where prtt_prem_id in
--(select prtt_prem_id from ben.ben_prtt_prem_f			-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_prem_id from apps.ben_prtt_prem_f          --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
 where prtt_enrt_rslt_id in
 --START R12.2 Upgrade Remediation
 /*(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id				-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
 and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
 (select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id					--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
 and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
 --END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id))
);



select count(*)
into t3
--from ben.ben_prtt_prem_f		-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
from apps.ben_prtt_prem_f       --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
where prtt_enrt_rslt_id in
 --START R12.2 Upgrade Remediation
/*(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id				-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id				--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));



select count(*)
into t4
 --START R12.2 Upgrade Remediation
/*from ben.ben_prtt_rt_val where prtt_enrt_rslt_id in											-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_prtt_rt_val where prtt_enrt_rslt_id in											--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));

select count(*)
into t5
 --START R12.2 Upgrade Remediation
/*from ben.ben_bnft_prvdd_ldgr_f where prtt_enrt_rslt_id in									-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_bnft_prvdd_ldgr_f where prtt_enrt_rslt_id in									--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


select count(*)
into t6
 --START R12.2 Upgrade Remediation
/*from ben.ben_prtt_enrt_actn_f where prtt_enrt_rslt_id in										-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_prtt_enrt_actn_f where prtt_enrt_rslt_id in										--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


select count(*)
into t7
 --START R12.2 Upgrade Remediation
/*from ben.ben_prtt_enrt_actn_f where elig_cvrd_dpnt_id in									-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select elig_cvrd_dpnt_id from ben.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben_ler_f ler*/
from apps.ben_prtt_enrt_actn_f where elig_cvrd_dpnt_id in									--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select elig_cvrd_dpnt_id from apps.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id)));


select count(*)
into t8
 --START R12.2 Upgrade Remediation
/*from ben.ben_prtt_enrt_actn_f where pl_bnf_id in												-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select pl_bnf_id from ben.ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_prtt_enrt_actn_f where pl_bnf_id in												--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select pl_bnf_id from apps.ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id)));


select count(*)
into t9
 --START R12.2 Upgrade Remediation
/*from ben.ben_prtt_enrt_ctfn_prvdd_f where prtt_enrt_rslt_id in										-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_prtt_enrt_ctfn_prvdd_f where prtt_enrt_rslt_id in											--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


select count(*)
into t10
 --START R12.2 Upgrade Remediation
/*from ben.ben_cvrd_dpnt_ctfn_prvdd_f where elig_cvrd_dpnt_id in								-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select elig_cvrd_dpnt_id from ben.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_cvrd_dpnt_ctfn_prvdd_f where elig_cvrd_dpnt_id in									--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select elig_cvrd_dpnt_id from apps.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id)));


select count(*)
into t11
 --START R12.2 Upgrade Remediation
/*from ben.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in									-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in									--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


select count(*)
into t12
 --START R12.2 Upgrade Remediation
/*from ben.ben_elig_dpnt where per_in_ler_id in											-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_elig_dpnt where per_in_ler_id in											--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
where ler.ler_id=pil.ler_id
and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
and pil.person_id = v_person_id);


select count(*)
into t13
 --START R12.2 Upgrade Remediation
/*from ben.ben_pl_bnf_ctfn_prvdd_f where pl_bnf_id in								-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select pl_bnf_id from ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_pl_bnf_ctfn_prvdd_f where pl_bnf_id in								--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select pl_bnf_id from ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id)));


select count(*)
into t14
 --START R12.2 Upgrade Remediation
/*from ben.ben_pl_bnf_f where prtt_enrt_rslt_id in											-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_pl_bnf_f where prtt_enrt_rslt_id in											--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


select count(*)
into t15
--START R12.2 Upgrade Remediation
/*from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id								-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id								--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id);


select count(*)
into t16
--START R12.2 Upgrade Remediation
/*from ben.ben_per_cm_prvdd_f where per_cm_id in										-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select per_cm_id from ben.ben_per_cm_f where person_id = v_person_id);*/
from apps.ben_per_cm_prvdd_f where per_cm_id in											--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select per_cm_id from apps.ben_per_cm_f where person_id = v_person_id);
--END R12.2.12 Upgrade remediation


select count(*)
into t17
--START R12.2 Upgrade Remediation
/*from ben.ben_per_cm_trgr_f where per_cm_id in										-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select per_cm_id from ben.ben_per_cm_f where person_id = v_person_id);*/
from apps.ben_per_cm_trgr_f where per_cm_id in										--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select per_cm_id from apps.ben_per_cm_f where person_id = v_person_id);
--END R12.2.12 Upgrade remediation

select count(*)
into t18
--START R12.2 Upgrade Remediation
/*from ben.ben_per_cm_usg_f where per_cm_id in				-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select per_cm_id from ben.ben_per_cm_f where person_id = v_person_id);*/
from apps.ben_per_cm_usg_f where per_cm_id in				--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select per_cm_id from apps.ben_per_cm_f where person_id = v_person_id);
--END R12.2.12 Upgrade remediation

select count(*)
into t19
--from ben.ben_per_cm_f where person_id = v_person_id;				 -- Commented code by IXPRAVEEN-ARGANO,19-May-2023
from apps.ben_per_cm_f where person_id = v_person_id;                 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023


select count(*)
into t20
--START R12.2 Upgrade Remediation
/*from ben.ben_elig_per_opt_f where elig_per_id in								-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select elig_per_id from ben.ben_elig_per_f where person_id = v_person_id
and per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_elig_per_opt_f where elig_per_id in								--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select elig_per_id from apps.ben_elig_per_f where person_id = v_person_id
and per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


select count(*)
into t21
--START R12.2 Upgrade Remediation
/*from ben.ben_elig_per_f where person_id = v_person_id								-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_elig_per_f where person_id = v_person_id								--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id);


select count(*)
into t22
--START R12.2 Upgrade Remediation
/*from ben.ben_per_in_ler where person_id = v_person_id										  -- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
from apps.ben_per_in_ler where person_id = v_person_id											--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,ben.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id);


select count(*)
into t23
--START R12.2 Upgrade Remediation
/*from ben.ben_ptnl_ler_for_per where person_id = v_person_id									  -- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and PTNL_LER_FOR_PER_ID in (select PTNL_LER_FOR_PER_ID from ben.ben_ptnl_ler_for_per ptnl,ben.ben_ler_f ler*/
from apps.ben_ptnl_ler_for_per where person_id = v_person_id											--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and PTNL_LER_FOR_PER_ID in (select PTNL_LER_FOR_PER_ID from apps.ben_ptnl_ler_for_per ptnl,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
where ler.ler_id=ptnl.ler_id
      and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
      and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
      and person_id = v_person_id );

if  p_validate = 'N' then

begin

--delete from hr.PAY_ELEMENT_ENTRIES_F					-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
delete from apps.PAY_ELEMENT_ENTRIES_F                    --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
where assignment_id in
(select assignment_id
from per_all_assignments_f
where person_id = v_person_id)
and creator_type = 'F' and creator_id in
--START R12.2 Upgrade Remediation
/*(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id			-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id			--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));

--delete from ben.ben_prtt_prem_by_mo_f				-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
delete from apps.ben_prtt_prem_by_mo_f               --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
where prtt_prem_id in
--(select prtt_prem_id from ben.ben_prtt_prem_f				-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_prem_id from apps.ben_prtt_prem_f               --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
 where prtt_enrt_rslt_id in
 --START R12.2 Upgrade Remediation
 /*(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id				-- Commented code by IXPRAVEEN-ARGANO,19-May-2023	
 and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
 (select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id					 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
 and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
 --END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id))
);



--delete from ben.ben_prtt_prem_f			-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
delete from apps.ben_prtt_prem_f            --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
where prtt_enrt_rslt_id in
--START R12.2 Upgrade Remediation
/*(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id						-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id					--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_prtt_rt_val where prtt_enrt_rslt_id in										-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_prtt_rt_val where prtt_enrt_rslt_id in											 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));

--START R12.2 Upgrade Remediation
/*delete from ben.ben_bnft_prvdd_ldgr_f where prtt_enrt_rslt_id in									-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_bnft_prvdd_ldgr_f where prtt_enrt_rslt_id in									 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_prtt_enrt_actn_f where prtt_enrt_rslt_id in									-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_prtt_enrt_actn_f where prtt_enrt_rslt_id in									 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_prtt_enrt_actn_f where elig_cvrd_dpnt_id in									-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select elig_cvrd_dpnt_id from ben.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben_ler_f ler*/
delete from apps.ben_prtt_enrt_actn_f where elig_cvrd_dpnt_id in									 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select elig_cvrd_dpnt_id from apps.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id)));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_prtt_enrt_actn_f where pl_bnf_id in											-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select pl_bnf_id from ben.ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_prtt_enrt_actn_f where pl_bnf_id in											 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select pl_bnf_id from apps.ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id)));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_prtt_enrt_ctfn_prvdd_f where prtt_enrt_rslt_id in								-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_prtt_enrt_ctfn_prvdd_f where prtt_enrt_rslt_id in								 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_cvrd_dpnt_ctfn_prvdd_f where elig_cvrd_dpnt_id in									-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select elig_cvrd_dpnt_id from ben.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_cvrd_dpnt_ctfn_prvdd_f where elig_cvrd_dpnt_id in									 --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select elig_cvrd_dpnt_id from apps.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id)));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in										-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in										 --  code Added by IXPRAVEEN-ARGANO,   19-May-20
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_elig_dpnt where per_in_ler_id in													-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_elig_dpnt where per_in_ler_id in													 --  code Added by IXPRAVEEN-ARGANO,   19-May-20
(select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
where ler.ler_id=pil.ler_id
and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
and pil.person_id = v_person_id);


--START R12.2 Upgrade Remediation
/*delete from ben.ben_pl_bnf_ctfn_prvdd_f where pl_bnf_id in														-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select pl_bnf_id from ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_pl_bnf_ctfn_prvdd_f where pl_bnf_id in															--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select pl_bnf_id from ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id)));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_pl_bnf_f where prtt_enrt_rslt_id in														-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select prtt_enrt_rslt_id from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_pl_bnf_f where prtt_enrt_rslt_id in													  --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select prtt_enrt_rslt_id from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_prtt_enrt_rslt_f pen where person_id = v_person_id										-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_prtt_enrt_rslt_f pen where person_id = v_person_id											--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and pen.per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id);


--START R12.2 Upgrade Remediation
/*delete from ben.ben_per_cm_prvdd_f where per_cm_id in														-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select per_cm_id from ben.ben_per_cm_f where person_id = v_person_id);*/
delete from apps.ben_per_cm_prvdd_f where per_cm_id in														--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select per_cm_id from apps.ben_per_cm_f where person_id = v_person_id);
--END R12.2.12 Upgrade remediation


--START R12.2 Upgrade Remediation
/*delete from ben.ben_per_cm_trgr_f where per_cm_id in										-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select per_cm_id from ben.ben_per_cm_f where person_id = v_person_id);*/
delete from apps.ben_per_cm_trgr_f where per_cm_id in										--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select per_cm_id from apps.ben_per_cm_f where person_id = v_person_id);
--END R12.2.12 Upgrade remediation


--START R12.2 Upgrade Remediation
/*delete from ben.ben_per_cm_usg_f where per_cm_id in												-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select per_cm_id from ben.ben_per_cm_f where person_id = v_person_id);*/
delete from apps.ben_per_cm_usg_f where per_cm_id in												--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select per_cm_id from apps.ben_per_cm_f where person_id = v_person_id);
--END R12.2.12 Upgrade remediation


--delete from ben.ben_per_cm_f where person_id = v_person_id;								-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
delete from apps.ben_per_cm_f where person_id = v_person_id;								--  code Added by IXPRAVEEN-ARGANO,   19-May-2023



--START R12.2 Upgrade Remediation
/*delete from ben.ben_elig_per_opt_f where elig_per_id in									-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
(select elig_per_id from ben.ben_elig_per_f where person_id = v_person_id
and per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_elig_per_opt_f where elig_per_id in									--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
(select elig_per_id from apps.ben_elig_per_f where person_id = v_person_id
and per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id));


--START R12.2 Upgrade Remediation
/*delete from ben.ben_elig_per_f where person_id = v_person_id											-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_elig_per_f where person_id = v_person_id											--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id);


--START R12.2 Upgrade Remediation
/*delete from ben.ben_per_in_ler where person_id = v_person_id													-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and per_in_ler_id in (select per_in_ler_id from ben.ben_per_in_ler pil,ben.ben_ler_f ler*/
delete from apps.ben_per_in_ler where person_id = v_person_id													--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and per_in_ler_id in (select per_in_ler_id from apps.ben_per_in_ler pil,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
            where ler.ler_id=pil.ler_id
            and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
            and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
            and pil.person_id = v_person_id);


--START R12.2 Upgrade Remediation
/*delete from ben.ben_ptnl_ler_for_per where person_id = v_person_id														-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
and PTNL_LER_FOR_PER_ID in (select PTNL_LER_FOR_PER_ID from ben.ben_ptnl_ler_for_per ptnl,ben.ben_ler_f ler*/
delete from apps.ben_ptnl_ler_for_per where person_id = v_person_id															--  code Added by IXPRAVEEN-ARGANO,   19-May-2023
and PTNL_LER_FOR_PER_ID in (select PTNL_LER_FOR_PER_ID from apps.ben_ptnl_ler_for_per ptnl,apps.ben_ler_f ler
--END R12.2.12 Upgrade remediation
where ler.ler_id=ptnl.ler_id
      and trunc(sysdate) between ler.effective_start_date and ler.effective_end_date
      and ler.typ_cd not in ('GSP','IREC', 'COMP', 'ABS')
      and person_id = v_person_id );

commit;

fnd_file.put_line (fnd_file.LOG, 'For employee number '||p_employee_number||':');
fnd_file.put_line (fnd_file.LOG, t1 ||' records deleted from table PAY_ELEMENT_ENTRIES_F') ;
fnd_file.put_line (fnd_file.LOG, t2 ||' records deleted from table ben_prtt_prem_by_mo_f') ;
fnd_file.put_line (fnd_file.LOG, t3 ||' records deleted from table ben_prtt_rt_val' );
fnd_file.put_line (fnd_file.LOG, t5 ||' records deleted from table ben_bnft_prvdd_ldgr_f');
fnd_file.put_line (fnd_file.LOG, t6 ||' records deleted from table ben_prtt_enrt_actn_f');
fnd_file.put_line (fnd_file.LOG, t7 ||' records deleted from table ben_prtt_enrt_actn_f');
fnd_file.put_line (fnd_file.LOG, t8 ||' records deleted from table ben_prtt_enrt_actn_f');
fnd_file.put_line (fnd_file.LOG, t9 ||' records deleted from table ben_prtt_enrt_ctfn_prvdd_f' );
fnd_file.put_line (fnd_file.LOG, t10 ||' records deleted from table ben_cvrd_dpnt_ctfn_prvdd_f');
fnd_file.put_line (fnd_file.LOG, t11 ||' records deleted from table ben_elig_cvrd_dpnt_f' );
fnd_file.put_line (fnd_file.LOG, t12 ||' records deleted from table ben_elig_dpnt' );
fnd_file.put_line (fnd_file.LOG, t13 ||' records deleted from table ben_pl_bnf_ctfn_prvdd_f');
fnd_file.put_line (fnd_file.LOG, t14 ||' records deleted from table ben_pl_bnf_f');
fnd_file.put_line (fnd_file.LOG, t15 ||' records deleted from table ben_prtt_enrt_rslt_f');
fnd_file.put_line (fnd_file.LOG, t16 ||' records deleted from table ben_per_cm_prvdd_f');
fnd_file.put_line (fnd_file.LOG, t17 ||' records deleted from table ben_per_cm_trgr_f');
fnd_file.put_line (fnd_file.LOG, t18 ||' records deleted from table ben_per_cm_usg_f');
fnd_file.put_line (fnd_file.LOG, t19 ||' records deleted from table ben_per_cm_f');
fnd_file.put_line (fnd_file.LOG, t20 ||' records deleted from table ben_elig_per_opt_f');
fnd_file.put_line (fnd_file.LOG, t21 ||' records deleted from table ben_elig_per_f');
fnd_file.put_line (fnd_file.LOG, t22 ||' records deleted from table ben_per_in_ler');
fnd_file.put_line (fnd_file.LOG, t23 ||' records deleted from table ben_ptnl_ler_for_per');


end;

elsif p_validate = 'Y' then

begin

fnd_file.put_line (fnd_file.LOG, 'For employee number '||p_employee_number||':');
fnd_file.put_line (fnd_file.LOG, t1 ||' records to be deleted from table PAY_ELEMENT_ENTRIES_F') ;
fnd_file.put_line (fnd_file.LOG, t2 ||' records to be deleted from table ben_prtt_prem_by_mo_f') ;
fnd_file.put_line (fnd_file.LOG, t3 ||' records to be deleted from table ben_prtt_rt_val' );
fnd_file.put_line (fnd_file.LOG, t5 ||' records to be deleted from table ben_bnft_prvdd_ldgr_f');
fnd_file.put_line (fnd_file.LOG, t6 ||' records to be deleted from table ben_prtt_enrt_actn_f');
fnd_file.put_line (fnd_file.LOG, t7 ||' records to be deleted from table ben_prtt_enrt_actn_f');
fnd_file.put_line (fnd_file.LOG, t8 ||' records to be deleted from table ben_prtt_enrt_actn_f');
fnd_file.put_line (fnd_file.LOG, t9 ||' records to be deleted from table ben_prtt_enrt_ctfn_prvdd_f' );
fnd_file.put_line (fnd_file.LOG, t10 ||' records to be deleted from table ben_cvrd_dpnt_ctfn_prvdd_f');
fnd_file.put_line (fnd_file.LOG, t11 ||' records to be deleted from table ben_elig_cvrd_dpnt_f' );
fnd_file.put_line (fnd_file.LOG, t12 ||' records to be deleted from table ben_elig_dpnt' );
fnd_file.put_line (fnd_file.LOG, t13 ||' records to be deleted from table ben_pl_bnf_ctfn_prvdd_f');
fnd_file.put_line (fnd_file.LOG, t14 ||' records to be deleted from table ben_pl_bnf_f');
fnd_file.put_line (fnd_file.LOG, t15 ||' records to be deleted from table ben_prtt_enrt_rslt_f');
fnd_file.put_line (fnd_file.LOG, t16 ||' records to be deleted from table ben_per_cm_prvdd_f');
fnd_file.put_line (fnd_file.LOG, t17 ||' records to be deleted from table ben_per_cm_trgr_f');
fnd_file.put_line (fnd_file.LOG, t18 ||' records to be deleted from table ben_per_cm_usg_f');
fnd_file.put_line (fnd_file.LOG, t19 ||' records to be deleted from table ben_per_cm_f');
fnd_file.put_line (fnd_file.LOG, t20 ||' records to be deleted from table ben_elig_per_opt_f');
fnd_file.put_line (fnd_file.LOG, t21 ||' records to be deleted from table ben_elig_per_f');
fnd_file.put_line (fnd_file.LOG, t22 ||' records to be deleted from table ben_per_in_ler');
fnd_file.put_line (fnd_file.LOG, t23 ||' records to be deleted from table ben_ptnl_ler_for_per');

end;

end if;

exception

when others then

fnd_file.put_line (fnd_file.LOG, 'Error while Deleting -- '
                 || SQLERRM);

end;
/
show errors;
/