create or replace procedure      TT_PAYCARD
                          (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER,
                           P_OUTPUT_DIR IN VARCHAR2,
						   P_BEGIN_DATE IN VARCHAR2 )  is
						   
						   
						   
						   
						   
 /************************************************************************************
        Program Name:     TT_PAYCARD

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI(ARGANO)            1.0      30-JUN-2023      R12.2 Upgrade Remediation
    ****************************************************************************************/						   
						   
						   
						   
						   
						   
						   
						   

-- Global Variables ---------------------------------------------------------------------------------
l_emp_output 	VARCHAR2(2000);
--l_module_name   CUST.TTEC_error_handling.module_name%type := 'PAYCARD';  --code commented by RXNETHI-ARGANO,30/06/23
l_module_name   APPS.TTEC_error_handling.module_name%type := 'PAYCARD';    --code added by RXNETHI-ARGANO,30/06/23

-- Variables used by Common Error Procedure
/*
START R12.2 Upgrade Remediation
code commented by RXNETHI-ARGANO,30/06/23
g_application_code          CUST.TTEC_error_handling.application_code%TYPE := 'PYC';
g_interface                 CUST.TTEC_error_handling.interface%TYPE := 'PAYCARD';
g_program_name              CUST.TTEC_error_handling.program_name%TYPE := 'PAYCARD';
g_initial_status            CUST.TTEC_error_handling.status%TYPE := 'INITIAL';
g_warning_status            CUST.TTEC_error_handling.status%TYPE := 'WARNING';
g_failure_status            CUST.TTEC_error_handling.status%TYPE := 'FAILURE';
*/
--code added by RXNETHI-ARGANO,30/06/23
g_application_code          APPS.TTEC_error_handling.application_code%TYPE := 'PYC';
g_interface                 APPS.TTEC_error_handling.interface%TYPE := 'PAYCARD';
g_program_name              APPS.TTEC_error_handling.program_name%TYPE := 'PAYCARD';
g_initial_status            APPS.TTEC_error_handling.status%TYPE := 'INITIAL';
g_warning_status            APPS.TTEC_error_handling.status%TYPE := 'WARNING';
g_failure_status            APPS.TTEC_error_handling.status%TYPE := 'FAILURE';
--END R12.2 Upgrade Remediation

-- Filehandle Variables

p_FileName VARCHAR2(50)   := 'TE096.24116.PS00012.'||to_char(sysdate, 'MMDDYYYY')||'.txt';
v_daily_file UTL_FILE.FILE_TYPE;


-----------------------------------------------------------------------------------------------------
-- Cursor declarations ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
CURSOR c_emp_data IS
SELECT DISTINCT
  SUBSTR(f.segment3, 6,10) CARD_NUMBER,
  TRANSLATE(UPPER(c.national_identifier),
                '_, .!?:;''"()[]{}<>-+=*/\$#%&^@|'||chr(9)||chr(10),
                ' ') SOCIAL,
  UPPER(SUBSTR(c.first_name,1,15)) FIRST_NAME,
  UPPER(SUBSTR(c.last_name,1,15)) LAST_NAME,
  TRANSLATE(UPPER(SUBSTR(e.attribute2,1,15)),
                '_, .!?:;''"()[]{}<>-+=*/\$#%&^@|'||chr(9)||chr(10),
                ' ') CODEWORD
FROM
  apps.per_all_assignments_f a, apps.pay_personal_payment_methods_f b,
  apps.per_all_people_f c, apps.per_person_types d,
  apps.pay_personal_payment_methods_f e, apps.pay_external_accounts f
WHERE
  a.assignment_id = b.assignment_id
  AND a.person_id = c.person_id
  AND c.person_type_id = d.person_type_id
  AND d.system_person_type IN ('EMP','EMP_APL')
  AND a.primary_flag = 'Y'
  AND a.assignment_id = e.assignment_id
  AND e.external_account_id = f.external_account_id
  AND e.effective_start_date >= P_BEGIN_DATE
  AND f.segment4 = '064102397'
ORDER BY
  UPPER(SUBSTR(c.last_name,1,15));

BEGIN

