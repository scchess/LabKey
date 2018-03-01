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
PARAMETERS(onDate TIMESTAMP)
-- Part 1: select cages with animals
SELECT
housing.Id,
CASE WHEN housing.cage IS NULL THEN housing.room
     ELSE (housing.room || housing.cage)
END AS location,
housing.cage,
clh.cage_size,
clh.rate_class,
animal.demographics.species,
animal.demographics.gender,
animal.demographics.birth,
CASE
    WHEN (animal.demographics.death IS NULL) OR (onDate < animal.demographics.death) THEN onDate
    ELSE animal.demographics.death
END AS deathOrOnDate,
-- Adapted from demographicsMostRecentWeight
(SELECT mostRecentWeight FROM
 	(SELECT
 	 weightData.Id,
     CAST((
     	 SELECT
     	 ROUND(CAST(AVG(w2.weight) AS DOUBLE), 2)  -- this part differs from apexvitals_encl_ondate, which does a straight selection
     	 FROM study.weight w2
     	 WHERE w2.Id=weightData.Id
     	 AND w2.date=weightData.MostRecentWeightDate
 	 ) AS DOUBLE) AS mostRecentWeight
 	 FROM (
     	 SELECT
     	 w.Id,
     	 MAX(w.date) AS MostRecentWeightDate
     	 FROM study.weight w
     	 WHERE w.qcstate.publicdata = true
     	 AND w.weight IS NOT NULL
     	 AND w.date <= onDate
     	 GROUP BY w.Id
 	 ) weightData
    )
 WHERE Id = animal.Id
) MostRecentWeight,
housing.date,
-- Adapted from DemographicsActivePayor
(SELECT group_concat(payor_Assignments.payor_id)
    FROM study.payor_Assignments
    WHERE payor_Assignments.Id = animal.Id
    AND onDate >= payor_Assignments.date
    AND onDate < COALESCE(payor_Assignments.endDate, now())
    GROUP BY payor_Assignments.Id
) payor_ids,
col_assign.colonyCode,
bga.groupCode,
breed_roster.book,  -- potentially incorrect for non-current dates
-- Adapted from DemographicsActiveAssignment
(SELECT
    MAX(latestProjects.primaryProject) AS primaryProject,
    FROM(
    SELECT
    assign.Id,
    (CASE WHEN assign.assignmentStatus='P' THEN MAX(assign.projectCode) END) AS primaryProject,
    FROM study.assignment assign
    WHERE onDate >= assign.date  -- different from DemographicsActiveAssignment, trying to match apexvitals_encl_ondate better
    AND onDate < COALESCE(assign.endDate, now())
    GROUP BY assign.Id, assign.assignmentStatus) latestProjects
    WHERE Id = animal.Id
    GROUP BY latestProjects.Id
) primaryProject,
(SELECT
    MAX(latestProjects.secondaryProjects) AS secondaryProjects
    FROM(
    SELECT
    assign.Id,
    (CASE WHEN assign.assignmentStatus='S' THEN Group_concat(assign.projectCode, ', ') ELSE NULL END) AS secondaryProjects
    FROM study.assignment assign
    WHERE onDate >= assign.date  -- different from DemographicsActiveAssignment, trying to match apexvitals_encl_ondate better
    AND onDate < COALESCE(assign.endDate, now())
    GROUP BY assign.Id, assign.assignmentStatus) latestProjects
    WHERE Id = animal.Id
    GROUP BY latestProjects.Id
) secondaryProjects,
(SELECT
    group_concat(flags.flag, ', ') as flagValues
    FROM study.flags flags
    WHERE flags.Id = animal.Id
    AND onDate >= flags.date
    AND onDate < COALESCE(flags.endDate, now())
    GROUP BY flags.Id
) values,
preg_confirm.conNum,
timestampdiff('SQL_TSI_DAY', preg_confirm.conception, onDate) AS daysPregnant,
preg_confirm.conceptionDateStatus,
preg_confirm.pgComment,
room_enc.supervisor,  -- potentially incorrect for non-current dates
housing.room,
(SELECT
 CASE
     WHEN (pair2.Id IS NULL) AND (pair1.observation <> 'AW') THEN 'DD'
     WHEN (SELECT COUNT(*) FROM study.pairings pair3
           WHERE pair3.Id = animal.Id
           AND pair3.endDate IS NULL)
           > 1
         THEN '**'
     -- CAST is for natural sort
     WHEN CAST(pair1.Id.curLocation.cage AS INTEGER) < CAST(pair2.Id.curLocation.cage AS INTEGER)
         THEN '//'
     WHEN CAST(pair1.Id.curLocation.cage AS INTEGER) > CAST(pair2.Id.curLocation.cage AS INTEGER)
         THEN '\\'
     WHEN pair1.Id < pair2.Id
         THEN '//'
     WHEN pair1.Id > pair2.Id
         THEN '\\'
 END AS PairedSymbol
 FROM study.pairings pair1
 LEFT OUTER JOIN study.pairings pair2 ON pair2.pairId = pair1.pairId
                                       AND pair2.Id <> animal.Id
 WHERE pair1.Id = animal.Id
 AND pair1.endDate IS NULL
 AND animal.curLocation.location IS NOT NULL
 LIMIT 1) AS pairingIndicator,    -- potentially incorrect for non-current dates; possible to make historical but will require some work
