create or replace PROCEDURE TTEC_H_UK_CNV_CON_ADD AS
  -- -----------------------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  -- Program Name  : TTEC_H_UK_CNV_CON_ADD
  -- Author        : Arun Jayaraman
  -- Creation Date : 02/24/05
  -- Purpose       : Program to load TTEC UK Employee Contact Address data from Legacy System
  -- -----------------------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  
  
  
   /************************************************************************************
        Program Name: TTEC_PO_TSG_INTERFACE 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI-ARGANO            1.0      19-May-2023      R12.2 Upgrade Remediation
    ****************************************************************************************/
  
  
  
  
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
MODULE_NAME_CONST CONSTANT      VARCHAR2(40)    := 'CREATE CONTACT ADDRESS';
               SYSTEM_USER_CONST CONSTANT                 VARCHAR2(40) 	:= 'TELETECH';
g_error_message			VARCHAR2(2000);
l_error_message			VARCHAR2(100);
l_tot_err_data					VARCHAR2(200);
l_tot_proc_data					VARCHAR2(200);
L_tot_succ_data					VARCHAR2(200);
e_log_file                      VARCHAR2(100);
e_log_file_name                 VARCHAR2(40)   := 'HR_CON_ADD_UK_LOG_FILE';
e_open_log_file                 Utl_File.FILE_TYPE;
v_address_line1 		varchar2(240)	;
v_address_line2 		varchar2(240)	;
v_address_line3 		varchar2(240)	;
v_town_or_city			varchar2(100)	;

-- ------------------------------------------------------------------------------------
CURSOR  t_add is
SELECT  DISTINCT
	       a.Employee_number_in_ls
          ,a.national_identifier_contact
          ,a.last_name_contact
          ,a.first_name_contact
          ,a.middle_names_contact
          ,a.effective_date
          ,a.pradd_ovlapval_override
          ,a.validate_county
          ,a.primary_flag
          ,'GB' style
          ,a.date_from
          ,a.date_to
          ,a.address_type
          ,a.comments
          ,a.address_line1
          ,a.address_line2
          ,a.address_line3
          ,a.town_or_city
          ,a.region_1
          ,a.region_2
          ,a.region_3
          ,a.postal_code
          ,a.country
          ,a.telephone_number_1
          ,a.telephone_number_2
          ,a.telephone_number_3
          ,a.addr_attribute_category
          ,a.addr_attribute1
          ,a.addr_attribute2
          ,a.addr_attribute3
          ,a.addr_attribute4
          ,a.addr_attribute5
          ,a.addr_attribute6
          ,a.addr_attribute7
          ,a.addr_attribute8
          ,a.addr_attribute9
          ,a.addr_attribute10
          ,a.addr_attribute11
          ,a.addr_attribute12
          ,a.addr_attribute13
          ,a.addr_attribute14
          ,a.addr_attribute15
          ,a.addr_attribute16
          ,a.addr_attribute17
          ,a.addr_attribute18
          ,a.addr_attribute19
          ,a.addr_attribute20
          ,a.add_information13
          ,a.add_information14
          ,a.add_information15
          ,a.add_information16
          ,a.add_information17
          ,a.add_information18
          ,a.add_information19
          ,a.add_information20
          ,c.per_person_id  person_id
/*
START R12.2 Upgrade Remediation
code commented by RXNETHI-ARGANO,19/05/23
FROM      cust.ttec_h_uk_con_add a
         ,cust.ttec_h_uk_emp     b
		 ,cust.ttec_h_uk_con     c
*/
--code added by RXNETHI-ARGANO,19/05/23
FROM      apps.ttec_h_uk_con_add a
         ,apps.ttec_h_uk_emp     b
		 ,apps.ttec_h_uk_con     c
--END R12.2 Upgrade Remediation
WHERE    a.employee_number_in_ls = b.employee_number_in_ls
AND      b.status = 'S'
and      a.employee_number_in_ls = c.employee_number_in_ls
and      c.status = 'S'
and      nvl(a.status,'X') != 'S'
and      nvl(a.first_name_contact,'X') = nvl(c.first_name,'X')
and      nvl(a.last_name_contact,'X')  = nvl(c.last_name,'X')
ORDER BY 1;

BEGIN
/*
             DBMS_OUTPUT.ENABLE(1000000);
             dbms_output.put_line('Begin Statement');
               -- --------------------------------------------------------------------------------------------------
               --         Open Log file
               -- -----------------------------------------------
*/
e_open_log_file := ttec_conv_util.Open_Log_File(e_log_file_name);



