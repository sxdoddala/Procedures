create or replace PROCEDURE      ttec_gl_tcmb_rec_rates_upload (errbuf OUT VARCHAR2, retcode OUT VARCHAR2)
AUTHID CURRENT_USER IS
/* $Header: TTEC_GL_TCMB_REC_RATES_UPLOAD.prc 1.0 2011/07/10 kbabu $ */
/*== START ================================================================================================*\
   Date:  JUL 25, 2011
   Desc:  This procedure updatethe Turkish TCMB Rates on top of oanda daily rates in the Staging
               table
   Call from: TeleTech TCMB Exchange Rates - Upload Rates to Oracle

   Parameter:

  Modification History:

 Mod#  Developer           Date       Comments
---------------------------------------------------------------------------
     1.0        7/11/2011   Kaushik Gonuguntla    Initial Script TTSD R 827439
	 1.0        7/17/2023   RXNETHI-ARGANO        R12.2 Upgrade Remediation
\*== END ==================================================================================================*/
-- Cursor to parse the data to get TCMB currency rates to be updated
   CURSOR c_tcmb_curr_upd
   IS
      SELECT base_from_currency, quote_to_currency, amount, conversion_date, ask / amount ask,
             bid_conversion_rate / amount bid_conversion_rate, file_process_time
        FROM (SELECT SUBSTR (file_string, 1, 3) base_from_currency,
                     SUBSTR (file_string, 5, 3) quote_to_currency,
                     SUBSTR (file_string, 10, INSTR (SUBSTR (file_string, 10), ' ', 1) - 1) amount,
                     TO_CHAR (SYSDATE, 'MM-DD-YYYY') conversion_date,
                     SUBSTR (SUBSTR (file_string,
                                       INSTR (SUBSTR (file_string, 1, INSTR (file_string, '.', 1, 1)),
                                              ' ',
                                              -1
                                             )
                                     + 1
                                    ),
                             1,
                               INSTR (SUBSTR (file_string,
                                                INSTR (SUBSTR (file_string,
                                                               1,
                                                               INSTR (file_string, '.', 1, 1)
                                                              ),
                                                       ' ',
                                                       -1
                                                      )
                                              + 1
                                             ),
                                      ' '
                                     )
                             - 1
                            ) bid_conversion_rate,
                     SUBSTR (SUBSTR (file_string,
                                       INSTR (SUBSTR (file_string, 1, INSTR (file_string, '.', 1, 2)),
                                              ' ',
                                              -1
                                             )
                                     + 1
                                    ),
                             1,
                               INSTR (SUBSTR (file_string,
                                                INSTR (SUBSTR (file_string,
                                                               1,
                                                               INSTR (file_string, '.', 1, 1)
                                                              ),
                                                       ' ',
                                                       -1
                                                      )
                                              + 1
                                             ),
                                      ' '
                                     )
                             - 1
                            ) ask,
                     file_process_time
                FROM ttec_tcmb_rec_rates_parsing
               WHERE SUBSTR (file_string, 5, 3) = 'TRY') DUAL
       WHERE bid_conversion_rate IS NOT NULL;

   v_oanda_cnt   NUMBER       DEFAULT 0;
   v_tcmb_cnt    NUMBER       DEFAULT 0;
   v_exist       VARCHAR2 (1) DEFAULT NULL;
