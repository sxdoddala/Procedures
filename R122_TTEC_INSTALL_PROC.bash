# ---------------------------- CONFIDENTIAL ---------------------------------
# This file contains proprietary information of TTEC and is
# tendered subject to the condition that no copy or other reproduction be
# made, in whole or in part, and that no use be made of the information
# herein except for the purpose for which it is transmitted without express
# written permission of Enterprise Products.
# ---------------------------------------------------------------------------
#  MODULE       	: XX
#  Template Version : 1.0.0
#
#
# --------------------------------------------------------------------------
# VERSION  DATE        NAME                DESCRIPTION
# -------  --------   -----------------    ---------------------------------
# 1.0     28/Jun/2023  RPANIGRAHI(ARGANO)  Intial Version
# --------------------------------------------------------------------------
INSTALL_DIR=$CUST_TOP/install
OUT_DIR=$INSTALL_DIR/out
OUTFILE=$OUT_DIR/R122_TTEC_INSTALL_SQL.out

echo  "************* Custom Object Migration START **************"  > $OUTFILE
chmod 777 $OUTFILE

# ---------------------------------------------------------------------------
#  REQUIRED INPUT - START
# ---------------------------------------------------------------------------
#


#
# ---------------------------------------------------------------------------
#  REQUIRED MIGRATION FILES - START
# ---------------------------------------------------------------------------
#

echo " ----------------------------------------------------"
echo  "Please enter the following passwords :"
echo " ----------------------------------------------------"
echo Enter APPS Password :

read apps_pw


#CONNECT_STRING=`echo $APPS_JDBC_URL | cut -d @ -f2`

#
# ---------------------------------------------------------------------------
#  REQUIRED MIGRATION FILES - END
# ---------------------------------------------------------------------------
#

cd $CUST_TOP/install

echo "--------------------------------------------------------" >> $OUTFILE
echo " COPY FILES FROM INSTALL TO RESPECTIVE DIRECTORIES - END  " >> $OUTFILE
echo "--------------------------------------------------------" >> $OUTFILE


echo " --------------------------------------------------------------  " >> $OUTFILE
echo " Start Executing SQL scripts from sql directory                  " >> $OUTFILE
echo " --------------------------------------------------------------  " >> $OUTFILE

# echo "Executing ADP_PRINT_PKG.pkb"  >> $OUTFILE
# sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
# SET SCAN OFF
# SET DEFINE OFF
# @ADP_PRINT_PKG.pkb
# exit
# EOF
# echo "Completed ADP_PRINT_PKG.pkb" >> $OUTFILE
echo "Executing TTEC_PO_OPEN_RPT.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_PO_OPEN_RPT.sql
exit
EOF
echo "Completed TTEC_PO_OPEN_RPT.sql" >> $OUTFILE

echo "Executing TELETECHPROFILES.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TELETECHPROFILES.sql
exit
EOF
echo "Completed TELETECHPROFILES.sql" >> $OUTFILE

echo "Executing TTEC_SALARYGRADERATESBYHIER.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_SALARYGRADERATESBYHIER.sql
exit
EOF
echo "Completed TTEC_SALARYGRADERATESBYHIER.sql" >> $OUTFILE

echo "Executing TT_COSTING_INT.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TT_COSTING_INT.sql
exit
EOF
echo "Completed TT_COSTING_INT.sql" >> $OUTFILE

echo "Executing TTEC_DELETE_EMPLOYEE_BENEFIT.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_DELETE_EMPLOYEE_BENEFIT.sql
exit
EOF
echo "Completed TTEC_DELETE_EMPLOYEE_BENEFIT.sql" >> $OUTFILE

echo "Executing TT_GROSS_TO_NET_REPORT.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TT_GROSS_TO_NET_REPORT.sql
exit
EOF
echo "Completed TT_GROSS_TO_NET_REPORT.sql" >> $OUTFILE

echo "Executing TTEC_GLOBAL_ORACLE_OUTAGE.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GLOBAL_ORACLE_OUTAGE.sql
exit
EOF
echo "Completed TTEC_GLOBAL_ORACLE_OUTAGE.sql" >> $OUTFILE

echo "Executing TTEC_CONDOR_EMP.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_CONDOR_EMP.sql
exit
EOF
echo "Completed TTEC_CONDOR_EMP.sql" >> $OUTFILE

echo "Executing TTEC_1044976_DELETE_REG_SAL.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_1044976_DELETE_REG_SAL.sql
exit
EOF
echo "Completed TTEC_1044976_DELETE_REG_SAL.sql" >> $OUTFILE

