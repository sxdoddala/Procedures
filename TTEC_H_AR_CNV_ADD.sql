create or replace PROCEDURE TTEC_H_AR_CNV_ADD AS
  -- -----------------------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  -- Program Name  : TTEC_H_AR_CNV_ADD
  -- Author        : Arun Jayaraman
  -- Creation Date : 11/30/04
  -- Purpose       : Program to load TTEC Employee Address data from Legacy System
 /*---------------------------------------------------------------------------------------------
       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
   MXKEERTHI(ARGANO)  19-May-2023           1.0          R12.2 Upgrade Remediation
    ****************************************************************************************/
   
  -- -----------------------------------------------------------------------------
  -- -----------------------------------------------------------------------------
 v_person_id		        PER_ALL_PEOPLE_F.PERSON_ID%TYPE;
 V_employee_number		PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE;
 v_party_id			NUMBER;
 V_address_id			NUMBER;
 v_object_version_number	NUMBER;
 v_business_group_id		PER_ALL_PEOPLE_F.BUSINESS_GROUP_ID%TYPE;
 v_err_count 			NUMBER:=0;
 v_lerr_count			NUMBER:=0;
 v_addr_count			NUMBER:=0;
 v_proc_count 			NUMBER:=0;
 v_county			VARCHAR2(10);
 v_validate_county		BOOLEAN;
STATS				VARCHAR2(1)	:='S';
STATF				VARCHAR2(1)	:='F';
MODULE_NAME_CONST CONSTANT      VARCHAR2(40)    := 'CREATE ADDRESS';
               SYSTEM_USER_CONST CONSTANT                 VARCHAR2(40) 	:= 'TELETECH';
g_error_message			VARCHAR2(2000);
l_error_message			VARCHAR2(100);
l_tot_err_data					VARCHAR2(200);
l_tot_proc_data					VARCHAR2(200);
L_tot_succ_data					VARCHAR2(200);
e_log_file                      VARCHAR2(100);
e_log_file_name                 VARCHAR2(20)   := 'HR_ADD_AR_log_file_';
e_open_log_file                 Utl_File.FILE_TYPE;
v_address_line1 		varchar2(40)	;
v_address_line2 		varchar2(40)	;
v_address_line3 		varchar2(40)	;
v_town_or_city			varchar2(30)	;
-- ------------------------------------------------------------------------------------
CURSOR  t_add is
SELECT
	 a.EMP_NUM_LEGACY
	,a.EFFECTIVE_DATE
	,a.VALIDATE_COUNTY
	,a.PRIMARY_FLAG
	,a.STYLE
	,a.DATE_FROM
	,a.DATE_TO
	,a.ADDRESS_TYPE
	,a.COMMENTS
	,a.ADDRESS_LINE1
	,a.ADDRESS_LINE2
	,a.ADDRESS_LINE3
	,a.TOWN_OR_CITY
	,a.REGION_1
	,a.REGION_2
	,a.REGION_3
	,a.POSTAL_CODE
	,a.COUNTRY
	,a.TELEPHONE_NUMBER_1
	,a.TELEPHONE_NUMBER_2
	,a.TELEPHONE_NUMBER_3
--	,a.ADDR_ATTRIBUTE_CATEGORY
--	,a.ADDR_ATTRIBUTE1
--	,a.ADDR_ATTRIBUTE2
--	,a.ADDR_ATTRIBUTE3
--	,a.ADDR_ATTRIBUTE4
--	,a.ADDR_ATTRIBUTE5
--	,a.ADDR_ATTRIBUTE6
--	,a.ADDR_ATTRIBUTE7
--	,a.ADDR_ATTRIBUTE8
--	,a.ADDR_ATTRIBUTE9
--	,a.ADDR_ATTRIBUTE10
--	,a.ADDR_ATTRIBUTE11
--	,a.ADDR_ATTRIBUTE12
--	,a.ADDR_ATTRIBUTE13
	,a.ADDR_ATTRIBUTE14
	,a.ADDR_ATTRIBUTE15
	,a.ADDR_ATTRIBUTE16
