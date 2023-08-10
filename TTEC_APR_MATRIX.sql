create or replace PROCEDURE      ttec_apr_matrix ( errbuf OUT VARCHAR2,
                                           retcode OUT NUMBER)
IS
/*
-- Program Name:  ttec_apr_matrix
--
-- Description:  This program generates matrix report for North America Purchase Requisition Approval Matrix - Finance
--
-- Called From:   TeleTech PR Approval Group Matrix (N/A)
--
-- Input/Output Parameters:
--
--
--
-- Tables Modified:  N/A
--
--
-- Created By:  Elango Pandurangan
-- Date: Mar 22 2009
--
-- Modification Log:
-- Developer        Date        Description
-- ----------       --------    --------------------------------------------------------------------
	IXPRAVEEN(ARGANO)            1.0     19-May-2023     R12.2 Upgrade Remediation

*/

CURSOR c_main IS
   SELECT DISTINCT segment1_low||' '||ffv.description Location, ttec_apr_grp(segment1_low,1) low,ttec_apr_grp(segment1_low,2) mid,ttec_apr_grp(segment1_low,3) hgh
   --a.control_group_id,  a.amount_limit,
      --FROM po.po_control_rules a			-- Commented code by IXPRAVEEN-ARGANO,19-May-2023
      FROM apps.po_control_rules a            --  code Added by IXPRAVEEN-ARGANO,   19-May-2023
         , po_control_groups_all b--, po_control_groups b
         , fnd_flex_values_vl ffv
     WHERE a.control_group_id = b.control_group_id
       AND a.object_code = 'ACCOUNT_RANGE'
       AND a.rule_type_code = 'INCLUDE'
       AND ffv.flex_value = segment1_low
       AND ffv.enabled_flag = 'Y'
       AND b.attribute10 IS NOT NULL
AND segment1_low IN
('01010',
'01011',
'01012',
'01013',
'01020',
'01045',
'01047',
'01049',
'01051',
'01053',
'01066',
'01068',
'01067',
'01071',
'01069',
'01070',
'01072',
'01098',
'01110',
'01111',
'01115',
'01117',
'01122',
'01202',
'01210',
'01251',
'01252',
'01254',
'01270',
'01271',
'01300',
'01310',
'01350',
'01351',
'01352',
'01353',
'01570',
'01572',
'01600',
'01610',
'01620',
'01630',
'01800',
'01810',
'01811',
'01054',
'01055',
'01056',
'01057',
'01058',
'01059',
'01060',
'01061',
'01062',
'01063',
'01064',
'01065',
'01080',
'01081',
'01082',
'01083',
'01084',
'01085',
'01086',
'01087',
'01090',
'05255',
'05300',
'05320',
'05321',
'05322',
'05323',
'05324',
'05325',
'05326',
'05330',
'05331',
'05332',
'05335',
'05336',
'05337',
'05338',
'05339',
'05340',
'05341',
'02200',
'02201',
'02215')
ORDER BY 1;

BEGIN

  Fnd_File.PUT_LINE (  Fnd_File.output,' <html> <body>');
  Fnd_File.PUT_LINE (  Fnd_File.output, ' <h2 align="center"> North America Purchase Requisition Approval Matrix - Finance </h2>');
  Fnd_File.PUT_LINE (  Fnd_File.output, ' <table border="1"> ');
  Fnd_File.PUT_LINE (  Fnd_File.output, ' <tr><th> Location </th><th> </th><th> Approvers </th><th> </th></tr> ');
  Fnd_File.PUT_LINE (  Fnd_File.output, '<tr><th>  </th><th> $0-$100K </th><th> $100K+ </th><th> $250K+ </th></tr>');




   FOR v_main IN c_main LOOP

   Fnd_File.PUT_LINE (  Fnd_File.output, '<tr><td>'||v_main.location||'</td><td>'||v_main.low||'</td><td>'||v_main.mid||'</td><td>'||v_main.hgh||'</td></tr>');


   END LOOP;

   Fnd_File.PUT_LINE (  Fnd_File.output, '</table>');

  Fnd_File.PUT_LINE (  Fnd_File.output, '</body></html>');

EXCEPTION
  WHEN OTHERS THEN
  NULL;
END ttec_apr_matrix;
/
show errors;
/