echo "Executing TTEC_H_MX_CNV_SAL.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_H_MX_CNV_SAL.sql
exit
EOF
echo "Completed TTEC_H_MX_CNV_SAL.sql" >> $OUTFILE

echo "Executing TTEC_ATELKA_DELETE_ELEMENT.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_ATELKA_DELETE_ELEMENT.sql
exit
EOF
echo "Completed TTEC_ATELKA_DELETE_ELEMENT.sql" >> $OUTFILE

echo "Executing TTEC_HR_EMP_SPARES.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_HR_EMP_SPARES.sql
exit
EOF
echo "Completed TTEC_HR_EMP_SPARES.sql" >> $OUTFILE

echo "Executing TTEC_H_BR_CNV_SAL.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_H_BR_CNV_SAL.sql
exit
EOF
echo "Completed TTEC_H_BR_CNV_SAL.sql" >> $OUTFILE

echo "Executing TTEC_H_AR_CNV_SAL.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_H_AR_CNV_SAL.sql
exit
EOF
echo "Completed TTEC_H_AR_CNV_SAL.sql" >> $OUTFILE

echo "Executing TT_HIERARCHY_REPORT.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TT_HIERARCHY_REPORT.sql
exit
EOF
echo "Completed TT_HIERARCHY_REPORT.sql" >> $OUTFILE

echo "Executing TTEC_APR_MATRIX.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_APR_MATRIX.sql
exit
EOF
echo "Completed TTEC_APR_MATRIX.sql" >> $OUTFILE

echo "Executing TT_EMP_PTO_LOCATION.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TT_EMP_PTO_LOCATION.sql
exit
EOF
echo "Completed TT_EMP_PTO_LOCATION.sql" >> $OUTFILE

echo "Executing TTEC_GL_DAILY_RATES_INT_LOAD.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GL_DAILY_RATES_INT_LOAD.sql
exit
EOF
echo "Completed TTEC_GL_DAILY_RATES_INT_LOAD.sql" >> $OUTFILE

echo "Executing TTEC_GL_REC_RATES_INT_LOAD.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GL_REC_RATES_INT_LOAD.sql
exit
EOF
echo "Completed TTEC_GL_REC_RATES_INT_LOAD.sql" >> $OUTFILE

echo "Executing TTEC_CARRY_OVER.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_CARRY_OVER.sql
exit
EOF
echo "Completed TTEC_CARRY_OVER.sql" >> $OUTFILE

echo "Executing TTEC_USER_INSERT.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_USER_INSERT.sql
exit
EOF
echo "Completed TTEC_USER_INSERT.sql" >> $OUTFILE

echo "Executing TTEC_GL_ALLOCATION_INTF_PKG_1.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GL_ALLOCATION_INTF_PKG_1.sql
exit
EOF
echo "Completed TTEC_GL_ALLOCATION_INTF_PKG_1.sql" >> $OUTFILE

echo "Executing TTEC_H_AR_CNV_ADD.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_H_AR_CNV_ADD.sql
exit
EOF
echo "Completed TTEC_H_AR_CNV_ADD.sql" >> $OUTFILE

echo "Executing TTEC_H_BR_CNV_ADD.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_H_BR_CNV_ADD.sql
exit
EOF
echo "Completed TTEC_H_BR_CNV_ADD.sql" >> $OUTFILE

echo "Executing TTEC_H_ES_CNV_ADD.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_H_ES_CNV_ADD.sql
exit
EOF
echo "Completed TTEC_H_ES_CNV_ADD.sql" >> $OUTFILE

echo "Executing TTEC_H_MX_CNV_ADD.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_H_MX_CNV_ADD.sql
exit
EOF
echo "Completed TTEC_H_MX_CNV_ADD.sql" >> $OUTFILE

echo "Executing TTEC_H_UK_CNV_ADD.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_H_UK_CNV_ADD.sql
exit
EOF
echo "Completed TTEC_H_UK_CNV_ADD.sql" >> $OUTFILE

echo "Executing TTEC_H_UK_CNV_CON_ADD.sql"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_H_UK_CNV_CON_ADD.sql
exit
EOF
echo "Completed TTEC_H_UK_CNV_CON_ADD.sql" >> $OUTFILE

echo " OUT FILE = "
ls -lrt $OUTFILE
echo  "************* Custom Object Migration  COMPLETE ************** " >> $OUTFILE