--	,a.ADDR_ATTRIBUTE17
--	,a.ADDR_ATTRIBUTE18
--	,a.ADDR_ATTRIBUTE19
--	,a.ADDR_ATTRIBUTE20
--	,a.ADD_INFORMATION13
--	,a.ADD_INFORMATION14
--	,a.ADD_INFORMATION15
--	,a.ADD_INFORMATION16
--	,a.ADD_INFORMATION17
--	,a.ADD_INFORMATION18
--	,a.ADD_INFORMATION19
--	,a.ADD_INFORMATION20
	,c.person_id
	 --FROM  cust.ttec_h_ar_add a,   --Commented code by MXKEERTHI-ARGANO, 05/19/2023
FROM  apps.ttec_h_ar_add a,   --code added by MXKEERTHI-ARGANO, 05/19/2023
--	cust.ttec_h_ar_emp b, --Commented code by MXKEERTHI-ARGANO, 05/19/2023
	apps.ttec_h_ar_emp b, --code added by MXKEERTHI-ARGANO, 05/19/2023
	per_all_people_f c
WHERE address_id IS NULL
AND b.status='S'
AND a.emp_num_legacy=b.emp_num_legacy
AND b.person_id=c.person_id
AND b.new_employee_number IS NOT NULL
AND b.status = 'S' ;
BEGIN
/*
             DBMS_OUTPUT.ENABLE(1000000);
             dbms_output.put_line('Begin Statement');
               -- --------------------------------------------------------------------------------------------------
               --         Open Log file
               -- -----------------------------------------------
*/
e_open_log_file := ttec_conv_util.Open_Log_File(e_log_file_name);
/*
		l_error_message := 'Create Address Process - Argentina';
		apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                 ||'-- '||SYSTEM_USER_CONST);
*/
-- ----------------------------------------------------------------------
-- 		Load Data From temp table
-- ----------------------------------------------------------------------
FOR addrec IN t_add
LOOP
 apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
        || addrec.EMP_NUM_LEGACY ||'-'||' '||SYSTEM_USER_CONST);
		v_lerr_count			:=0;
		v_person_id			:= addrec.person_id;
		v_party_id			:= NULL;
		v_address_id			:= NULL;
		v_object_version_number 	:= NULL;

		v_address_line1 		:=null	;
		v_address_line2 		:=null	;
		v_address_line3 		:=null	;
		v_town_or_city			:=null	;
		v_address_line1	:=ltrim(rtrim(addrec.address_line1));
		v_address_line2	:=ltrim(rtrim(addrec.address_line2));
		v_address_line3	:=ltrim(rtrim(addrec.address_line3));


		v_town_or_city	:=ltrim(rtrim(addrec.town_or_city,' '));



 		l_error_message :='  Processing Address for employee  ';
			 apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                        || addrec.EMP_NUM_LEGACY ||'-'||' '||SYSTEM_USER_CONST);


--  ---------------------------------------------------------------------
--  		Validate the County
--  ---------------------------------------------------------------------
BEGIN
	IF ltrim(rtrim(addrec.validate_county))='Argentina'THEN
		v_validate_county := TRUE;
	ELSE
		v_validate_county :=FALSE;
	--	v_err_count := v_err_count+1;
	END IF;
