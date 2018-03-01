SELECT
CWOLI_WO_NO AS workOrderNum,
CWOLI_LINE_NO AS lineNum,
CWOLI_ITEM_CODE AS itemCode,
CWOLI_DESCR AS description,
CWOLI_QTY AS quantity,
CWOLI_UOM AS uom,
CWOLI_CHARGE_AMT AS chargeAmount,
CWOLI_EXEMPT_AMT AS exemptAmount,
CWOLI_RC_CODE AS rcCode,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc_billing.ZCWOS_WO_LINE_ITEM;