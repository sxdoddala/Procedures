create or replace PROCEDURE TTEC_H_MX_CNV_ADD AS
  -- -----------------------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  -- Program Name  : TTEC_H_MX_CNV_ADD
  -- Author        : Arun Jayaraman
  -- Creation Date : 11/30/04
  -- Purpose       : Program to load TTEC Employee Address data from Legacy System
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
 v_employee_number		PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE;
 v_party_id			NUMBER;
 v_address_id			NUMBER;
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
 MODULE_NAME_CONST CONSTANT     VARCHAR2(40)    := 'CREATE ADDRESS';
 SYSTEM_USER_CONST CONSTANT     VARCHAR2(40) 	:= 'TELETECH';
 g_error_message		VARCHAR2(2000);
 l_error_message		VARCHAR2(100);
 l_tot_err_data			VARCHAR2(200);
 l_tot_proc_data		VARCHAR2(200);
 l_tot_succ_data		VARCHAR2(200);
 e_log_file                     VARCHAR2(100);
 e_log_file_name                VARCHAR2(20)   := 'HR_ADD_MX_log_file_';
 e_open_log_file                Utl_File.FILE_TYPE;
-- ------------------------------------------------------------------------------------
CURSOR  t_add is
SELECT
	 a.EMPLOYEE_NUMBER_IN_LS
	,a.EFFECTIVE_DATE
	,a.VALIDATE_COUNTY
	,a.PRIMARY_FLAG
	,a.STYLE
	,a.DATE_FROM
	,a.DATE_TO
	,a.ADDRESS_TYPE
	,a.COMMENTS
--	,a.street_name_and_num     -- Reserved for MX only api parm for futer usage, in case..
--	,a.neighborhood            --
--	,a.municipality
--	,a.city
--	,a.state
--	,a.telephone
--	,a.fax                     -- Reserved for MX only api parm for futer usage, in case..
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
	,a.ADDR_ATTRIBUTE_CATEGORY
	,a.ADDR_ATTRIBUTE1
	,a.ADDR_ATTRIBUTE2
	,a.ADDR_ATTRIBUTE3
	,a.ADDR_ATTRIBUTE4
	,a.ADDR_ATTRIBUTE5
	,a.ADDR_ATTRIBUTE6
	,a.ADDR_ATTRIBUTE7
	,a.ADDR_ATTRIBUTE8
	,a.ADDR_ATTRIBUTE9
	,a.ADDR_ATTRIBUTE10
	,a.ADDR_ATTRIBUTE11
	,a.ADDR_ATTRIBUTE12
	,a.ADDR_ATTRIBUTE13
	,a.ADDR_ATTRIBUTE14
	,a.ADDR_ATTRIBUTE15
	,a.ADDR_ATTRIBUTE16
	,a.ADDR_ATTRIBUTE17
	,a.ADDR_ATTRIBUTE18
	,a.ADDR_ATTRIBUTE19
	,a.ADDR_ATTRIBUTE20
--	,a.ADDR_INFORMATION13    -- not exist in conv temp table
--	,a.ADDR_INFORMATION14
--	,a.ADDR_INFORMATION15
--	,a.ADDR_INFORMATION16
--	,a.ADDR_INFORMATION17
--	,a.ADDR_INFORMATION18
--	,a.ADDR_INFORMATION19
--	,a.ADDR_INFORMATION20    -- not exist in conv temp table
	,b.person_id
/*
START R12.2 Upgrade Remediation
code commented by RXNETHI-ARGANO,19/05/23
FROM    cust.ttec_h_mx_add a,
	cust.ttec_h_mx_emp b
*/
--code added by RXNETHI-ARGANO,19/05/23
FROM    apps.ttec_h_mx_add a,
	    apps.ttec_h_mx_emp b
--END R12.2 Upgrade Remediation
WHERE   a.address_id IS NULL
AND     b.status = 'S'
AND     a.employee_number_in_ls=b.employee_number_in_ls
AND     (a.status ='F' OR a.status IS NULL);

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
		l_error_message := 'Create Address Process -MExico';
		apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                 ||'-- '||SYSTEM_USER_CONST);