-- Opening file
  v_daily_file := UTL_FILE.FOPEN(P_OUTPUT_DIR, p_FileName, 'w');

    FOR rec_emp IN  c_emp_data LOOP

	 BEGIN


        l_emp_output :=
		       ('TE096' --account number
                || rpad('24116',10)  --customer id
                || rpad(' ',10)  --discretionary data
                || rpad(' ',9)	--Tracking Number
				|| rpad('24116',10)  --Cust id
                || rpad('00242912',25) --Security Code
                || nvl(rpad(rec_emp.card_number,10),rpad(' ',10)) --Card Number
                || rpad(' ',10) --Trip Number
                || nvl(rpad(rec_emp.social,16),rpad(' ',16)) --Employee Number
                || 'A'  --Status
				|| nvl(rpad(rec_emp.FIRST_NAME,15),rpad(' ',15)) --First Name
                || nvl(rpad(rec_emp.LAST_NAME,20),rpad(' ',20)) --Last Name
				|| nvl(rpad(rec_emp.CODEWORD,20),rpad(' ',20)) -- Drivers License Number
				|| rpad(' ',2) --Drivers License State
				|| rpad(' ',6) --Unit Number
				|| rpad(' ',4) --Reserved
				|| rpad(' ',10) --Trailer Number
				|| 'Y'  --Express Cash Flag
                || 'Y'  --Phone Service
                || 'Y'  --Company Standards Flag
				|| rpad(' ',8) --Phone Limit
				|| rpad(' ',9) --Phone Renew Flags
                || 'E'  --ATM Access Flags
				|| ' '  --Voice Mail Flags
				|| ' '  --Fax Mail Flag
				|| ' '  --Conference Call Flag
				|| ' '  --Message Services Flag
				|| ' '  --Information Services Flag
                || 'Y'  --VRU Access Flag
                || rpad(' ',4)	--Reserved2
                || 'E'  --Maestro POS
				|| rpad(' ',8)	--Purchase limit amt
				|| ' '	--Purchase Limit Reset daily
				|| rpad(' ',7)	--PL reset weekdays
				|| ' '	--PL reset one time
                || rpad(' ',8)	--PL one time amount
				|| rpad(' ',8)	--cash limit amount
				|| ' '	--cash limit reset daily
     			|| rpad(' ',7)	--cash limit reset weekdays
				|| ' '	--cash limit reset one time
    			|| rpad(' ',8)	--cash limit one time amount
    			|| rpad(' ',10)	--transfer to card number
				);

        utl_file.put_line(v_daily_file, l_emp_output);

      END;

    END LOOP;

	utl_file.put_line(v_daily_file, '**FTP');

  UTL_FILE.FCLOSE(v_daily_file);

EXCEPTION
 WHEN UTL_FILE.INVALID_OPERATION THEN
		UTL_FILE.FCLOSE(v_daily_file);
		RAISE_APPLICATION_ERROR(-20051, p_FileName ||':  Invalid Operation');
  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
		UTL_FILE.FCLOSE(v_daily_file);
		RAISE_APPLICATION_ERROR(-20052, p_FileName ||':  Invalid File Handle');
  WHEN UTL_FILE.READ_ERROR THEN
		UTL_FILE.FCLOSE(v_daily_file);
		RAISE_APPLICATION_ERROR(-20053, p_FileName ||':  Read Error');
  WHEN UTL_FILE.INVALID_PATH THEN
		UTL_FILE.FCLOSE(v_daily_file);
		RAISE_APPLICATION_ERROR(-20054, p_FileName ||':  Invalid Path');
  WHEN UTL_FILE.INVALID_MODE THEN
		UTL_FILE.FCLOSE(v_daily_file);
		RAISE_APPLICATION_ERROR(-20055, p_FileName ||':  Invalid Mode');
  WHEN UTL_FILE.WRITE_ERROR THEN
		UTL_FILE.FCLOSE(v_daily_file);
		RAISE_APPLICATION_ERROR(-20056, p_FileName ||':  Write Error');
  WHEN UTL_FILE.INTERNAL_ERROR THEN
		UTL_FILE.FCLOSE(v_daily_file);
		RAISE_APPLICATION_ERROR(-20057, p_FileName ||':  Internal Error');
  WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
		UTL_FILE.FCLOSE(v_daily_file);
		RAISE_APPLICATION_ERROR(-20058, p_FileName ||':  Maxlinesize Error');
  WHEN OTHERS THEN
		UTL_FILE.FCLOSE(v_daily_file);
        --CUST.TTEC_PROCESS_ERROR (g_application_code, g_interface, g_program_name, l_module_name,  --code commented by RXNETHI-ARGANO,30/06/23
        APPS.TTEC_PROCESS_ERROR (g_application_code, g_interface, g_program_name, l_module_name,    --code added by RXNETHI-ARGANO,30/06/23
                         'FAILURE', SQLCODE, SQLERRM);
		COMMIT;
		RAISE;

END;
/
show errors;
/