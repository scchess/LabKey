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
SELECT
  casesAndMorningHealthObs.Id,
  casesAndMorningHealthObs.Location,
  casesAndMorningHealthObs.AdmitType,
  casesAndMorningHealthObs.Problem,
  casesAndMorningHealthObs.AdmitDate,
  casesAndMorningHealthObs.DaysAdmitted,
  casesAndMorningHealthObs.MHObs,
  casesAndMorningHealthObs.ProjectCode,
  casesAndMorningHealthObs.Area,
  casesAndMorningHealthObs.Room,
  cr.p,
  cr.p2,
  cr.remark,
  NULL AS AssignedVet,
  NULL AS NextFollowUp,
  casesAndMorningHealthObs.history,
  casesAndMorningHealthObs.confirm AS confirm,
  (CASE WHEN meds.medCount > 0 THEN meds.medNames ELSE NULL END) as meds

FROM
  (
    SELECT
      cases.Id,
      cases.Id.curLocation.location                        AS Location,
      cases.admitType                                      AS AdmitType,
      cases.problem                                        AS Problem,
      cases.date                                           AS AdmitDate,
      cases.duration                                       AS DaysAdmitted,
      ''                                                   AS MHObs,
      cases.Id.demographicsActiveAssignment.primaryProject AS ProjectCode,
      cases.Id.curLocation.Area,
      cases.Id.curLocation.Room,
      cases.Id.Demographics.history,
      '' AS confirm
    FROM
      study.cases
    WHERE cases.endDate IS NULL
    UNION ALL
    SELECT
      mho.Id,
      mho.location                                       AS Location,
      'MH'                                               AS AdmitType,
      ''                                                 AS Problem,
      NULL                                               AS AdmitDate,
      mho.duration                                       AS DaysAdmitted,
      mhs.observation                                    AS MHObs,
      mho.Id.demographicsActiveAssignment.primaryProject AS ProjectCode,
      mho.Id.curLocation.Area,
      mho.Id.curLocation.Room,
      mho.Id.Demographics.history,
      'Confirm' AS confirm
    FROM study.morningHealthObs mho
      JOIN study.morningHealthSigns mhs ON mhs.id = mho.id AND mhs.date = mho.date
    WHERE mho.endDate IS NULL
          AND mho.date > timestampadd('SQL_TSI_DAY', -1 , curdate())
          AND (
                mhs.observation LIKE '%POORAPP%' OR
                mhs.observation LIKE '%LIQDSTL%' OR
                mhs.observation LIKE '%DEHYDRT%'
          )
  ) casesAndMorningHealthObs

  LEFT JOIN (SELECT
               max(clinremarks.date) AS maxDate,
               clinremarks.Id
             FROM clinremarks
             GROUP BY id) latestClinRemark ON latestClinRemark.id = casesAndMorningHealthObs.id
  LEFT JOIN clinremarks cr ON cr.id = latestClinRemark.id AND cr.date = latestClinRemark.maxDate
  LEFT JOIN (Select id, count(*)  AS medCount, group_concat(drugName) as medNames from study.treatmentOrdersActive GROUP BY id) meds on meds.id = casesAndMorningHealthObs.Id