END;
/*
-- -----------------------------------------------------------
--        Business Group ID
-- -----------------------------------------------------------
BEGIN
     SELECT business_group_id
  	 INTO   v_business_group_id
  	 FROM   hr_all_organization_units
  	 WHERE  name = 'TeleTech Holdings - ARZ';
	 EXCEPTION
 	 WHEN NO_DATA_FOUND THEN
	g_error_message := SQLERRM;
     	l_error_message := 'No Business group id ';
        apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
        || addrec.EMP_NUM_LEGACY ||'-'|| g_error_message||' '||SYSTEM_USER_CONST);
	 v_err_count:= v_err_count+1;
END;
*/
-- -------------------------------------------------------------
-- 		Retrieve New Employee Number
--  -------------------------------------------------------------
/*
BEGIN
		SELECT c.new_employee_number
		INTO   V_employee_number
		FROM   cust.ttec_h_ar_emp c
                WHERE addrec.emp_num_legacy=c.emp_num_legacy;
		-- AND business_group_id= 1590;
END;
*/
-- --------------------------------------------------------------
-- 		Get Person id and Effective Start date
-- --------------------------------------------------------------
/*
BEGIN
	SELECT    paf.person_id
   	INTO    v_person_id
   	FROM   PER_ALL_PEOPLE_F paf,
	       cust.ttec_h_ar_emp c
     	WHERE   paf.person_id=c.person_id
	AND	c.emp_num_legacy=addrec.emp_num_legacy
--	AND 	c.new_employee_number=v_employee_number
--	AND  business_group_id = 1590;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
	g_error_message := SQLERRM;
     	l_error_message := 'NO PERSON ID';
        apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
        || addrec.EMP_NUM_LEGACY ||'-'|| g_error_message||' '||SYSTEM_USER_CONST);
--	v_lerr_count := v_lerr_count+1;
 END;
*/
-- -------------------------------------------------------------
--             End of Validation Process
-- --------------------------------------------------------------
-- IF v_lerr_count = 0 THEN
--  IF v_err_count = 0 then
--  ---------------------------------------------------------
--   		Call Create Address API
--  ---------------------------------------------------------
BEGIN
	apps.HR_PERSON_ADDRESS_API.CREATE_PERSON_ADDRESS
	(
		p_validate			=>	FALSE
		,p_effective_date		=>	addrec.effective_date
		,p_pradd_ovlapval_override	=>	FALSE
		,p_validate_county		=>	v_validate_county
		,p_person_id			=>	v_person_id
		,p_primary_flag			=>	addrec.primary_flag
		,p_style			=>	addrec.style
		,p_date_from			=>	addrec.date_from
		,p_date_to			=>	addrec.date_to
		,p_address_type			=>	addrec.address_type
		,p_comments			=>	addrec.comments
		,p_address_line1		=>	v_address_line1
		,p_address_line2		=>	v_address_line2
		,P_address_line3		=>	v_address_line3
		,p_town_or_city			=>	v_town_or_city
		,p_region_1			=>	addrec.region_1
		,p_region_2			=>	addrec.region_2
		,P_region_3			=>	addrec.region_3
		,p_postal_code			=>	addrec.postal_code
	--	,p_country			=>	addrec.country
		,p_country			=>	'AR' 				-- test data hardcoded
		,p_telephone_number_1		=>	addrec.telephone_number_1
	--	,p_telephone_number_2		=>	addrec.telephone_number_2
	--	,p_telephone_number_3		=>	addrec.telephone_number_3
	--	,p_addr_attribute_category	=>	addrec.addr_attribute_category
	--	,p_addr_attribute_category	=>	null				-- test data hardcoded
	--	,p_addr_attribute1		=>	addrec.addr_attribute1
	--	,p_addr_attribute2		=>	addrec.addr_attribute2
	--	,p_addr_attribute3		=>	addrec.addr_attribute3
	--	,p_addr_attribute4		=>	addrec.addr_attribute4
	--	,p_addr_attribute5		=>	addrec.addr_attribute5
	--	,p_addr_attribute6		=>	addrec.addr_attribute6
	--	,p_addr_attribute7		=>	addrec.addr_attribute7
	--	,p_addr_attribute8		=>	addrec.addr_attribute8
	--	,p_addr_attribute9		=>	addrec.addr_attribute9
	--	,p_addr_attribute10		=>	addrec.addr_attribute10
	--	,p_addr_attribute11		=>	addrec.addr_attribute11
	--	,p_addr_attribute12		=>	addrec.addr_attribute12
	--	,p_addr_attribute13		=>	addrec.addr_attribute13
        --     	,p_addr_attribute14		=>	addrec.addr_attribute14
	--	,p_addr_attribute15		=>	addrec.addr_attribute15
	--	,p_addr_attribute16		=>	addrec.addr_attribute16
	--	,p_addr_attribute17		=>	addrec.addr_attribute17
	--	,p_addr_attribute18		=>	addrec.addr_attribute18
	--	,p_addr_attribute19		=>	addrec.addr_attribute19
	--	,p_addr_attribute20		=>	addrec.addr_attribute20
	--	,p_add_information13		=>	addrec.add_information13
		,p_add_information14		=>	addrec.addr_attribute14
		,p_add_information15		=>	addrec.addr_attribute15
		,p_add_information16		=>	addrec.addr_attribute16
	--	,p_add_information17		=>	addrec.add_information17
	--	,p_add_information18		=>	addrec.add_information18
	--	,p_add_information19		=>	addrec.add_information19
	--	,p_add_information20		=>	addrec.add_information20
		,p_party_id                     => 	v_party_id
		,p_address_id                   =>      v_address_id
		,p_object_version_number        =>      v_object_version_number
);
-- ----------------------------------------------------------------
--  			Update the Temp address table
-- --------------------------------------------------------------
IF (v_address_id is not null) THEN
			--UPDATE cust.ttec_h_ar_add--Commented code by MXKEERTHI-ARGANO, 05/19/2023
			UPDATE apps.ttec_h_ar_add --code added by MXKEERTHI-ARGANO, 05/19/2023
				SET
				address_id	= v_address_id,
				party_id 	= v_party_id,
				STATUS   	= STATS
				where emp_num_legacy=addrec.emp_num_legacy;
                		v_addr_count :=v_addr_count+1;
				l_error_message:=' Address Created ';
                        apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                         || addrec.EMP_NUM_LEGACY ||' - '|| ' '||SYSTEM_USER_CONST);
               --         UPDATE hr.per_addresses
               --                 SET
               --                  ADD_INFORMATION14  = addrec.addr_attribute14,
               --                  ADD_INFORMATION15  = addrec.addr_attribute15,
               --                  ADD_INFORMATION16  = addrec.addr_attribute16
               --                 WHERE
               --                  PERSON_ID = addrec.person_id;
