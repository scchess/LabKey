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
AB_AN_ID AS animalId,
AB_BOOK AS book,
AB_MALE_ENEMY_1 AS maleEnemy1,
AB_MALE_ENEMY_2 AS maleEnemy2,
AB_MALE_ENEMY_3 AS maleEnemy3,
AB_MALE_ENEMY_4 AS maleEnemy4,
AB_MALE_ENEMY_5 AS maleEnemy5,
OBJECTID AS objectId,
DATE_TIME
FROM cnprcSrc.ZAN_BREEDING;