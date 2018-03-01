/*
 * Copyright (c) 2017 LabKey Corporation
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

SELECT demo.Id,
CASE WHEN animalUtilizations.fund_types_by_animal = 'V' THEN 'Pilot'
     WHEN animalUtilizations.fund_types_by_animal = 'X' THEN 'PI Funded'
     WHEN animalUtilizations.fund_types_by_animal = 'B' THEN 'Base Grant'
     WHEN animalUtilizations.fund_types_by_animal = 'O' THEN 'Other'
     ELSE 'Expired/Unknown'  -- this will happen if any dupes were found earlier, even if they're all the same fund type!
END AS fundingCategory,
animalUtilizations.fund_types_by_animal
FROM Demographics demo
LEFT JOIN
(
    SELECT activePayor.Id,
           group_concat(uniqueAccountOrChargeIds.fund_types) AS fund_types_by_animal
    FROM (
        SELECT currentAccountOrChargeIds.accountOrChargeId,
               group_concat(currentAccountOrChargeIds.fund_type) AS fund_types
        FROM (
            SELECT
                CASE WHEN acct2.fund_type IN ('O', 'X') THEN acct2.acct_id
                WHEN acct2.fund_type IN ('B', 'V') THEN acct2.charge_id
                END AS accountOrChargeId,
                acct2.fund_type
            FROM cnprc_billing_linked.account acct2
            WHERE now() >= acct2.begin_date
              AND now() <= acct2.end_date
        ) currentAccountOrChargeIds
        GROUP BY accountOrChargeId
    ) uniqueAccountOrChargeIds
    JOIN study.payor_assignments activePayor
        ON (SUBSTRING(activePayor.payor_id, 7, 10) = uniqueAccountOrChargeIds.accountOrChargeId)
        AND (activePayor.enddate IS NULL)
    GROUP BY activePayor.Id
) animalUtilizations
ON animalUtilizations.Id = demo.Id
WHERE demo.calculated_status = 'Alive'
