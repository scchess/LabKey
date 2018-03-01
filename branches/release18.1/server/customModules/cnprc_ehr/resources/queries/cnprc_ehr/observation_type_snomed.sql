
SELECT
  ot.obsCode,
  GROUP_CONCAT(ot.snomedCode, '; ') as snomed,
  GROUP_CONCAT(sn.meaning, '; ') as snomedMeaning,
  MAX(ot.pregnancyDisplayFlag) as pregnancyDisplayFlag,
  MAX(ot.visualSignsOnlyFlag) as visualSignsOnlyFlag
  FROM cnprc_ehr.observation_types ot
  JOIN ehr_lookups.snomed sn
  ON ot.snomedCode = sn.code
GROUP BY ot.obsCode