*/
-- ----------------------------------------------------------------------
-- 		Load Data From temp table
-- ----------------------------------------------------------------------
FOR addrec IN t_add
LOOP
 l_error_message := '**************Processing legacy employee X ';
 apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
        || addrec.employee_number_in_ls ||'-'||' '||SYSTEM_USER_CONST);
		v_lerr_count			:=0;
		v_person_id			:= addrec.person_id;
		v_party_id			:= NULL;
		v_address_id			:= NULL;
		v_object_version_number 	:= NULL;
--  ---------------------------------------------------------------------
--  		Validate the County
--  ---------------------------------------------------------------------
BEGIN
	IF ltrim(rtrim(addrec.validate_county))='MX'THEN
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
     WHERE  name = 'TeleTech Holdings - MEX';

     EXCEPTION
 	   WHEN NO_DATA_FOUND THEN
	   g_error_message := SQLERRM;
     	   l_error_message := 'No Business group id ';
           apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
           || addrec.employee_number_in_ls ||'-'|| g_error_message||' '||SYSTEM_USER_CONST);
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
		FROM   cust.ttec_h_mx_emp c
                WHERE  addrec.employee_number_in_ls=c.employee_number_in _ls;
END;
*/
-- --------------------------------------------------------------
-- 		Get Person id and Effective Start date
-- --------------------------------------------------------------
/* commeted out
BEGIN
        SELECT    paf.person_id
   	INTO      v_person_id
   	FROM      PER_ALL_PEOPLE_F paf,
	          cust.ttec_h_mx_emp c
     	WHERE     paf.person_id=c.person_id
        AND       c.employee_number_in _ls=addrec.employee_number_in_ls;

--	AND 	  c.new_employee_number=v_employee_number
--	AND       business_group_id = 1590;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
	          g_error_message := SQLERRM;
     	          l_error_message := 'NO PERSON ID';
      		  apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
       		  || addrec.employee_number_in_ls ||'-'|| g_error_message||' '||SYSTEM_USER_CONST);
  		  v_lerr_count := v_lerr_count+1;
 END;
*/
-- -------------------------------------------------------------
--             End of Validation Process
-- --------------------------------------------------------------
IF v_lerr_count = 0 THEN
 --  IF v_err_count = 0 then
