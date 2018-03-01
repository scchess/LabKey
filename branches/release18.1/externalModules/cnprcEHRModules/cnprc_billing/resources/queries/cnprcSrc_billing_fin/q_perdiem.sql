SELECT
ZP_PAYOR_ID AS payorId,
ZP_ACCOUNT_ID AS accountId,
ZP_CHARGE_ID AS chargeId,
ZP_PROJECT_ID AS projectCode,
ZP_FUND_SOURCE_RANK AS fundSourceRank,
ZP_FUND_SOURCE_CODE AS fundSourceCode,
ZP_SPECIES AS species,
ZP_AN_ID AS animalId,
ZP_DATE AS perdiemDate,
ZP_LOCATION_PREFIX AS locationPrefix,
ZP_LOCATION AS location,
ZP_RATE_CLASS AS rateClass,
ZP_BASE_RATE AS baseRate,
ZP_DEDUCTION_FLAG AS deductionFlag,
ZP_DEDUCTION_RATE AS deductionRate,
ZP_NET_CHARGE AS netCharge,
ZP_BILLING_CLOSED AS billingClosed,
ZP_CREATION_DATE AS creationDate,
ZP_LOCATION_RATE_CLASS AS locationRateClass,
ZP_AN_DAYS_OF_AGE AS animalDaysOfAge,
ZP_RATE_TIER_CODE_FK AS rateRierCodeFk
FROM cnprcSrc_billing_fin.ZPERDIEM;