create or replace PROCEDURE TELETECHPROFILES
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

(ERRBUF VARCHAR2, RETCODE NUMBER)
AS
fileid UTL_FILE.FILE_TYPE;


BEGIN

--		  The below file location is an absolute location and will need to be changed as servers and environments change.
	   fileid := utl_file.FOPEN('/export/home/prod/d01/oracle/prodappl/teletech/11.5.0/data/BenefitInterface', 'teletechprofiles.csv', 'w');
	  FOR getUserInfo IN (
	SELECT DISTINCT
		PAPF.EMPLOYEE_NUMBER ORACLEID,
		NVL (PAPF.FIRST_NAME,PAPF.LAST_NAME) FIRSTNAME,
		PAPF.LAST_NAME LASTNAME,
		PAPF.MIDDLE_NAMES MIDDLENAME,
		PAPF.EMAIL_ADDRESS EMAIL,
		PAPF.CURRENT_EMPLOYEE_FLAG STATUS,
		SUBSTR (PJ.NAME, INSTR(PJ.NAME, '.')+1) TITLE,
		SUBSTR(PAAF.EMPLOYMENT_CATEGORY, 0,1) FULL_PART_TIME,
		PAPF1.EMPLOYEE_NUMBER SUPERID,
		nvl(PCAK.SEGMENT2,'9500') CLIENTID,
		FFVV.DESCRIPTION CLIENT,
		NVL(HLA.ATTRIBUTE2,'01050') LOCATIONID,
		HLA.LOCATION_CODE LOCATION,
		NVL(PCAK1.SEGMENT3,'005') DEPARTMENTID,
		HAOU.NAME DEPARTMENT
	FROM
	     --START R12.2 Upgrade Remediation
	  /*
	    	Commented code by MXKEERTHI-ARGANO, 05/19/2023
 		HR.PER_ALL_PEOPLE_F PAPF,
		HR.PER_ALL_ASSIGNMENTS_F PAAF,
		HR.PER_ALL_PEOPLE_F PAPF1,
		HR.HR_LOCATIONS_ALL HLA,
		HR.PAY_COST_ALLOCATION_KEYFLEX PCAK,
		HR.PAY_COST_ALLOCATION_KEYFLEX PCAK1,
		HR.PAY_COST_ALLOCATIONS_F PCAF,
		APPS.FND_FLEX_VALUES_VL FFVV,
		HR.HR_ALL_ORGANIZATION_UNITS HAOU,
		HR.PER_JOBS PJ
	   */
	  --code Added  by MXKEERTHI-ARGANO, 05/19/2023
		apps.PER_ALL_PEOPLE_F PAPF,
		apps.PER_ALL_ASSIGNMENTS_F PAAF,
		apps.PER_ALL_PEOPLE_F PAPF1,
		apps.HR_LOCATIONS_ALL HLA,
		apps.PAY_COST_ALLOCATION_KEYFLEX PCAK,
		apps.PAY_COST_ALLOCATION_KEYFLEX PCAK1,
		apps.PAY_COST_ALLOCATIONS_F PCAF,
		APPS.FND_FLEX_VALUES_VL FFVV,
		apps.HR_ALL_ORGANIZATION_UNITS HAOU,
		apps.PER_JOBS PJ
	  --END R12.2.10 Upgrade remediation


	WHERE
		PAPF.PERSON_ID = PAAF.PERSON_ID
		AND PAAF.SUPERVISOR_ID = PAPF1.PERSON_ID(+)
		AND PAPF.CURRENT_EMPLOYEE_FLAG IN ( 'Y', 'L' ) -- comment #1
		AND PAPF.BUSINESS_GROUP_ID NOT IN ( 0 )
		AND PAAF.PRIMARY_FLAG = 'Y'
		AND PAPF1.EFFECTIVE_END_DATE(+) = '31-DEC-4712'
		AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
		AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
		AND SYSDATE BETWEEN PCAF.EFFECTIVE_START_DATE AND PCAF.EFFECTIVE_END_DATE
		AND PCAF.EFFECTIVE_END_DATE(+) = '31-DEC-4712'
		AND PAAF.LOCATION_ID = HLA.LOCATION_ID
		AND PAAF.ASSIGNMENT_ID = PCAF.ASSIGNMENT_ID(+)
		AND PCAF.COST_ALLOCATION_KEYFLEX_ID = PCAK.COST_ALLOCATION_KEYFLEX_ID(+)
		and pcak.cost_allocation_keyflex_id = (select max (cost_allocation_keyflex_id)
		      --from HR.PAY_COST_ALLOCATIONS_F x where x.assignment_id = paaf.assignment_id --Commented code by MXKEERTHI-ARGANO, 05/19/2023
		    from APPS.PAY_COST_ALLOCATIONS_F x where x.assignment_id = paaf.assignment_id --code added by MXKEERTHI-ARGANO, 05/19/2023
			and SYSDATE BETWEEN X.EFFECTIVE_START_DATE AND X.EFFECTIVE_END_DATE)
		AND nvl(PCAK.SEGMENT2,'9500') = FFVV.FLEX_VALUE_MEANING(+)
		AND PAAF.JOB_ID = PJ.JOB_ID
		AND FFVV.FLEX_VALUE_SET_ID(+) = '1002611'
		AND PAAF.ORGANIZATION_ID = HAOU.ORGANIZATION_ID
	  	AND HAOU.COST_ALLOCATION_KEYFLEX_ID = PCAK1.COST_ALLOCATION_KEYFLEX_ID(+)
	ORDER BY 3,2)
LOOP
	utl_file.PUT_LINE(fileid, (getUserInfo.ORACLEID||'|'||
	getUserInfo.FIRSTNAME ||'|'||
	getUserInfo.LASTNAME ||'|'||
	getUserInfo.MIDDLENAME || '|' ||
	getUserInfo.EMAIL ||'|'||
	getUserInfo.STATUS ||'|'||
	getUserInfo.TITLE ||'|'||
	getUserInfo.FULL_PART_TIME ||'|'||
	getUserInfo.SUPERID ||'|'||
	getUserInfo.CLIENTID ||'|'||
	getUserInfo.CLIENT ||'|'||
	getUserInfo.LOCATIONID ||'|'||
	getUserInfo.LOCATION ||'|'||
	getUserInfo.DEPARTMENTID ||'|'||
	getUserInfo.DEPARTMENT
	  	   ));
END LOOP;
	       		 utl_file.FCLOSE(fileid);


EXCEPTION
  WHEN utl_file.invalid_path THEN
	   RAISE_APPLICATION_ERROR(-20000, 'utl_file.invalid_path');
  WHEN utl_file.invalid_mode THEN
       RAISE_APPLICATION_ERROR(-20001, 'utl_file.invalid_mode');
  WHEN utl_file.invalid_filehandle THEN
       RAISE_APPLICATION_ERROR(-20001, 'utl_file.invalid_filehandle');
  WHEN utl_file.invalid_operation THEN
       RAISE_APPLICATION_ERROR(-20001, 'utl_file.invalid_operation');
  WHEN utl_file.read_error THEN
  	   RAISE_APPLICATION_ERROR(-20001, 'utl_file.read_error');
  WHEN utl_file.write_error THEN
       RAISE_APPLICATION_ERROR(-20001, 'utl_file.write_error');
  WHEN utl_file.internal_error THEN
       RAISE_APPLICATION_ERROR(-20001, 'utl_file.internal_error');
  WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20001, 'utl_file.other_error');

END;
/
show errors;
/