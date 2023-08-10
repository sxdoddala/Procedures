create or replace PROCEDURE TTEC_H_ES_CNV_ADD AS
  -- -----------------------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  -- Program Name  : TTEC_H_ES_CNV_ADD
  -- Author        : Pradip Kumar Hati
  -- Creation Date : 03/09/05
  -- Purpose       : Program to load TTEC SPAIN Employee Address data from Legacy System
  -- -----------------------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  
  
  /************************************************************************************
        Program Name: TTEC_H_ES_CNV_ADD 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI(ARGANO)            1.0      19-May-2023      R12.2 Upgrade Remediation
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
 e_log_file_name                VARCHAR2(20)   := 'HR_ADD_ES_log_file_';
 e_open_log_file                Utl_File.FILE_TYPE;

-- ------------------------------------------------------------------------------------
CURSOR c_add IS

SELECT
      thea.employee_number_in_ls
    , addr_effective_date
    , address_id
    , business_group_id
    , thee.person_id
    , date_from
    , primary_flag
    , style
    , street_type
    , street_name
    , street_number
    , address_type
    , comments
    , country
    , date_to
    , postal_code
    , region_1
    , province
    , region_3
    , telephone_number_1
    , telephone_number_2
    , town_or_city
    , addr_attribute_category
    , addr_attribute1
    , addr_attribute2
    , addr_attribute3
    , addr_attribute4
    , addr_attribute5
    , addr_attribute6
    , addr_attribute7
    , addr_attribute8
    , addr_attribute9
    , addr_attribute10
    , addr_attribute11
    , addr_attribute12
    , addr_attribute13
    , addr_attribute14
    , addr_attribute15
    , addr_attribute16
    , addr_attribute17
    , addr_attribute18
    , addr_attribute19
    , addr_attribute20
    , building          --add_information13
    , stairs          --add_information14
    , floor            --add_information15
    , door             --add_information16
    , add_information17
    , add_information18
    , add_information19
    , add_information20
/*
START R12.2 Upgrade Remediation
code commented by RXNETHI-ARGANO
FROM  cust.ttec_h_es_add  thea
     ,cust.ttec_h_es_emp  thee
*/
--code added by RXNETHI-ARGANO,19/05/23
FROM  apps.ttec_h_es_add  thea
     ,apps.ttec_h_es_emp  thee
--END R12.2 Upgrade Remediation
WHERE thee.employee_number_in_ls =   thea.employee_number_in_ls
AND   thee.status = 'S'
AND   nvl(thea.status,'X')  != 'S'
--AND  thea.employee_number_in_ls = 100032
order by thea.employee_number_in_ls ;



o_address_id             NUMBER;
o_object_version_number  NUMBER;
o_party_id               NUMBER;


BEGIN


         e_open_log_file := ttec_conv_util.Open_Log_File(e_log_file_name);

-- ----------------------------------------------------------------------
-- 		Load Data From temp table
-- ----------------------------------------------------------------------


FOR r_add in C_add
LOOP



 l_error_message := 'Processing legacy employee ';


   apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                                               || r_add.employee_number_in_ls ||'-'||' '||SYSTEM_USER_CONST);
		               v_lerr_count			:=0;
		               v_person_id			:= r_add.person_id;
		               v_party_id			:= NULL;
		               v_address_id			:= NULL;
		               v_object_version_number 	        := NULL;



--  ---------------------------------------------------------------------
--  		Validate the County
--  ---------------------------------------------------------------------
BEGIN
	IF ltrim(rtrim(r_add.country))='ES'THEN
		v_validate_county := TRUE;
	ELSE
		v_validate_county :=FALSE;
                v_lerr_count      := v_lerr_count +1;
	END IF;
END;


-- -------------------------------------------------------------
--             End of Validation Process
-- --------------------------------------------------------------



IF v_lerr_count = 0 THEN


