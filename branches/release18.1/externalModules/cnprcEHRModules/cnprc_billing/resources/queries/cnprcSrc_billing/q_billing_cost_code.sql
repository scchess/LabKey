SELECT
BCC_SERVICE_CODE                 AS     SERVICE_CODE
,BCC_COST_CODE                   AS     COST_CODE
,BCC_BEGIN_DATE                  AS     BEGIN_DATE
,BCC_COST_CODE_TYPE              AS     COST_CODE_TYPE
,BCC_BASE_GRANT_EXEMPT_FACTOR    AS     BASE_GRANT_EXEMPT_FACTOR
,BCC_ROUTINE_SERV_EXEMPT_FACTOR  AS     ROUTINE_SERV_EXEMPT_FACTOR
,BCC_OLD_COST_CODE               AS     OLD_COST_CODE
,BCC_SALES_TAXABLE_FLAG          AS     SALES_TAXABLE_FLAG
,BCC_CHARGE_OBJ                  AS     CHARGE_OBJ
,BCC_CHARGE_CT_0                 AS     CHARGE_CT_0
,BCC_CHARGE_CT_1                 AS     CHARGE_CT_1
,BCC_CHARGE_CT_2                 AS     CHARGE_CT_2
,BCC_CHARGE_CT_3                 AS     CHARGE_CT_3
,BCC_CHARGE_CT_4                 AS     CHARGE_CT_4
,BCC_CHARGE_CT_5                 AS     CHARGE_CT_5
,BCC_CHARGE_CT_6                 AS     CHARGE_CT_6
,BCC_CHARGE_CT_7                 AS     CHARGE_CT_7
,BCC_CHARGE_CT_8                 AS     CHARGE_CT_8
,BCC_CHARGE_CT_9                 AS     CHARGE_CT_9
,BCC_CHARGE_CT_10                AS     CHARGE_CT_10
,BCC_CHARGE_CT_11                AS     CHARGE_CT_11
,BCC_CHARGE_CT_12                AS     CHARGE_CT_12
,BCC_CHARGE_CT_13                AS     CHARGE_CT_13
,BCC_CHARGE_CT_14                AS     CHARGE_CT_14
,BCC_CHARGE_CT_15                AS     CHARGE_CT_15
,BCC_CHARGE_CT_16                AS     CHARGE_CT_16
,BCC_CHARGE_CT_17                AS     CHARGE_CT_17
,BCC_CHARGE_CT_18                AS     CHARGE_CT_18
,BCC_CHARGE_CT_19                AS     CHARGE_CT_19
,BCC_INCOME_ID                   AS     INCOME_ID
,BCC_INCOME_SUB                  AS     INCOME_SUB
,BCC_INCOME_OBJ                  AS     INCOME_OBJ
,BCC_INCOME_CT                   AS     INCOME_CT
,BCC_COSTXFER_TO_ID              AS     COSTXFER_TO_ID
,BCC_COSTXFER_TO_SUB             AS     COSTXFER_TO_SUB
,BCC_COSTXFER_TO_OBJ             AS     COSTXFER_TO_OBJ
,BCC_COSTXFER_TO_CT              AS     COSTXFER_TO_CT
,BCC_COSTXFER_FR_ID              AS     COSTXFER_FR_ID
,BCC_COSTXFER_FR_SUB             AS     COSTXFER_FR_SUB
,BCC_COSTXFER_FR_OBJ             AS     COSTXFER_FR_OBJ
,BCC_COSTXFER_FR_CT              AS     COSTXFER_FR_CT
,BCC_EXTERNAL_DESCR              AS     EXTERNAL_DESCR
,BCC_END_DATE                    AS     END_DATE
,BCC_RC_CODE                     AS     RC_CODE
,BCC_ACCT_TYPE                   AS     ACCT_TYPE
,BCC_NUD_EXEMPT_FLAG             AS     NUD_EXEMPT_FLAG
,Objectid
,Date_time
FROM cnprcSrc_billing.zbilling_cost_code