SELECT DISTINCT
CP_WORK_LOCATION AS Location
FROM
cnprcSrc_complianceAndTraining.ZCRPRC_PERSON
WHERE CP_WORK_LOCATION IS NOT NULL;