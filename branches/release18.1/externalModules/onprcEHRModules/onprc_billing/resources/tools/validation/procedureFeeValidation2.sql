--finds items present in invoicedItems, but not expected to bill
PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
i.*
FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.invoicedItems i

LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_billing.procedureFeeRates lf ON (
  lf.sourceRecord = i.sourceRecord
  AND lf.Id = i.Id
  AND lf.date = i.date
  and lf.chargeId = i.chargeId
)

WHERE lf.sourceRecord IS NULL AND i.category IN ('Surgical Procedure', 'Clinical Procedure', 'Surgery')

AND CAST(i.date AS DATE) >= StartDate AND CAST(i.date as DATE) <= EndDate