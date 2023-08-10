create or replace PROCEDURE ttec_po_open_rpt (
 /************************************************************************************
        Program Name: ttec_po_open_rpt

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
   MXKEERTHI(ARGANO)  19-May-2023           1.0          R12.2 Upgrade Remediation
    ****************************************************************************************/
 
    retcode   OUT NUMBER,
    errbuf    OUT VARCHAR2,
     p_from_creation_date   IN VARCHAR2,
    p_to_creation_date     IN VARCHAR2,
    P_STATUS IN VARCHAR2
) AS

    v_header             VARCHAR2(4000);
    v_stat               NUMBER := 0;
    v_mesg               VARCHAR2(256);
    v_code               NUMBER;
    v_errm               VARCHAR2(255);
    v_columns_str        VARCHAR2(4000);
    v_cur_flag           BOOLEAN := true;
    v_del_file_flag      BOOLEAN := false;
    v_data_exists_flag   BOOLEAN := true;
	v_approver_count     NUMBER :=0;						--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
    CURSOR cur_po_open IS
        ( SELECT DISTINCT
            poh.po_header_id,
            pol.po_line_id,
            prd.distribution_id,
            hrp2.local_name AS preparer_name,
            hrp.local_name AS approver_name,
            poh.segment1 AS po_num,
            prh.segment1 AS pr_code,
			prh.requisition_header_id,						--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
            poh.creation_date,
         --   trunc(rsh.creation_date) po_last_receive_date,
		 (SELECT trunc(creation_date) FROM rcv_shipment_headers rsh
WHERE  rsh.shipment_header_id = (
                    SELECT
                        MAX(shipment_header_id)
                    FROM
                        rcv_shipment_lines
                    WHERE
                        po_header_id = poh.po_header_id)
) po_last_receive_date	,
          --  check_date ap_last_payment_date,
(select check_date from apps.ap_checks_all apc
where  apc.check_id = (
                    SELECT
                        MAX(check_id)
                    FROM
                        ap_invoice_payments_all
                    WHERE
                        invoice_id = aia.invoice_id)) ap_last_payment_date,
            poh.authorization_status,
            poll.closed_code,
            poll.closed_reason,
            aps.vendor_id,
            aps.vendor_name,
            --pol.item_description,
            poh.currency_code,
            pol.unit_price,
            ( pol.unit_price * pod.quantity_ordered ) AS dist_line_total_cost,
            pod.quantity_ordered,
            pod.quantity_delivered,
            pod.quantity_billed,
            aia.invoice_id,
            ( prl.unit_price * prl.quantity ) req_amount,
            pod.set_of_books_id,
            (
                SELECT
                    name
                FROM
                    gl_ledgers
                WHERE
                    ledger_id = pod.set_of_books_id
            ) AS ledger_name,
            cd.segment1 AS location,
            cd.segment2 AS client,
            cd.segment3 AS department,
            cd.segment4 AS account,
            cd.segment5 AS ic,
            cd.segment6 AS future,
	(SELECT SUM(NVL(unit_price,0)* NVL(quantity,0)) po_amount FROM po_lines_all l WHERE l.po_header_id = poh.po_header_id) TOTAL_PO_AMT		--Added by Vaibhav 10-DEC-2019 to provide PO Amount
	,(SELECT full_name FROM per_all_people_f P WHERE person_id=prl.to_person_id AND SYSDATE BETWEEN effective_start_date AND effective_end_date) requestor		--Added by Vaibhav on 20-DEC-2019 for adding Approver Logic
	,(SELECT APPROVER
FROM por_approval_status_lines_v WHERE document_id=prh.requisition_header_id AND APPROVAL_STATUS='SUBMIT'     AND SEQUENCE_NUM=(SELECT MIN(SEQUENCE_NUM) FROM por_approval_status_lines_v WHERE  APPROVAL_STATUS='SUBMIT' AND document_id=prh.requisition_header_id)) submitted		--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
	 ,(SELECT LISTAGG(APPROVER, '~ ') WITHIN GROUP (ORDER BY SEQUENCE_NUM )
FROM por_approval_status_lines_v WHERE document_id=prh.requisition_header_id AND APPROVAL_STATUS='APPROVE')  approvers
        FROM
		    --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
            po.po_headers_all poh,
            po.po_lines_all pol,
            po.po_distributions_all pod,
            ap.ap_suppliers aps,
            po.po_agents poa,
            gl.gl_code_combinations cd,
            po.po_line_locations_all poll,
            po.po_requisition_headers_all prh,
            po.po_requisition_lines_all prl,
            po.po_req_distributions_all prd,
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
            APPS.po_headers_all poh,
            APPS.po_lines_all pol,
            APPS.po_distributions_all pod,
            APPS.ap_suppliers aps,
            APPS.po_agents poa,
            APPS.gl_code_combinations cd,
            APPS.po_line_locations_all poll,
            APPS.po_requisition_headers_all prh,
            APPS.po_requisition_lines_all prl,
            APPS.po_req_distributions_all prd,
	  --END R12.2.10 Upgrade remediation


            (
                SELECT DISTINCT
                    person_id,
                    local_name,
					effective_start_date, --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
					effective_end_date	  --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
                FROM
                    per_all_people_f
                WHERE
                    local_name NOT IN (
                        'Meneses,Evarista'
                    )
            ) hrp,
            (
                SELECT DISTINCT
                    person_id,
                    local_name,
					effective_start_date, --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
					effective_end_date	  --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
                FROM
                    per_all_people_f
                WHERE
                    local_name NOT IN (
                        'Meneses,Evarista'
                    )
            ) hrp2,
            ap_invoice_distributions_all aid,
            ap_invoices_all aia
          --  rcv_shipment_headers rsh,
          --  ap_checks_all apc
        WHERE
                1 = 1                   --and poh.PO_HEADER_ID =5488671
            AND
                poh.po_header_id = pol.po_header_id
            AND
                pol.po_line_id = pod.po_line_id
            AND
                poh.vendor_id = aps.vendor_id
            AND
                poh.agent_id = poa.agent_id
            AND
                poa.agent_id = hrp.person_id
            AND
                pod.code_combination_id = cd.code_combination_id
            AND
                poh.po_header_id = poll.po_header_id
            AND
                pol.po_line_id = poll.po_line_id
            AND
                pod.req_distribution_id = prd.distribution_id
            AND
                prd.requisition_line_id = prl.requisition_line_id
            AND
                prl.requisition_header_id = prh.requisition_header_id
            AND
                prh.preparer_id = hrp2.person_id
            AND
                pod.po_distribution_id = aid.po_distribution_id
            AND
                aia.invoice_id = aid.invoice_id
       --     AND
         --       line_type_lookup_code = 'ITEM'
         /*   AND
                rsh.shipment_header_id = (
                    SELECT
                        MAX(shipment_header_id)
                    FROM
                        rcv_shipment_lines
                    WHERE
                        po_header_id = poh.po_header_id
                )
            AND
                apc.check_id = (
                    SELECT
                        MAX(check_id)
                    FROM
                        ap_invoice_payments_all
                    WHERE
                        invoice_id = aia.invoice_id
                ) */
             AND
			 poll.closed_code NOT IN (
                    'FINALLY CLOSED','CANCELLED'
                )
				 and poll.closed_code=DECODE(P_STATUS,'ALL',poll.CLOSED_CODE,
                                    P_STATUS)
            AND
                trunc(poh.creation_date) BETWEEN nvl(
                    fnd_date.canonical_to_date (p_from_creation_date),
                    TO_DATE(
                        poh.creation_date,
                        'DD-MON-RR'
                    )
                ) AND
                    NVL (fnd_date.canonical_to_date (p_to_creation_date),
                    TO_DATE(
                        poh.creation_date,
                        'DD-MON-RR'
                    )
                )
               -- and poh.segment1=:PO_NUM
	--		AND  poh.creation_date BETWEEN hrp.effective_start_date AND  hrp.effective_end_date				--Added by Vaibhav 10-DEC-2019 to avoid duplicate records
    --            AND  poh.creation_date BETWEEN hrp2.effective_start_date AND  hrp2.effective_end_date
              --  and poh.segment1=:PO_NUM
				/*   AND
                trunc(poh.creation_date) BETWEEN to_date('01-APR-2018','DD-MON-YYYY')
                 AND to_date('01-AUG-2020','DD-MON-YYYY')
				 and poh.segment1='680001'*/
		UNION
		SELECT DISTINCT
            poh.po_header_id,
            pol.po_line_id,
            prd.distribution_id,
            hrp2.local_name AS preparer_name,
            hrp.local_name AS approver_name,
            poh.segment1 AS po_num,
            prh.segment1 AS pr_code,
			prh.requisition_header_id,						--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
            poh.creation_date,
         --   trunc(rsh.creation_date) po_last_receive_date,
		 (SELECT trunc(creation_date) FROM rcv_shipment_headers rsh
WHERE  rsh.shipment_header_id = (
                    SELECT
                        MAX(shipment_header_id)
                    FROM
                        rcv_shipment_lines
                    WHERE
                        po_header_id = poh.po_header_id)
) po_last_receive_date	,
          --  check_date ap_last_payment_date,
NULL ap_last_payment_date,	-- No Payment as there is no invoice link
            poh.authorization_status,
            poll.closed_code,
            poll.closed_reason,
            aps.vendor_id,
            aps.vendor_name,
            --pol.item_description,
            poh.currency_code,
            pol.unit_price,
            ( pol.unit_price * pod.quantity_ordered ) AS dist_line_total_cost,
            pod.quantity_ordered,
            pod.quantity_delivered,
            pod.quantity_billed,
            null invoice_id, -- made NULL AS THERE IS NO AP invoices table link
            ( prl.unit_price * prl.quantity ) req_amount,
            pod.set_of_books_id,
            (
                SELECT
                    name
                FROM
                    gl_ledgers
                WHERE
                    ledger_id = pod.set_of_books_id
            ) AS ledger_name,
            cd.segment1 AS location,
            cd.segment2 AS client,
            cd.segment3 AS department,
            cd.segment4 AS account,
            cd.segment5 AS ic,
            cd.segment6 AS future,
	(SELECT SUM(NVL(unit_price,0)* NVL(quantity,0)) po_amount FROM po_lines_all l WHERE l.po_header_id = poh.po_header_id) TOTAL_PO_AMT		--Added by Vaibhav 10-DEC-2019 to provide PO Amount
	,(SELECT full_name FROM per_all_people_f P WHERE person_id=prl.to_person_id AND SYSDATE BETWEEN effective_start_date AND effective_end_date) requestor		--Added by Vaibhav on 20-DEC-2019 for adding Approver Logic
	,(SELECT APPROVER
FROM por_approval_status_lines_v WHERE document_id=prh.requisition_header_id AND APPROVAL_STATUS='SUBMIT'     AND SEQUENCE_NUM=(SELECT MIN(SEQUENCE_NUM) FROM por_approval_status_lines_v WHERE  APPROVAL_STATUS='SUBMIT' AND document_id=prh.requisition_header_id)) submitted		--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
	 ,(SELECT LISTAGG(APPROVER, '~ ') WITHIN GROUP (ORDER BY SEQUENCE_NUM )
FROM por_approval_status_lines_v WHERE document_id=prh.requisition_header_id AND APPROVAL_STATUS='APPROVE')  approvers
        FROM
		    --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
             po.po_headers_all poh,
            po.po_lines_all pol,
            po.po_distributions_all pod,
            ap.ap_suppliers aps,
            po.po_agents poa,
            gl.gl_code_combinations cd,
            po.po_line_locations_all poll,
            po.po_requisition_headers_all prh,
            po.po_requisition_lines_all prl,
            po.po_req_distributions_all prd,
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
            APPS.po_headers_all poh,
            APPS.po_lines_all pol,
            APPS.po_distributions_all pod,
            APPS.ap_suppliers aps,
            APPS.po_agents poa,
            APPS.gl_code_combinations cd,
            APPS.po_line_locations_all poll,
            APPS.po_requisition_headers_all prh,
            APPS.po_requisition_lines_all prl,
            APPS.po_req_distributions_all prd,
	  --END R12.2.10 Upgrade remediation


            (
                SELECT DISTINCT
                    person_id,
                    local_name,
					effective_start_date, --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
					effective_end_date	  --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
                FROM
                    per_all_people_f
                WHERE
                    local_name NOT IN (
                        'Meneses,Evarista'
                    )
            ) hrp,
            (
                SELECT DISTINCT
                    person_id,
                    local_name,
					effective_start_date, --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
					effective_end_date	  --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
                FROM
                    per_all_people_f
                WHERE
                    local_name NOT IN (
                        'Meneses,Evarista'
                    )
            ) hrp2
         --   ap_invoice_distributions_all aid,
         --   ap_invoices_all aia,
        --    rcv_shipment_headers rsh
        --    ap_checks_all apc
        WHERE
                1 = 1                   --and poh.PO_HEADER_ID =5488671
            AND
                poh.po_header_id = pol.po_header_id
            AND
                pol.po_line_id = pod.po_line_id
            AND
                poh.vendor_id = aps.vendor_id
            AND
                poh.agent_id = poa.agent_id
            AND
                poa.agent_id = hrp.person_id
            AND
                pod.code_combination_id = cd.code_combination_id
            AND
                poh.po_header_id = poll.po_header_id
            AND
                pol.po_line_id = poll.po_line_id
            AND
                pod.req_distribution_id = prd.distribution_id
            AND
                prd.requisition_line_id = prl.requisition_line_id
            AND
                prl.requisition_header_id = prh.requisition_header_id
            AND
                prh.preparer_id = hrp2.person_id
         --   AND
         --       pod.po_distribution_id(+) = aid.po_distribution_id
         --   AND
          --      aia.invoice_id = aid.invoice_id(+)
          --  AND
            --    line_type_lookup_code = 'ITEM'

      /*      AND
                apc.check_id = (
                    SELECT
                        MAX(check_id)
                    FROM
                        ap_invoice_payments_all
                    WHERE
                        invoice_id = aia.invoice_id
                )*/
            AND
			 poll.closed_code NOT IN (
                    'FINALLY CLOSED','CANCELLED'
                )
				 and poll.closed_code=DECODE(P_STATUS,'ALL',poll.CLOSED_CODE,
                                    P_STATUS)
				 AND
                trunc(poh.creation_date) BETWEEN nvl(
                    fnd_date.canonical_to_date (p_from_creation_date),
                    TO_DATE(
                        poh.creation_date,
                        'DD-MON-RR'
                    )
                ) AND
                    NVL (fnd_date.canonical_to_date (p_to_creation_date),
                    TO_DATE(
                        poh.creation_date,
                        'DD-MON-RR'
                    )
                )
            AND NOT EXISTS
                (SELECT 1 FROM AP_INVOICE_DISTRIBUTIONS_ALL aid
                WHERE pod.po_distribution_id = aid.po_distribution_id)
              --  and poh.segment1=:PO_NUM
            UNION
            SELECT DISTINCT
            poh.po_header_id,
            pol.po_line_id,
         --   prd.distribution_id,
           null distribution_id,
          --  hrp2.local_name AS preparer_name,
           null preparer_name,
            hrp.local_name AS approver_name,
            poh.segment1 AS po_num,
        --    prh.segment1 AS pr_code,
              NULL AS pr_code,
		--	prh.requisition_header_id,	--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
             NULL AS requisition_header_id,
            poh.creation_date,
         --   trunc(rsh.creation_date) po_last_receive_date,
		 (SELECT trunc(creation_date) FROM rcv_shipment_headers rsh
WHERE  rsh.shipment_header_id = (
                    SELECT
                        MAX(shipment_header_id)
                    FROM
                        rcv_shipment_lines
                    WHERE
                        po_header_id = poh.po_header_id)
) po_last_receive_date	,
          --  check_date ap_last_payment_date,
(select check_date from apps.ap_checks_all apc
where  apc.check_id = (
                    SELECT
                        MAX(check_id)
                    FROM
                        ap_invoice_payments_all
                    WHERE
                        invoice_id = aia.invoice_id)) ap_last_payment_date,
            poh.authorization_status,
            poll.closed_code,
            poll.closed_reason,
            aps.vendor_id,
            aps.vendor_name,
            --pol.item_description,
            poh.currency_code,
            pol.unit_price,
            ( pol.unit_price * pod.quantity_ordered ) AS dist_line_total_cost,
            pod.quantity_ordered,
            pod.quantity_delivered,
            pod.quantity_billed,
            aia.invoice_id,
        --    ( prl.unit_price * prl.quantity ) req_amount,
            NULL req_amount,
            pod.set_of_books_id,
            (
                SELECT
                    name
                FROM
                    gl_ledgers
                WHERE
                    ledger_id = pod.set_of_books_id
            ) AS ledger_name,
            cd.segment1 AS location,
            cd.segment2 AS client,
            cd.segment3 AS department,
            cd.segment4 AS account,
            cd.segment5 AS ic,
            cd.segment6 AS future,
	(SELECT SUM(NVL(unit_price,0)* NVL(quantity,0)) po_amount
    FROM po_lines_all l WHERE l.po_header_id = poh.po_header_id) TOTAL_PO_AMT,		--Added by Vaibhav 10-DEC-2019 to provide PO Amount
	/*,(SELECT full_name FROM per_all_people_f P WHERE person_id=prl.to_person_id
    AND SYSDATE BETWEEN effective_start_date AND effective_end_date) requestor	*/	--Added by Vaibhav on 20-DEC-2019 for adding Approver Logic
  null requestor,
/*	,(SELECT APPROVER
FROM por_approval_status_lines_v WHERE document_id=prh.requisition_header_id AND APPROVAL_STATUS='SUBMIT'
AND SEQUENCE_NUM=(SELECT MIN(SEQUENCE_NUM) FROM por_approval_status_lines_v WHERE
APPROVAL_STATUS='SUBMIT' AND document_id=prh.requisition_header_id)) submitted	*/	--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
	 null submitted
    /* ,(SELECT LISTAGG(APPROVER, '~ ') WITHIN GROUP (ORDER BY SEQUENCE_NUM )
FROM por_approval_status_lines_v WHERE document_id=prh.requisition_header_id AND APPROVAL_STATUS='APPROVE')  approvers*/
    , null approvers
	    --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
         FROM
            po.po_headers_all poh,
            po.po_lines_all pol,
            po.po_distributions_all pod,
            ap.ap_suppliers aps,
            po.po_agents poa,
            gl.gl_code_combinations cd,
            po.po_line_locations_all poll,
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
        FROM
            APPS.po_headers_all poh,
            APPS.po_lines_all pol,
            APPS.po_distributions_all pod,
            APPS.ap_suppliers aps,
            APPS.po_agents poa,
            APPS.gl_code_combinations cd,
            APPS.po_line_locations_all poll,
	  --END R12.2.10 Upgrade remediation


         /*   po.po_requisition_headers_all prh,
            po.po_requisition_lines_all prl,
            po.po_req_distributions_all prd, */
            (
                SELECT DISTINCT
                    person_id,
                    local_name,
					effective_start_date, --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
					effective_end_date	  --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
                FROM
                    per_all_people_f
                WHERE
                    local_name NOT IN (
                        'Meneses,Evarista'
                    )
            ) hrp,
         /*   (
                SELECT DISTINCT
                    person_id,
                    local_name,
					effective_start_date, --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
					effective_end_date	  --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
                FROM
                    per_all_people_f
                WHERE
                    local_name NOT IN (
                        'Meneses,Evarista'
                    )
            ) hrp2,*/
            ap_invoice_distributions_all aid,
            ap_invoices_all aia
          --  rcv_shipment_headers rsh,
          --  ap_checks_all apc
        WHERE
                1 = 1                   --and poh.PO_HEADER_ID =5488671
            AND
                poh.po_header_id = pol.po_header_id
            AND
                pol.po_line_id = pod.po_line_id
            AND
                poh.vendor_id = aps.vendor_id
            AND
                poh.agent_id = poa.agent_id
            AND
                poa.agent_id = hrp.person_id
            AND
                pod.code_combination_id = cd.code_combination_id
            AND
                poh.po_header_id = poll.po_header_id
            AND
                pol.po_line_id = poll.po_line_id
            AND  pod.req_distribution_id is null
           /*     pod.req_distribution_id = prd.distribution_id
            AND
                prd.requisition_line_id = prl.requisition_line_id
            AND
                prl.requisition_header_id = prh.requisition_header_id
            AND
                prh.preparer_id = hrp2.person_id*/
            AND
                pod.po_distribution_id = aid.po_distribution_id
            AND
                aia.invoice_id = aid.invoice_id
         --   AND
           --     line_type_lookup_code = 'ITEM'
         /*   AND
                rsh.shipment_header_id = (
                    SELECT
                        MAX(shipment_header_id)
                    FROM
                        rcv_shipment_lines
                    WHERE
                        po_header_id = poh.po_header_id
                )
            AND
                apc.check_id = (
                    SELECT
                        MAX(check_id)
                    FROM
                        ap_invoice_payments_all
                    WHERE
                        invoice_id = aia.invoice_id
                ) */
             AND
			 poll.closed_code NOT IN (
                    'FINALLY CLOSED','CANCELLED'
                )
				 and poll.closed_code=DECODE(P_STATUS,'ALL',poll.CLOSED_CODE,
                                    P_STATUS)
            AND
                trunc(poh.creation_date) BETWEEN nvl(
                    fnd_date.canonical_to_date (p_from_creation_date),
                    TO_DATE(
                        poh.creation_date,
                        'DD-MON-RR'
                    )
                ) AND
                    NVL (fnd_date.canonical_to_date (p_to_creation_date),
                    TO_DATE(
                        poh.creation_date,
                        'DD-MON-RR'
                    )
                )
             --   and poh.segment1=:PO_NUM
	--		AND  poh.creation_date BETWEEN hrp.effective_start_date AND  hrp.effective_end_date				--Added by Vaibhav 10-DEC-2019 to avoid duplicate records
    --            AND  poh.creation_date BETWEEN hrp2.effective_start_date AND  hrp2.effective_end_date
              --  and poh.segment1=:PO_NUM
				/*   AND
                trunc(poh.creation_date) BETWEEN to_date('01-APR-2018','DD-MON-YYYY')
                 AND to_date('01-AUG-2020','DD-MON-YYYY')
				 and poh.segment1='680001'*/
		UNION
		SELECT DISTINCT
            poh.po_header_id,
            pol.po_line_id,
          --  prd.distribution_id,
             null distribution_id,
          --  hrp2.local_name AS preparer_name,
            null preparer_name,
            hrp.local_name AS approver_name,
          --  poh.segment1 AS po_num,
            null po_num,
         --   prh.segment1 AS pr_code,
            null pr_code,
		--	prh.requisition_header_id,						--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
            null requisition_header_id,
            poh.creation_date,
         --   trunc(rsh.creation_date) po_last_receive_date,
		 (SELECT trunc(creation_date) FROM rcv_shipment_headers rsh
WHERE  rsh.shipment_header_id = (
                    SELECT
                        MAX(shipment_header_id)
                    FROM
                        rcv_shipment_lines
                    WHERE
                        po_header_id = poh.po_header_id)
) po_last_receive_date	,
          --  check_date ap_last_payment_date,
NULL ap_last_payment_date,	-- No Payment as there is no invoice link
            poh.authorization_status,
            poll.closed_code,
            poll.closed_reason,
            aps.vendor_id,
            aps.vendor_name,
            --pol.item_description,
            poh.currency_code,
            pol.unit_price,
            ( pol.unit_price * pod.quantity_ordered ) AS dist_line_total_cost,
            pod.quantity_ordered,
            pod.quantity_delivered,
            pod.quantity_billed,
            null invoice_id, -- made NULL AS THERE IS NO AP invoices table link
          --  ( prl.unit_price * prl.quantity ) req_amount,
          null req_amount,
            pod.set_of_books_id,
            (
                SELECT
                    name
                FROM
                    gl_ledgers
                WHERE
                    ledger_id = pod.set_of_books_id
            ) AS ledger_name,
            cd.segment1 AS location,
            cd.segment2 AS client,
            cd.segment3 AS department,
            cd.segment4 AS account,
            cd.segment5 AS ic,
            cd.segment6 AS future,
	(SELECT SUM(NVL(unit_price,0)* NVL(quantity,0)) po_amount FROM po_lines_all l
    WHERE l.po_header_id = poh.po_header_id) TOTAL_PO_AMT		--Added by Vaibhav 10-DEC-2019 to provide PO Amount
/*	,(SELECT full_name FROM per_all_people_f P WHERE person_id=prl.to_person_id AND
    SYSDATE BETWEEN effective_start_date AND effective_end_date) requestor		*/--Added by Vaibhav on 20-DEC-2019 for adding Approver Logic
	, null requestor
  /*  ,(SELECT APPROVER
FROM por_approval_status_lines_v WHERE document_id=prh.requisition_header_id AND APPROVAL_STATUS='SUBMIT'
AND SEQUENCE_NUM=(SELECT MIN(SEQUENCE_NUM) FROM por_approval_status_lines_v
WHERE  APPROVAL_STATUS='SUBMIT' AND document_id=prh.requisition_header_id)) submitted	*/	--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
	, null submitted
    /* ,(SELECT LISTAGG(APPROVER, '~ ') WITHIN GROUP (ORDER BY SEQUENCE_NUM )
FROM por_approval_status_lines_v WHERE document_id=prh.requisition_header_id AND APPROVAL_STATUS='APPROVE')  approvers*/
    , null approvers
	    --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
         FROM
            po.po_headers_all poh,
            po.po_lines_all pol,
            po.po_distributions_all pod,
            ap.ap_suppliers aps,
            po.po_agents poa,
            gl.gl_code_combinations cd,
            po.po_line_locations_all poll,
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
        FROM
            APPS.po_headers_all poh,
            APPS.po_lines_all pol,
            APPS.po_distributions_all pod,
            APPS.ap_suppliers aps,
            APPS.po_agents poa,
            APPS.gl_code_combinations cd,
            APPS.po_line_locations_all poll,
	  --END R12.2.10 Upgrade remediation


         /*   po.po_requisition_headers_all prh,
            po.po_requisition_lines_all prl,
            po.po_req_distributions_all prd,*/
            (
                SELECT DISTINCT
                    person_id,
                    local_name,
					effective_start_date, --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
					effective_end_date	  --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
                FROM
                    per_all_people_f
                WHERE
                    local_name NOT IN (
                        'Meneses,Evarista'
                    )
            ) hrp
       /*     (
                SELECT DISTINCT
                    person_id,
                    local_name,
					effective_start_date, --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
					effective_end_date	  --Added by Vaibhav 10-DEC-2019 to avoid duplicate records
                FROM
                    per_all_people_f
                WHERE
                    local_name NOT IN (
                        'Meneses,Evarista'
                    )
            ) hrp2*/
         --   ap_invoice_distributions_all aid,
         --   ap_invoices_all aia,
        --    rcv_shipment_headers rsh
        --    ap_checks_all apc
        WHERE
                1 = 1                   --and poh.PO_HEADER_ID =5488671
            AND
                poh.po_header_id = pol.po_header_id
            AND
                pol.po_line_id = pod.po_line_id
            AND
                poh.vendor_id = aps.vendor_id
            AND
                poh.agent_id = poa.agent_id
            AND
                poa.agent_id = hrp.person_id
            AND
                pod.code_combination_id = cd.code_combination_id
            AND
                poh.po_header_id = poll.po_header_id
            AND
                pol.po_line_id = poll.po_line_id
            AND pod.req_distribution_id is null
           /* AND
                pod.req_distribution_id = prd.distribution_id
            AND
                prd.requisition_line_id = prl.requisition_line_id
            AND
                prl.requisition_header_id = prh.requisition_header_id
            AND
                prh.preparer_id = hrp2.person_id */
         --   AND
         --       pod.po_distribution_id(+) = aid.po_distribution_id
         --   AND
          --      aia.invoice_id = aid.invoice_id(+)
          --  AND
            --    line_type_lookup_code = 'ITEM'

      /*      AND
                apc.check_id = (
                    SELECT
                        MAX(check_id)
                    FROM
                        ap_invoice_payments_all
                    WHERE
                        invoice_id = aia.invoice_id
                )*/
            AND
			 poll.closed_code NOT IN (
                    'FINALLY CLOSED','CANCELLED'
                )
				 and poll.closed_code=DECODE(P_STATUS,'ALL',poll.CLOSED_CODE,
                                    P_STATUS)
				 AND
                trunc(poh.creation_date) BETWEEN nvl(
                    fnd_date.canonical_to_date (p_from_creation_date),
                    TO_DATE(
                        poh.creation_date,
                        'DD-MON-RR'
                    )
                ) AND
                    NVL (fnd_date.canonical_to_date (p_to_creation_date),
                    TO_DATE(
                        poh.creation_date,
                        'DD-MON-RR'
                    )
                )
            AND NOT EXISTS
                (SELECT 1 FROM AP_INVOICE_DISTRIBUTIONS_ALL aid
                WHERE pod.po_distribution_id = aid.po_distribution_id)
               -- and poh.segment1=:PO_NUM;
                );
				--cur_po_open