-- ----------------------------------------------------------------------
-- 		Load Data From temp table
-- ----------------------------------------------------------------------
FOR addrec IN t_add
LOOP
-- apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
--        || addrec.Employee_number_in_ls ||'-'||' '||SYSTEM_USER_CONST);
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
                        || addrec.Employee_number_in_ls ||'-'||' '||SYSTEM_USER_CONST);


--  ---------------------------------------------------------------------
--  		Validate the County
--  ---------------------------------------------------------------------
BEGIN
	IF ltrim(rtrim(addrec.validate_county))='GB'THEN
		v_validate_county := TRUE;
	ELSE
		v_validate_county :=FALSE;
	--	v_err_count := v_err_count+1;
	END IF;
END;


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
		p_validate					=>	FALSE
		,p_effective_date			=>	addrec.effective_date
		,p_pradd_ovlapval_override	=>	FALSE
		,p_validate_county			=>	v_validate_county
		,p_person_id				=>	v_person_id
		,p_primary_flag				=>	'Y' -- addrec.primary_flag
		,p_style					=>	addrec.style
		,p_date_from				=>	addrec.date_from
		,p_date_to					=>	addrec.date_to
		,p_address_type				=>	addrec.address_type
		,p_comments					=>	addrec.comments
		,p_address_line1			=>	v_address_line1
		,p_address_line2			=>	v_address_line2
		,P_address_line3			=>	v_address_line3
		,p_town_or_city				=>	v_town_or_city
		,p_region_1					=>	addrec.region_1
		,p_region_2					=>	addrec.region_2
		,P_region_3					=>	addrec.region_3
		,p_postal_code				=>	addrec.postal_code
		,p_country					=>	addrec.country
		,p_telephone_number_1		=>	addrec.telephone_number_1
		,p_telephone_number_2		=>	addrec.telephone_number_2
		,p_telephone_number_3		=>	addrec.telephone_number_3
	--	,p_addr_attribute_category	=>	addrec.addr_attribute_category
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
		,p_addr_attribute13		=>	addrec.addr_attribute13
	--	,p_addr_attribute14		=>	addrec.addr_attribute14
	--	,p_addr_attribute15		=>	addrec.addr_attribute15
	--	,p_addr_attribute16		=>	addrec.addr_attribute16
	--	,p_addr_attribute17		=>	addrec.addr_attribute17
	--	,p_addr_attribute18		=>	addrec.addr_attribute18
	--	,p_addr_attribute19		=>	addrec.addr_attribute19
	--	,p_addr_attribute20		=>	addrec.addr_attribute20
	--	,p_add_information13		=>	addrec.add_information13
	--	,p_add_information14		=>	addrec.add_information14
	--	,p_add_information15		=>	addrec.add_information15
	--	,p_add_informati-on16		=>	addrec.add_information16
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
			--UPDATE cust.ttec_h_uk_con_add    --code commented by RXNETHI-ARGANO,19/05/23
			UPDATE apps.ttec_h_uk_con_add      --code added by RXNETHI-ARGANO,19/05/23
				SET
				address_id	= v_address_id,
				party_id 	= v_party_id,
				STATUS   	= STATS
				where Employee_number_in_ls=addrec.Employee_number_in_ls;
                		v_addr_count :=v_addr_count+1;
				l_error_message:='Address Created ';
     apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
        || addrec.Employee_number_in_ls ||'-'|| ' '||SYSTEM_USER_CONST);
END IF;
	EXCEPTION
		WHEN OTHERS THEN
			--UPDATE cust.ttec_h_uk_con_add     --code commented by RXNETHI-ARGANO,19/05/23
			UPDATE apps.ttec_h_uk_con_add       --code added by RXNETHI-ARGANO,19/05/23
			SET
			 party_id = NULL,
			address_id = v_address_id,
			STATUS = STATF
			where Employee_number_in_ls=addrec.Employee_number_in_ls;
			 g_error_message := SQLERRM;
			 l_error_message :=' Address API Failed for legacy Emp # ';
			 apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                        || addrec.Employee_number_in_ls ||'  '|| g_error_message||' '||SYSTEM_USER_CONST);
			v_err_count := v_err_count + 1;
END;
--  END IF;		-- v_err_count
-- END IF; 	-- v_lerr_count
v_proc_count := v_proc_count + 1;
END LOOP;
l_tot_err_data	:=('Total Address creation failed'||v_err_count);
l_tot_proc_data	:=('Total processed data'||v_proc_count);
l_tot_succ_data	:=('Total Address created'||v_addr_count);
apps.ttec_conv_util.Stampln(e_open_log_file,l_tot_err_data );
apps.ttec_conv_util.Stampln(e_open_log_file,l_tot_proc_data );
apps.ttec_conv_util.Stampln(e_open_log_file, l_tot_succ_data );
  ttec_conv_util.Close_Log_File(e_open_log_file);
END;
/
show errors;
/