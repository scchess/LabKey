SELECT
SCI_PK AS pdlPk,
SCI_SC_FK AS pdlScFk,
SCI_CHARGE_ID AS chargeId,
SCI_ACTIVE_YN AS isActive,
SCI_SORT_ORDER AS sortOrder,
SCI_COMMENT AS comments,
OBJECTID AS objectid,
DATE_TIME
FROM
cnprcSrc_billing_srl.SRL_CHARGE_ID;