BEGIN
    BEGIN
        --v_header := 'PO_HEADER_ID~PO_LINE_ID~DISTRIBUTION_ID~PREPARER_NAME~APPROVER_NAME~PO_NUM~PR_CODE ~CREATION_DATE~ PO_LAST_RECEIVE_DATE~AP_LAST_PAYMENT_DATE~AUTHORIZATION_STATUS~ CLOSED_CODE~ CLOSED_REASON ~ VENDOR_ID ~ VENDOR_NAME ~ ITEM_DESCRIPTION~CURRENCY_CODE ~ UNIT_PRICE ~ DIST_LINE_TOTAL_COST ~ QUANTITY_ORDERED ~QUANTITY_DELIVERED ~ QUANTITY_BILLED ~ INVOICE_ID~REQ_AMOUNT ~TOTAL_PO_AMT ~SET_OF_BOOKS_ID~LEDGER_NAME~ LOCATION ~ CLIENT ~DEPARTMENT ~ ACCOUNT ~ IC ~FUTURE~BUSINESS_APPROVER1~Business_approver_action1~BUSINESS_APPROVER2~Business_approver_action2~BUSINESS_APPROVER3~Business_approver_action3~BUSINESS_APPROVER4~Business_approver_action4~BUSINESS_APPROVER5~Business_approver_action5~BUSINESS_APPROVER6~Business_approver_action6~BUSINESS_APPROVER7~Business_approver_action7'		--Modified by Vaibhav 10-DEC-2019 to provide PO Amount
       -- v_header := 'PO_HEADER_ID~PO_LINE_ID~DISTRIBUTION_ID~PREPARER_NAME~APPROVER_NAME~PO_NUM~PR_CODE ~CREATION_DATE~ PO_LAST_RECEIVE_DATE~AP_LAST_PAYMENT_DATE~AUTHORIZATION_STATUS~ CLOSED_CODE~ CLOSED_REASON ~ VENDOR_ID ~ VENDOR_NAME ~CURRENCY_CODE ~ UNIT_PRICE ~ DIST_LINE_TOTAL_COST ~ QUANTITY_ORDERED ~QUANTITY_DELIVERED ~ QUANTITY_BILLED ~ INVOICE_ID~REQ_AMOUNT ~TOTAL_PO_AMT ~SET_OF_BOOKS_ID~LEDGER_NAME~ LOCATION ~ CLIENT ~DEPARTMENT ~ ACCOUNT ~ IC ~FUTURE~BUSINESS_APPROVER1~Business_approver_action1~BUSINESS_APPROVER2~Business_approver_action2~BUSINESS_APPROVER3~Business_approver_action3~BUSINESS_APPROVER4~Business_approver_action4~BUSINESS_APPROVER5~Business_approver_action5~BUSINESS_APPROVER6~Business_approver_action6~BUSINESS_APPROVER7~Business_approver_action7'		--Modified by Vaibhav 10-DEC-2019 to provide PO Amount
		  v_header := 'PO_HEADER_ID~PO_LINE_ID~DISTRIBUTION_ID~PREPARER_NAME~APPROVER_NAME~PO_NUM~PR_CODE ~CREATION_DATE~ PO_LAST_RECEIVE_DATE~AP_LAST_PAYMENT_DATE~AUTHORIZATION_STATUS~ CLOSED_CODE~ CLOSED_REASON ~ VENDOR_ID ~ VENDOR_NAME ~CURRENCY_CODE ~ UNIT_PRICE ~ DIST_LINE_TOTAL_COST ~ QUANTITY_ORDERED ~QUANTITY_DELIVERED ~ QUANTITY_BILLED ~ INVOICE_ID~REQ_AMOUNT ~TOTAL_PO_AMT ~SET_OF_BOOKS_ID~LEDGER_NAME~ LOCATION ~ CLIENT ~DEPARTMENT ~ ACCOUNT ~ IC ~FUTURE~REQUESTED_BY~SUBMITTED_BY~BUSINESS_APPROVER1~BUSINESS_APPROVER2~BUSINESS_APPROVER3~BUSINESS_APPROVER4~BUSINESS_APPROVER5~BUSINESS_APPROVER6~BUSINESS_APPROVER7~BUSINESS_APPROVER8~BUSINESS_APPROVER9~BUSINESS_APPROVER10~BUSINESS_APPROVER11~BUSINESS_APPROVER12~BUSINESS_APPROVER13~BUSINESS_APPROVER14~BUSINESS_APPROVER15~BUSINESS_APPROVER16~BUSINESS_APPROVER17~BUSINESS_APPROVER18~BUSINESS_APPROVER19~BUSINESS_APPROVER20~BUSINESS_APPROVER21~BUSINESS_APPROVER22~BUSINESS_APPROVER23~BUSINESS_APPROVER24~BUSINESS_APPROVER25~BUSINESS_APPROVER26~BUSINESS_APPROVER27~BUSINESS_APPROVER28~BUSINESS_APPROVER29~BUSINESS_APPROVER30~BUSINESS_APPROVER31~BUSINESS_APPROVER32~BUSINESS_APPROVER33~BUSINESS_APPROVER34~BUSINESS_APPROVER35~BUSINESS_APPROVER36~BUSINESS_APPROVER37~BUSINESS_APPROVER38~BUSINESS_APPROVER39~BUSINESS_APPROVER40~BUSINESS_APPROVER41~BUSINESS_APPROVER42~BUSINESS_APPROVER43~BUSINESS_APPROVER44~BUSINESS_APPROVER45~BUSINESS_APPROVER46~BUSINESS_APPROVER47~BUSINESS_APPROVER48~BUSINESS_APPROVER49~BUSINESS_APPROVER50'		--Modified by Vaibhav 10-DEC-2019 to provide PO Amount

