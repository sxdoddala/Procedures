create or replace PROCEDURE      ttec_gl_allocation_intf_pkg_1 (
   errbuf          OUT      VARCHAR2,
   retcode         OUT      VARCHAR2,
   p_je_category   IN       VARCHAR2,
   p_je_source     IN       VARCHAR2,
   p_ledger_name   IN       VARCHAR2,
   p_email_list    IN       VARCHAR2
)
AS
   v_resp_id          fnd_responsibility.responsibility_id%TYPE;
   c_cnt              NUMBER;
   v_resp_app_id      fnd_responsibility.application_id%TYPE;
   l_ledger_id        NUMBER;
   v_procstep         VARCHAR2 (200);
   v_request_status   BOOLEAN;
   v_errmsg           VARCHAR2 (230);
   n_requestid        NUMBER (15)                                 := 0;
   v_user_id          fnd_user.user_id%TYPE;
   l_batch_name       gl_interface.reference1%TYPE;
   l_sob_id           gl_sets_of_books.set_of_books_id%TYPE;
   l_sob_name         gl_sets_of_books.short_name%TYPE;
   l_currency         gl_sets_of_books.currency_code%TYPE;
   l_request_id       fnd_concurrent_requests.request_id%TYPE;
   l_phase            VARCHAR2 (100);
   l_status           VARCHAR2 (100);
   l_dev_phase        VARCHAR2 (100);
   l_dev_status       VARCHAR2 (100);
   l_message          VARCHAR2 (240);
   l_status_b         BOOLEAN;
   success            BOOLEAN;
   stop_program       EXCEPTION;
   l_created_by       NUMBER;
   v_email_flag       VARCHAR (1)                                 := 'N';
   x_request_id       NUMBER;
BEGIN
   l_request_id := fnd_global.conc_request_id;
   v_user_id := fnd_global.user_id;

-- Lookup the Responsibility ID for the Current Request
   SELECT responsibility_id
     INTO v_resp_id
     FROM fnd_concurrent_requests
    WHERE request_id = l_request_id;

