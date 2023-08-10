create or replace PROCEDURE      ttec_gl_daily_rates_int_load (
																					errbuf	 OUT VARCHAR2,
																					retcode	 OUT VARCHAR2
																				  )
IS
/******************************************************************************
 NAME: TTEC_GL_DAILY_RATES_INT_LOAD
 PURPOSE:

 REVISIONS:
 Ver Date Author Description
 --------- ---------- --------------- ------------------------------------
 1.0 6/24/2008 Kevin Hedger 1. Loads the Oanda daily rates into
 the GL.GL_DAILY_RATES_INTERFACE
 table.
 1.1 7/19/2011 Kaushik Gonuguntla 1. Changed the staging table name.
 NOTES:
1.2  10/28/2011 Kaushik Gonuguntla 1. R12 Retrofit as per SR 3-4838560841.
 Automatically available Auto Replace Keywords:
  Object Name:   TTEC_GL_DAILY_RATES_INT_LOAD
  Sysdate: 6/24/2008
  Date and Time: 6/24/2008, 12:40:46 PM, and 6/26/2008 12:40:46 PM
  Username:   (set in TOAD Options, Procedure Editor)
  Table Name: (set in the "New PL/SQL Object" dialog)
  
  1.0  RXNETHI-ARGANO   19/05/23   R12.2 Upgrade Remediation
******************************************************************************/

BEGIN
	--INSERT INTO gl.gl_daily_rates_interface (     --code commented by RXNETHI-ARGANO,19/05/23
	INSERT INTO apps.gl_daily_rates_interface (     --code added by RXNETHI-ARGANO,19/05/23
														  from_currency,
														  to_currency,
														  from_conversion_date,
														  to_conversion_date,
														  user_conversion_type,
														  conversion_rate,
														  mode_flag,
														  user_id
														 )
		SELECT base_from_currency,
				 quote_to_currency,
				 TRUNC (SYSDATE + 1),
				 TRUNC (SYSDATE + 1),
				 'Spot',
				 bid_conversion_rate,
				 'I',
				 fnd_profile.VALUE ('USER_ID')
		  FROM ttec_daily_exhg_rates_stg 																	 -- Version 1.1
		 WHERE base_from_currency < quote_to_currency                           -- this will get a unique combination of each currency. Version 1.2
				 AND file_process_time > TO_CHAR (SYSDATE - .25, 'YYYYMMDDhhmm');
-- Will only capture data from a file ran in the last 6 hours.
EXCEPTION
	WHEN NO_DATA_FOUND
	THEN
		NULL;
	WHEN OTHERS
	THEN
		-- Consider logging the error and then re-raise
		RAISE;
END ttec_gl_daily_rates_int_load;
/
show errors;
/