--  ---------------------------------------------------------
--   		Call Create Address API
--  ---------------------------------------------------------
BEGIN
	apps.HR_PERSON_ADDRESS_API.CREATE_MX_PERSON_ADDRESS
	(
		p_validate			=>	FALSE
		,p_effective_date		=>	addrec.effective_date
		,p_pradd_ovlapval_override	=>	FALSE
	--	,p_validate_county		=>	v_validate_county
		,p_person_id			=>	addrec.person_id
		,p_primary_flag			=>	addrec.primary_flag
        --      ,p_style			=>	addrec.style
		,p_date_from			=>	addrec.date_from
		,p_date_to			=>	addrec.date_to
		,p_address_type			=>	addrec.address_type
		,p_comments			=>	addrec.comments
	--	,p_street_name_and_num          => 	addrec.street_name_and_num  -- Reserved for MX only api parm for futer usage, in case..
	--	,p_neighborhood                 => 	addrec.neighborhood
	--	,p_municipality                 => 	addrec.municipality
	--	,p_city                         => 	addrec.city
	--	,p_state                        => 	addrec.state
	--	,p_telephone                    => 	addrec.telephone
	--	,p_fax                          => 	addrec.fax                   -- Reserved for MX only api parm for futer usage, in case..
                ,p_address_line1                =>      addrec.address_line1
		,p_address_line2		=>	addrec.address_line2
		,p_address_line3		=>	addrec.address_line3
	        ,p_city		        	=>	addrec.town_or_city       -- changed p_city from p_city_or_town due to call MX_create..
		,p_state                	=>	addrec.region_1           -- chanbge p_state from p_region_1 due to caa MX_create..
--              ,p_region_2			=>	addrec.region_2
--              ,P_region_3			=>	addrec.region_3
		,p_postal_code			=>	addrec.postal_code
		,p_country			=>	addrec.country
		,p_telephone_number_1		=>	addrec.telephone_number_1
		,p_telephone_number_2		=>	addrec.telephone_number_2
		,p_telephone_number_3		=>	addrec.telephone_number_3
		,p_addr_attribute_category	=>	addrec.addr_attribute_category
		,p_addr_attribute1		=>	addrec.addr_attribute1
		,p_addr_attribute2		=>	addrec.addr_attribute2
		,p_addr_attribute3		=>	addrec.addr_attribute3
		,p_addr_attribute4		=>	addrec.addr_attribute4
		,p_addr_attribute5		=>	addrec.addr_attribute5
		,p_addr_attribute6		=>	addrec.addr_attribute6
		,p_addr_attribute7		=>	addrec.addr_attribute7
		,p_addr_attribute8		=>	addrec.addr_attribute8
		,p_addr_attribute9		=>	addrec.addr_attribute9
		,p_addr_attribute10		=>	addrec.addr_attribute10
		,p_addr_attribute11		=>	addrec.addr_attribute11
		,p_addr_attribute12		=>	addrec.addr_attribute12
		,p_addr_attribute13		=>	addrec.addr_attribute13
		,p_addr_attribute14		=>	addrec.addr_attribute14
		,p_addr_attribute15		=>	addrec.addr_attribute15
		,p_addr_attribute16		=>	addrec.addr_attribute16
		,p_addr_attribute17		=>	addrec.addr_attribute17
		,p_addr_attribute18		=>	addrec.addr_attribute18
		,p_addr_attribute19		=>	addrec.addr_attribute19
		,p_addr_attribute20		=>	addrec.addr_attribute20
--,p_addr_information13		=>	addrec.addr_information13
--,p_addr_information14		=>	addrec.addr_information14
--,p_addr_information15		=>	addrec.addr_information15
--,p_addr_information16		=>	addrec.addr_information16
--,p_addr_information17		=>	addrec.addr_information17
--,p_addr_information18		=>	addrec.addr_information18
--,p_addr_information19		=>	addrec.addr_information19
--,p_addr_information20		=>	addrec.addr_information20
--,p_party_id                     => 	v_party_id
		,p_address_id                   =>      v_address_id
		,p_object_version_number        =>      v_object_version_number
);
-- ----------------------------------------------------------------
--  			Update the Temp address table
-- --------------------------------------------------------------
IF (v_address_id is not null) THEN
			--UPDATE cust.ttec_h_mx_add    --code commented by RXNETHI-ARGANO,19/05/23
			UPDATE apps.ttec_h_mx_add      --code added by RXNETHI-ARGANO,19/05/23
			SET
				address_id	= v_address_id,
				party_id 	= v_party_id,
				STATUS   	= STATS
			where   employee_number_in_ls=addrec.employee_number_in_ls;
                		v_addr_count :=v_addr_count+1;
				l_error_message:='Address Created XXX ';
     apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
        || addrec.employee_number_in_ls ||'-'|| ' '||SYSTEM_USER_CONST);
END IF;
	EXCEPTION
		WHEN OTHERS THEN
			--UPDATE cust.ttec_h_mx_add    --code commented by RXNETHI-ARGANO,19/05/23
			UPDATE apps.ttec_h_mx_add      --code added by RXNETHI-ARGANO,19/05/23
		SET
			party_id = NULL,
			address_id = v_address_id,
			STATUS = STATF
		where   employee_number_in_ls =addrec.employee_number_in_ls;
			g_error_message := SQLERRM;
			l_error_message :=' Address API Failed';
			apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                        || addrec.employee_number_in_ls ||'-'|| g_error_message||' '||SYSTEM_USER_CONST);
			v_err_count := v_err_count + 1;
END;
 --  END IF;		-- v_err_count
END IF; 	-- v_lerr_count
v_proc_count := v_proc_count + 1;
END LOOP;
	l_tot_err_data	:=('Total Address creation failed'||v_err_count);
	l_tot_proc_data	:=('Total processed data'||v_proc_count);
	l_tot_succ_data	:=('Total Address created'||v_addr_count);
	apps.ttec_conv_util.Stampln(e_open_log_file, 'Total # of record processed: ' || v_proc_count );
	apps.ttec_conv_util.Stampln(e_open_log_file, 'Total # of record successful: ' || v_addr_count );
        apps.ttec_conv_util.Stampln(e_open_log_file, 'Total # of record faild: ' || v_err_count );
 	apps.ttec_conv_util.Close_Log_File(e_open_log_file);
END;
/
show errors;
/