--  ---------------------------------------------------------
--   		Call Create Address API
--  ---------------------------------------------------------
  BEGIN


 /*
  hr_person_address_api.create_ES_person_address
  (p_validate                   => TRUE
  ,p_effective_date             => r_add.addr_effective_date
  ,p_pradd_ovlapval_override    => FALSE
  ,p_person_id                  => r_add.person_id
  ,p_primary_flag               => r_add.primary_flag
  ,p_date_from                  => r_add.date_from
  ,p_date_to                    => r_add.date_to
  ,p_address_type               => r_add.address_type
  ,p_comments                   => r_add.comments
  ,p_street_type                => r_add.street_type
  ,p_street_name                => r_add.street_name
  ,p_number                     => r_add.street_number
--  ,p_postal_code                => r_add.postal_code
  ,p_postal_code                => '8740'
  ,p_city                       => r_add.town_or_city
  ,p_province                   => r_add.province
  ,p_country                    => r_add.country
  ,p_telephone_number           => r_add.telephone_number_1
  ,p_telephone_number_2         => r_add.telephone_number_2
  ,p_addr_attribute_category      => r_add.addr_attribute_category
  ,p_addr_attribute1              => r_add.addr_attribute1
  ,p_addr_attribute2              => r_add.addr_attribute2
  ,p_addr_attribute3              => r_add.addr_attribute3
  ,p_addr_attribute4              => r_add.addr_attribute4
  ,p_addr_attribute5              => r_add.addr_attribute5
  ,p_addr_attribute6              => r_add.addr_attribute6
  ,p_addr_attribute7              => r_add.addr_attribute7
  ,p_addr_attribute8              => r_add.addr_attribute8
  ,p_addr_attribute9              => r_add.addr_attribute9
  ,p_addr_attribute10             => r_add.addr_attribute10
  ,p_addr_attribute11             => r_add.addr_attribute11
  ,p_addr_attribute12             => r_add.addr_attribute12
  ,p_addr_attribute13             => r_add.addr_attribute13
  ,p_addr_attribute14             => r_add.addr_attribute14
  ,p_addr_attribute15             => r_add.addr_attribute15
  ,p_addr_attribute16             => r_add.addr_attribute16
  ,p_addr_attribute17             => r_add.addr_attribute17
  ,p_addr_attribute18             => r_add.addr_attribute18
  ,p_addr_attribute19             => r_add.addr_attribute19
  ,p_addr_attribute20             => r_add.addr_attribute20
  ,p_add_information13            => r_add.building
  ,p_add_information14            => r_add.stairs
  ,p_add_information15            => r_add.floor
  ,p_add_information16            => r_add.door
  ,p_add_information17            => r_add.add_information17
  ,p_add_information18            => r_add.add_information18
  ,p_add_information19            => r_add.add_information19
  ,p_add_information20            => r_add.add_information20
  ,p_address_id                 => o_address_id --  out nocopy number
  ,p_object_version_number      => o_object_version_number --   out nocopy number
  );
*/


  hr_person_address_api.create_person_address
  (p_validate                   => FALSE
  ,p_effective_date             => r_add.addr_effective_date
  ,p_pradd_ovlapval_override    => FALSE
  ,p_validate_county            => FALSE
  ,p_person_id                  => r_add.person_id
  ,p_primary_flag               => r_add.primary_flag
  ,p_style                      => 'ES'
  ,p_date_from                  => r_add.date_from
  ,p_date_to                    => r_add.date_to
  ,p_address_type               => r_add.address_type
  ,p_comments                   => r_add.comments
  ,p_address_line1              => r_add.street_type
  ,p_address_line2              => r_add.street_name
  ,p_address_line3              => r_add.street_number
  ,p_town_or_city               => r_add.town_or_city
  ,p_region_1                   => r_add.region_1
  ,p_region_2                   => r_add.province
  ,p_region_3                   => r_add.region_3
  ,p_postal_code                => r_add.postal_code
  ,p_country                    => r_add.country
  ,p_telephone_number_1         => r_add.telephone_number_1
  ,p_telephone_number_2         => r_add.telephone_number_2
  ,p_telephone_number_3         => NULL
 ,p_addr_attribute_category     => r_add.addr_attribute_category
  ,p_addr_attribute1            => r_add.addr_attribute1
  ,p_addr_attribute2            => r_add.addr_attribute2
  ,p_addr_attribute3            => r_add.addr_attribute3
  ,p_addr_attribute4            => r_add.addr_attribute4
  ,p_addr_attribute5            => r_add.addr_attribute5
  ,p_addr_attribute6            => r_add.addr_attribute6
  ,p_addr_attribute7            => r_add.addr_attribute7
  ,p_addr_attribute8            => r_add.addr_attribute8
  ,p_addr_attribute9            => r_add.addr_attribute9
  ,p_addr_attribute10           => r_add.addr_attribute10
  ,p_addr_attribute11           => r_add.addr_attribute11
  ,p_addr_attribute12           => r_add.addr_attribute12
  ,p_addr_attribute13           => r_add.addr_attribute13
  ,p_addr_attribute14           => r_add.addr_attribute14
  ,p_addr_attribute15           => r_add.addr_attribute15
  ,p_addr_attribute16           => r_add.addr_attribute16
  ,p_addr_attribute17           => r_add.addr_attribute17
  ,p_addr_attribute18           => r_add.addr_attribute18
  ,p_addr_attribute19           => r_add.addr_attribute19
  ,p_addr_attribute20           => r_add.addr_attribute20
  ,p_add_information13          => r_add.building
  ,p_add_information14          => r_add.stairs
  ,p_add_information15          => r_add.floor
  ,p_add_information16          => r_add.door
  ,p_add_information17          => r_add.add_information17
  ,p_add_information18          => r_add.add_information18
  ,p_add_information19          => r_add.add_information19
  ,p_add_information20          => r_add.add_information20
  ,p_party_id                   => NULL
  ,p_address_id                 => o_address_id
  ,p_object_version_number      => o_object_version_number
  );

-- ----------------------------------------------------------------
--  			Update the Temp address table
-- --------------------------------------------------------------


   IF (o_address_id is not null) THEN
		--UPDATE cust.ttec_h_ES_add   --code commented by RXNETHI-ARGANO,19/05/23
		UPDATE apps.ttec_h_ES_add     --code added by RXNETHI-ARGANO,19/05/23
		SET
			address_id	= o_address_id,
			party_id 	= o_party_id,
			STATUS   	= STATS
		where   employee_number_in_ls=r_add.employee_number_in_ls;

            	v_addr_count :=v_addr_count+1;
		l_error_message:='Address Created';



     apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
        || r_add.employee_number_in_ls ||'-'|| ' '||SYSTEM_USER_CONST);
   END IF;


	EXCEPTION
		WHEN OTHERS THEN
			--UPDATE cust.ttec_h_ES_add     --code commented by RXNETHI-ARGANO,19/05/23
			UPDATE apps.ttec_h_ES_add       --code added by RXNETHI-ARGANO,19/05/23
		SET
			party_id = NULL,
			address_id = o_address_id,
			STATUS = STATF
		where   employee_number_in_ls =r_add.employee_number_in_ls;



			g_error_message := SQLERRM;
			l_error_message :=' Address API Failed';


                 apps.ttec_conv_util.Stampln(e_open_log_file, MODULE_NAME_CONST||' '|| l_error_message
                                  || r_add.employee_number_in_ls ||'-'|| g_error_message||' '||SYSTEM_USER_CONST);
		 v_err_count := v_err_count + 1;

      END;  -- Call Create Address API




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