-- Get the Application ID for the Input Responsibility ID
   SELECT application_id
     INTO v_resp_app_id
     FROM fnd_responsibility
    WHERE responsibility_id = v_resp_id;

   l_ledger_id := apps.ttec_gl_interface_pkg.get_ledger_id (p_ledger_name);

   BEGIN
      UPDATE ttec_gl_staging_intf
         SET request_group_id = l_request_id
       WHERE status = 'NEW'
         AND user_je_category_name = p_je_category
         AND user_je_source_name = p_je_source
         AND ledger_name = p_ledger_name;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.put_line (fnd_file.LOG, 'In error block');
   END;

   fnd_file.put_line (fnd_file.LOG, v_resp_app_id || ' ' || v_resp_id);

   BEGIN
      SELECT COUNT (*)
        INTO c_cnt
        FROM ttec_gl_staging_intf
       WHERE status = 'NEW' AND request_group_id = l_request_id;

      IF c_cnt > 0
      THEN
         fnd_file.put_line (fnd_file.LOG, 'New Records count is ' || c_cnt);
         NULL;
         fnd_global.apps_initialize (user_id           => v_user_id,
                                     resp_id           => v_resp_id,
                                     resp_appl_id      => v_resp_app_id
                                    );
         -- Submitting 'TeleTech Allocation GL Interface' request set
         v_procstep := 'Setting Context for Request Set';
         v_errmsg := 'Error while setting Conext for Request Set';
         success :=
            fnd_submit.set_request_set
                                 (application      => 'CUST',
                                  request_set      => 'TTEC_HYP_ALLOC_GL_IFACE_SET'
                                 );
         fnd_file.put_line (fnd_file.LOG, 'Step1' || n_requestid);

         IF (NOT success)
         THEN
            RAISE stop_program;
         END IF;

         IF (success)
         THEN
            v_procstep := 'Submitting Stage10 for Request Set';
            v_errmsg := 'Error while Submitting Stage10 for Request Set';
            success :=
               fnd_submit.submit_program (application      => 'CUST',
                                          program          => 'TTECHYPGLINTF',
                                          stage            => 'STAGE10',
                                          argument1        => p_je_category,
                                          argument2        => p_je_source,
                                          argument3        => l_request_id
                                         );
            v_procstep := 'Submitting Stage20 for Request Set';
            v_errmsg := 'Error while Submitting Stage20 for Request Set';
            success :=
               fnd_submit.submit_program (application      => 'CUST',
                                          program          => 'TTECJEIMPORT',
                                          stage            => 'STAGE20',
                                          argument1        => p_je_category,
                                          argument2        => p_je_source,
                                          argument3        => l_request_id,
                                          argument4        => l_ledger_id
                                         );
            v_procstep := 'Submitting Request Set';
            v_errmsg := 'Error while Submitting Request Set';
            n_requestid :=
               fnd_submit.submit_set (start_time       => NULL,
                                      sub_request      => FALSE);
            fnd_file.put_line (fnd_file.LOG,
                               'Request ID for Request Set : ' || n_requestid
                              );
            COMMIT;
         END IF;

         IF n_requestid = 0
         THEN
            fnd_file.put_line (fnd_file.LOG, 'Request is not submitted');
         END IF;

         IF n_requestid > 0
         THEN
            fnd_file.put_line (fnd_file.LOG,
                               'Request is  submitted' || n_requestid
                              );

            LOOP
               fnd_file.put_line (fnd_file.LOG,
                                  'n_requestid: ' || n_requestid
                                 );
               v_request_status :=
                  fnd_concurrent.wait_for_request (request_id      => n_requestid,
                                                   INTERVAL        => 2,
                                                   max_wait        => 60,
                                                   phase           => l_phase,
                                                   status          => l_status,
                                                   dev_phase       => l_dev_phase,
                                                   dev_status      => l_dev_status,
                                                   MESSAGE         => l_message
                                                  );
               EXIT WHEN UPPER (l_phase) = 'COMPLETED'
                     OR UPPER (l_status) IN
                                         ('CANCELLED', 'ERROR', 'TERMINATED');
            END LOOP;

            fnd_file.put_line (fnd_file.LOG,
                               ' l_request_id: ' || l_request_id);

            BEGIN
               UPDATE ttec_gl_staging_intf a
                  SET processed_flag = 'Y'
                WHERE validate_flag = 'Y'
                  AND status = 'SUCCESS'
                  AND request_group_id = l_request_id
                  AND user_je_category_name = p_je_category
                  AND user_je_source_name = p_je_source
                  AND NOT EXISTS (
                         SELECT 1
                           FROM gl_interface b
                          WHERE reference23 = a.request_group_id
                            AND a.user_je_category_name =
                                                       b.user_je_category_name
                            AND a.user_je_source_name = b.user_je_source_name
                            AND b.GROUP_ID = a.GROUP_ID);

               fnd_file.put_line
                  (fnd_file.LOG,
                      'No of records updated from staging table:Processed records:'
                   || TO_CHAR (SQL%ROWCOUNT)
                  );
               COMMIT;
               v_email_flag := 'Y';
            EXCEPTION
               WHEN OTHERS
               THEN
                  fnd_file.put_line
                     (fnd_file.LOG,
                         ' Error in updating Staging interface for proccesed records'
                      || SQLERRM
                     );
                  v_email_flag := 'N';
            END;

            BEGIN
               UPDATE ttec_gl_staging_intf a
                  SET processed_flag = 'N'
                WHERE validate_flag = 'Y'
                  AND status = 'SUCCESS'
                  AND request_group_id = l_request_id
                  AND user_je_category_name = p_je_category
                  AND user_je_source_name = p_je_source
                  AND EXISTS (
                         SELECT 1
                           FROM gl_interface b
                          WHERE reference23 = a.request_group_id
                            AND a.user_je_category_name =
                                                       b.user_je_category_name
                            AND a.user_je_source_name = b.user_je_source_name
                            AND b.GROUP_ID = a.GROUP_ID);

               fnd_file.put_line
                  (fnd_file.LOG,
                      'No of records updated from staging table:UnProcessed records:'
                   || TO_CHAR (SQL%ROWCOUNT)
                  );
               COMMIT;
               v_email_flag := 'Y';
            EXCEPTION
               WHEN OTHERS
               THEN
                  fnd_file.put_line
                     (fnd_file.LOG,
                         ' Error in updating Staging interface for unproccesed records'
                      || SQLERRM
                     );
                  v_email_flag := 'N';
            END;

            fnd_file.put_line (fnd_file.LOG,
                                  ' Before Email Block with flag stastus as :'
                               || v_email_flag
                              );

            -----calling Email program
            BEGIN
               IF v_email_flag = 'Y'
               THEN
                  x_request_id :=
                     fnd_request.submit_request (application      => 'CUST',
                                                 program          => 'TTECGLEMAIL',
                                                 argument1        => p_email_list,
                                                 argument2        => l_request_id
                                                );
                  COMMIT;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  fnd_file.put_line
                                  (fnd_file.LOG,
                                      ' Error while submitting email program'
                                   || SQLERRM
                                  );
            END;
            ----end of email program

         END IF;
      ELSE
         fnd_file.put_line (fnd_file.LOG,
                            ' No Records to Process' || SQLERRM);
      END IF;
   EXCEPTION
      WHEN stop_program
      THEN
         fnd_file.put_line (fnd_file.LOG,
                            'Step :' || v_procstep || ' Message :' || v_errmsg
                           );
      WHEN OTHERS
      THEN
         NULL;
   END;
END;
/
show errors;
/