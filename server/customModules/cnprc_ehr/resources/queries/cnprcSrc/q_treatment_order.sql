/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
SELECT
PRIMED_TREATMENT_PK AS treatmentPk,
PT_AN_ID AS Id,
PT_START_DATE AS startDate,
PT_CNPRC_PROJECT AS projectCode,
PT_TREATMENT_VOLUME AS volume,
PT_TREATMENT_VOLUME_UNITS AS vol_units,
PT_DRUG_CONCEN_PER_UNIT AS concentration,
PT_DRUG_CONCEN_UNITS AS conc_units,
PT_TOTAL_DOSE_AMOUNT AS amount,
PT_TOTAL_DOSE_UNITS AS amount_units,
PT_ROUTE AS route,
PT_END_DATE AS enddate,
PT_FREQUENCY_USED AS frequency,
PT_DOSE_PER_UNIT_USED AS dosage,
PT_DOSE_UNITS AS dosage_units,
PT_TREATMENT_TYPE AS category,
PT_SEQ AS seq,
PT_FORMULARY_NAME_FK AS formularyNameFk,
PT_FORMULARY_DOSING_FK AS formularyDosingFk,
PT_DRUG_CALC_DATA_AVAIL_YN AS drugCalcDataAvailable,
PT_AN_WT_OVERRIDE_YN AS weightOverride,
PT_AN_WT_DB AS weightDb,
PT_AN_WT_USED AS weightUsed,
PT_DRUG_CALC_OVERRIDE_YN AS drugCalOverride,
PT_DRUG_NAME AS drugName,
PT_DOSE_PER_UNIT_DB AS dosePerUnit,
PT_FREQUENCY_DB AS frequencyDb,
PT_DURATION_DB AS durationDb,
PT_DURATION_USED AS durationUsed,
PT_DOSING_NOTES AS dosingNotes,
PT_USER_COMMENT AS userComment,
PT_NEXT_PRINT_FLAG_UPDATE_YN AS nextPrintFlagUpdate,
PT_TREATMENT_CREATED_BY AS treatmentCreator,
PT_PRESCRIBING_VETERINARIAN AS prescribingVet,
PT_BILLING_ITEM_CODE AS billingItemCode,
PT_BILLING_AMOUNT AS billingAmt,
PT_CNPRC_BILLING_ID AS cnprcBillingId,
PT_RX_INVALID_OR_NEVER_GIVEN AS rxInvalidOrNeverGiven,
OBJECTID as objectid,
DATE_TIME
FROM cnprcSrc.ZPRIMED_TREATMENT

UNION ALL

SELECT
ANIMAL_TREATMENT_PK AS treatmentPk,
AT_AN_ID AS Id,
AT_START_DATE AS startDate,
AT_CNPRC_PROJECT AS projectCode,
AT_TREATMENT_VOLUME AS volume,
AT_TREATMENT_VOLUME_UNITS AS vol_units,
NULL AS concentration,
NULL AS conc_units,
AT_TOTAL_DOSE_AMOUNT AS amount,
AT_TOTAL_DOSE_UNITS AS amount_units,
AT_ROUTE AS route,
AT_END_DATE AS enddate,
AT_FREQUENCY_USED AS frequency,
NULL AS dosage,
NULL AS dosage_units,
AT_TREATMENT_TYPE AS category,
AT_SEQ AS seq,
AT_FORMULARY_NAME_FK AS formularyNameFk,
NULL AS formularyDosingFk,
AT_DRUG_CALC_DATA_AVAIL_YN AS drugCalcDataAvailable,
AT_AN_WT_OVERRIDE_YN AS weightOverride,
NULL AS weightDb,
AT_AN_WT_USED AS weightUsed,
AT_DRUG_CALC_OVERRIDE_YN AS drugCalOverride,
AT_DRUG_NAME AS drugName,
NULL AS dosePerUnit,
NULL AS frequencyDb,
NULL AS durationDb,
AT_DURATION_USED AS durationUsed,
NULL AS dosingNotes,
AT_USER_COMMENT AS userComment,
NULL AS nextPrintFlagUpdate,
AT_TREATMENT_CREATED_BY AS treatmentCreator,
NULL AS prescribingVet,
NULL AS billingItemCode,
NULL AS billingAmt,
NULL AS cnprcBillingId,
AT_RX_INVALID_OR_NEVER_GIVEN AS rxInvalidOrNeverGiven,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZAN_TREATMENT_SCRUBBED;
