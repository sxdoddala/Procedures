create or replace PROCEDURE      ttec_gl_rec_rates_int_load (
   errbuf             OUT      VARCHAR2,
   retcode            OUT      VARCHAR2,
   iv_recovery_date   IN       VARCHAR2
)
IS
   v_date   DATE := TO_DATE (iv_recovery_date, 'MM/DD/YYYY');
/* $Header: TTEC_GL_REC_RATES_INT_LOAD.prc 1.0 2011/07/10 kbabu $ */
/*== START ================================================================================================*\
   Date:  JUL 25, 2011
   Desc:  This procedure loads the data into gl_daily_rates_interface table for oracle process.

   Call from: TeleTech Oanda Recovery Load to Interface

   Parameter: iv_recovery_Date - Date the recovery process needs to be run.

  Modification History:

 Mod#  Developer           Date       Comments
---------------------------------------------------------------------------
   1.0 Kevin Hedger     7/24/2008    1. Loads the Recovered Oanda daily rates into
                                      the GL.GL_DAILY_RATES_INTERFACE table.
   2.0 Kaushik Gonuguntla 25-JUL-11   Updated with the new table name "ttec_daily_rec_rates_stg" the data needs to be selected - TTSD R 827439
   1.2 Kaushik Gonuguntla 10/28/2011 1. R12 Retrofit as per SR 3-4838560841.
   1.0 RXNETHI-ARGANO     19/MAY/2023   R12.2 Upgrade Remediation
\*== END ==================================================================================================*/
BEGIN
   --INSERT INTO gl.gl_daily_rates_interface  --code commented by RXNETHI-ARGANO,19/05/23
   INSERT INTO apps.gl_daily_rates_interface  --code added by RXNETHI-ARGANO,19/05/23
               (from_currency, to_currency, from_conversion_date, to_conversion_date,
                user_conversion_type, conversion_rate, mode_flag, user_id)
      SELECT base_from_currency, quote_to_currency, v_date, v_date, 'Spot', bid_conversion_rate, 'I',
             fnd_profile.VALUE ('USER_ID')
        --FROM cust.ttec_daily_rec_rates_stg                                                 --Version 2.0 --code commented by RXNETHI-ARGANO,19/05/23
        FROM apps.ttec_daily_rec_rates_stg                                                 --Version 2.0  --code added by RXNETHI-ARGANO,19/05/23
       WHERE base_from_currency < quote_to_currency                              -- this will get a unique combination of each currency. Version 2.1
         AND file_process_time > TO_CHAR (SYSDATE - .25, 'YYYYMMDDhhmi')
         -- Will only capture data from a file ran in the last 6 hours.
         AND bid_conversion_rate > .00000000000;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END ttec_gl_rec_rates_int_load;
/
show errors;
/