BEGIN
   BEGIN
      --DELETE FROM cust.ttec_daily_rec_rates_stg;  --code commented by RXNETHI-ARGANO,17/07/23
      DELETE FROM apps.ttec_daily_rec_rates_stg;    --code added by RXNETHI-ARGANO,17/07/23

      COMMIT;
   END;

   -- Count on the Oanda Parsing Table
   BEGIN
      SELECT COUNT (*)
        INTO v_oanda_cnt
        --FROM cust.ttec_oanda_daily_rates_ext_rec   --code commented by RXNETHI-ARGANO,17/07/23
        FROM apps.ttec_oanda_daily_rates_ext_rec     --code added by RXNETHI-ARGANO,17/07/23
       WHERE file_process_time > TO_CHAR (SYSDATE - .25, 'YYYYMMDDhhmi');
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_oanda_cnt := 0;
      WHEN OTHERS
      THEN
         v_oanda_cnt := 0;
   END;

   -- Count on the TCMB Parsing Table
   BEGIN
      SELECT COUNT (*)
        INTO v_tcmb_cnt
        --FROM cust.ttec_tcmb_rec_rates_parsing;   --code commented by RXNETHI-ARGANO,17/07/23
        FROM apps.ttec_tcmb_rec_rates_parsing;     --code added by RXNETHI-ARGANO,17/07/23
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_tcmb_cnt := 0;
      WHEN OTHERS
      THEN
         v_tcmb_cnt := 0;
   END;

   IF v_oanda_cnt > 0
   THEN
      BEGIN
         -- Insert oanda currency rates to staging table
         --INSERT INTO cust.ttec_daily_rec_rates_stg   --code commented by RXNETHI-ARGANO,17/07/23
         INSERT INTO apps.ttec_daily_rec_rates_stg     --code added by RXNETHI-ARGANO,17/07/23
                     (base_from_currency, quote_to_currency, amount, conversion_date, ask,
                      bid_conversion_rate, file_process_time)
            SELECT base_from_currency, quote_to_currency, amount, conversion_date, ask,
                   bid_conversion_rate, file_process_time
              --FROM cust.ttec_oanda_daily_rates_ext_rec   --code commented by RXNETHI-ARGANO,17/07/23
              FROM apps.ttec_oanda_daily_rates_ext_rec     --code added by RXNETHI-ARGANO,17/07/23
             WHERE file_process_time > TO_CHAR (SYSDATE - .25, 'YYYYMMDDhhmi');

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, 'Inserting Oanda Recovery Rates to Staging Table Failed');
      END;

      IF v_tcmb_cnt > 0
      THEN
         FOR r_tcmb_curr_upd IN c_tcmb_curr_upd
         LOOP
            BEGIN
               v_exist := NULL;

               SELECT 'Y'
                 INTO v_exist
                 --FROM cust.ttec_daily_rec_rates_stg   --code commented by RXNETHI-ARGANO,17/07/23
                 FROM apps.ttec_daily_rec_rates_stg     --code added by RXNETHI-ARGANO,17/07/23
                WHERE base_from_currency = r_tcmb_curr_upd.base_from_currency
                  AND quote_to_currency = r_tcmb_curr_upd.quote_to_currency;

               IF v_exist IS NOT NULL
               THEN
                  -- Update TCMB currency Rates in the staging table on top of Oanda Rates.
                  --UPDATE cust.ttec_daily_rec_rates_stg  --code commented by RXNETHI-ARGANO,17/07/23
                  UPDATE apps.ttec_daily_rec_rates_stg    --code added by RXNETHI-ARGANO,17/07/23
                     SET ask = r_tcmb_curr_upd.ask,
                         bid_conversion_rate = r_tcmb_curr_upd.bid_conversion_rate
                   WHERE base_from_currency = r_tcmb_curr_upd.base_from_currency
                     AND quote_to_currency = r_tcmb_curr_upd.quote_to_currency;

                  fnd_file.put_line (fnd_file.LOG,
                                        'Update TCMB Recovery Successful:'
                                     || r_tcmb_curr_upd.base_from_currency
                                     || '-'
                                     || r_tcmb_curr_upd.quote_to_currency
                                     || '-'
                                     || r_tcmb_curr_upd.bid_conversion_rate
                                     || '-'
                                     || r_tcmb_curr_upd.file_process_time
                                    );

                  --UPDATE cust.ttec_daily_rec_rates_stg  --code commented by RXNETHI-ARGANO,17/07/23
                  UPDATE apps.ttec_daily_rec_rates_stg    --code added by RXNETHI-ARGANO,17/07/23
                     SET ask = r_tcmb_curr_upd.ask,
                         bid_conversion_rate = 1 / r_tcmb_curr_upd.bid_conversion_rate
                   WHERE base_from_currency = r_tcmb_curr_upd.quote_to_currency
                     AND quote_to_currency = r_tcmb_curr_upd.base_from_currency;

                  fnd_file.put_line (fnd_file.LOG,
                                        'Update TCMB Recovery Successful:'
                                     || r_tcmb_curr_upd.quote_to_currency
                                     || '-'
                                     || r_tcmb_curr_upd.base_from_currency
                                     || '-'
                                     || (1 / r_tcmb_curr_upd.bid_conversion_rate)
                                     || '-'
                                     || r_tcmb_curr_upd.file_process_time
                                    );
                  COMMIT;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  fnd_file.put_line
                             (fnd_file.LOG,
                                 'Update TCMB Recovery Not Successful (No Matching Currency available):'
                              || r_tcmb_curr_upd.base_from_currency
                              || '-'
                              || r_tcmb_curr_upd.quote_to_currency
                              || '-'
                              || r_tcmb_curr_upd.bid_conversion_rate
                              || '-'
                              || r_tcmb_curr_upd.file_process_time
                             );
            END;
         END LOOP;
      END IF;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      ROLLBACK;
      NULL;
   WHEN OTHERS
   THEN
      ROLLBACK;
      RAISE;
END ttec_gl_tcmb_rec_rates_upload;
/
show errors;
/