END IF;
	EXCEPTION
		WHEN OTHERS THEN
		--	UPDATE cust.ttec_h_ar_add  --Commented code by MXKEERTHI-ARGANO, 05/19/2023
			UPDATE apps.ttec_h_ar_add --code added by MXKEERTHI-ARGANO, 05/19/2023
			SET
			 party_id = NULL,
			address_id = v_address_id,
			STATUS = STATF
			where emp_num_legacy=addrec.emp_num_legacy;
			 g_error_message := SQLERRM;
			 l_error_message :=' Address API Failed';
			 apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                        || addrec.EMP_NUM_LEGACY ||'-'|| g_error_message||' '||SYSTEM_USER_CONST);
			v_err_count := v_err_count + 1;
END;
--  END IF;		-- v_err_count
-- END IF; 	-- v_lerr_count
v_proc_count := v_proc_count + 1;
END LOOP;
l_tot_err_data	:=(' Total Address creation failed - '||v_err_count);
l_tot_proc_data	:=(' Total processed data - '||v_proc_count);
l_tot_succ_data	:=(' Total Address created - '||v_addr_count);
apps.ttec_conv_util.Stampln(e_open_log_file,l_tot_err_data );
apps.ttec_conv_util.Stampln(e_open_log_file,l_tot_proc_data );
apps.ttec_conv_util.Stampln(e_open_log_file, l_tot_succ_data );
  ttec_conv_util.Close_Log_File(e_open_log_file);
END;
/
show errors;
/