SUBSTRING(housing.room, 1, 2) AS area

FROM study.housing
LEFT OUTER JOIN cnprc_ehr.cage_location_history clh ON clh.location =
        (CASE WHEN housing.cage IS NULL THEN housing.room ELSE (housing.room || housing.cage) END)  -- TODO: this is ugly, should split this column in cage_location_history
	  AND (onDate >= clh.from_date) AND (onDate < COALESCE(clh.to_date, now()))
LEFT OUTER JOIN study.animal ON animal.Id = housing.Id
    AND (onDate >= animal.birth.date) AND (onDate < COALESCE(animal.death.date, now()))
LEFT OUTER JOIN cnprc_ehr.room_enclosure room_enc ON room_enc.room = housing.room
LEFT OUTER JOIN study.payor_assignments pay_assign ON pay_assign.Id = animal.Id
    AND (onDate >= pay_assign.date) AND (onDate < COALESCE(pay_assign.endDate, now()))
LEFT OUTER JOIN study.colony_assignments col_assign ON col_assign.Id = animal.Id
    AND (onDate >= col_assign.date) AND (onDate < COALESCE(col_assign.endDate, now()))
LEFT OUTER JOIN study.breedingGroupAssignments bga ON bga.Id = animal.Id
    AND (onDate >= bga.date) AND (onDate < COALESCE(bga.endDate, now()))
LEFT OUTER JOIN cnprc_ehr.breedingRoster breed_roster ON breed_roster.animalId = animal.Id
LEFT OUTER JOIN study.pregnancyConfirmations preg_confirm ON preg_confirm.Id = animal.Id
    AND (onDate >= preg_confirm.conception) AND (onDate < COALESCE(preg_confirm.termDate, now()))
WHERE (onDate >= housing.date) AND (onDate < COALESCE(housing.endDate, now()))

UNION ALL

-- Part 2: vacant cage selection
-- Select all but filter column
SELECT Id, location, cage, cage_size, rate_class, species, gender, birth, deathOrOnDate, MostRecentWeight, date, payor_ids,
       colonyCode, groupCode, book, primaryProject, secondaryProjects, values, conNum, pgComment, daysPregnant, conceptionDateStatus,
       supervisor, room, pairingIndicator, area
FROM
(SELECT
NULL AS Id,
clh.location,
clh.cage as cage,
clh.cage_size,
clh.rate_class,
'VACANT' AS species,
NULL AS gender,
NULL AS birth,
NULL AS deathOrOnDate,
NULL AS MostRecentWeight,
clh.from_date AS date,
NULL AS payor_ids,
NULL AS colonyCode,
NULL AS groupCode,
NULL AS book,
NULL AS primaryProject,
NULL AS secondaryProjects,
NULL AS values,
NULL AS conNum,
NULL AS daysPregnant,
NULL AS conceptionDateStatus,
NULL AS pgComment,
NULL AS supervisor,
clh.room,
NULL AS pairingIndicator,
SUBSTRING(clh.location, 1, 2) AS area,
allLocations.filter
FROM cnprc_ehr.cage_location_history clh
LEFT OUTER JOIN (
    SELECT
        'X' AS filter,  -- use inverse JOIN logic to get cages which should be empty
        CASE WHEN housing.cage IS NULL THEN housing.room
             ELSE (housing.room || housing.cage)
        END AS location  -- TODO: this is wasteful, should split this column in cage_location_history
    FROM study.housing
    WHERE (onDate >= housing.date) AND (onDate < COALESCE(housing.endDate, now()))
) allLocations
ON allLocations.location = clh.location
WHERE (onDate >= clh.from_date) AND (onDate < COALESCE(clh.to_date, now()))
AND (clh.file_status <> 'IN')
) emptyCages
WHERE emptyCages.filter IS NULL