;
        fnd_file.put_line(
            fnd_file.output,
            v_header
        );
    EXCEPTION
        WHEN OTHERS THEN
            v_stat := 1;
            v_code := sqlcode;
            v_errm := substr(
                sqlerrm,
                1,
                255
            );
            fnd_file.put_line(
                fnd_file.log,
                'Exception in writing header to file ' || v_code || ':' || v_errm
            );

    END;

    BEGIN
        FOR cur_po_open_rec IN cur_po_open LOOP
            v_columns_str := NULL;


            v_columns_str := cur_po_open_rec.po_header_id
             || '~'
             || cur_po_open_rec.po_line_id
             || '~'
             || cur_po_open_rec.distribution_id
             || '~'
             || cur_po_open_rec.preparer_name
             || '~'
             || cur_po_open_rec.approver_name
             || '~'
             || cur_po_open_rec.po_num
             || '~'
             || cur_po_open_rec.pr_code
             || '~'
             || cur_po_open_rec.creation_date
             || '~'
             || cur_po_open_rec.po_last_receive_date
             || '~'
             || cur_po_open_rec.ap_last_payment_date
             || '~'
             || cur_po_open_rec.authorization_status
             || '~'
             || cur_po_open_rec.closed_code
             || '~'
             || cur_po_open_rec.closed_reason
             || '~'
             || cur_po_open_rec.vendor_id
             || '~'
             || cur_po_open_rec.vendor_name
             || '~'
             --|| cur_po_open_rec.item_description			--Commented by VAIBHAV as discussed with Daniel on mail dated on 12-Dec-19
             --|| '~'										--Commented by VAIBHAV as discussed with Daniel on mail dated on 12-Dec-19
             || cur_po_open_rec.currency_code
             || '~'
             || cur_po_open_rec.unit_price
             || '~'
             || cur_po_open_rec.dist_line_total_cost
             || '~'
             || cur_po_open_rec.quantity_ordered
             || '~'
             || cur_po_open_rec.quantity_delivered
             || '~'
             || cur_po_open_rec.quantity_billed
             || '~'
             || cur_po_open_rec.invoice_id
             || '~'
             || cur_po_open_rec.req_amount
             || '~'
			 || cur_po_open_rec.TOTAL_PO_AMT				--Added by VAIBHAV as discussed with Daniel on mail dated on 12-Dec-19
			 || '~'
             || cur_po_open_rec.set_of_books_id
             || '~'
             || cur_po_open_rec.ledger_name
             || '~'
             || cur_po_open_rec.location
             || '~'
             || cur_po_open_rec.client
             || '~'
             || cur_po_open_rec.department
             || '~'
             || cur_po_open_rec.account
             || '~'
             || cur_po_open_rec.ic
             || '~'
             || cur_po_open_rec.future
			 || '~'
			 --|| cur_po_open_rec.Business_Approver1
			 --|| '~'
			 --|| cur_po_open_rec.Business_app_action1
			 --|| '~'
			 --|| cur_po_open_rec.Business_Approver2
			 --|| '~'
			 --|| cur_po_open_rec.Business_app_action2
			 --|| '~'
			 --|| cur_po_open_rec.Business_Approver3
			 --|| '~'
			 --|| cur_po_open_rec.Business_app_action3
			 --|| '~'
			 --|| cur_po_open_rec.Business_Approver4
			 --|| '~'
			 --|| cur_po_open_rec.Business_app_action4
			 --|| '~'
			 --|| cur_po_open_rec.Business_Approver5
			 --|| '~'
			 --|| cur_po_open_rec.Business_app_action5
			 --|| '~'
			 --|| cur_po_open_rec.Business_Approver6
			 --|| '~'
			 --|| cur_po_open_rec.Business_app_action6
			 --|| '~'
			 --|| cur_po_open_rec.Business_Approver7
			 --|| '~'
			 --|| cur_po_open_rec.Business_app_action7
			 --|| '~'
			 ||  cur_po_open_rec.requestor			--Added by Vaibhav on 20-DEC-2019 for adding Approver Logic
			 || '~'
			 ||  cur_po_open_rec.submitted			--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
			 || '~'
			 ||  cur_po_open_rec.approvers			--Added by Vaibhav on 18-DEC-2019 for adding Approver Logic
			 || '~'
			  ;
         --FND_FILE.PUT_LINE(FND_FILE.LOG,'Before writing to the OUTPUT FILE ');

            fnd_file.put_line(
                fnd_file.output,
                v_columns_str
            );
            v_cur_flag := false;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            v_stat := 1;
            v_code := sqlcode;
            v_errm := substr(
                sqlerrm,
                1,
                255
            );
            fnd_file.put_line(
                fnd_file.log,
                'Exception in writing to file ' || v_code || ':' || v_errm
            );

    END;

EXCEPTION
    WHEN OTHERS THEN
        v_code := sqlcode;
        v_errm := substr(
            sqlerrm,
            1,
            255
        );
        fnd_file.put_line(
            fnd_file.log,
            'Exception in closing file : ' || v_code || ':' || v_errm
        );

END ttec_po_open_rpt;
/
show errors;
/