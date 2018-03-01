/*
 * Copyright (c) 2016 LabKey Corporation
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
AC_FEMALE_ID AS Id,
AC_CYCLE_DAY1_DATE,
AC_EST_GEST_DAY0_DATE AS estGestStartDate,
AC_MALE_ID AS sire,
AC_DAYS_AND_HOURS_STRING AS daysAndHoursString,
AC_LOCATION_OVERRIDE AS locationOverride,
AC_WEEKEND_BREEDING AS weekendBreeding,
AC_PGDET_METHOD_1 AS methodOne,
AC_PGDET_GEST_DAY_1 AS gestDayOne,
AC_PGDET_SCHED_STATUS_1 AS schedStatusOne,
AC_PGDET_METHOD_2 AS methodTwo,
AC_PGDET_GEST_DAY_2 AS gestDayTwo,
AC_PGDET_SCHED_STATUS_2 AS schedStatusTwo,
AC_PGDET_METHOD_3	AS methodThree,
AC_PGDET_GEST_DAY_3 AS	gestDayThree,
AC_PGDET_SCHED_STATUS_3 AS schedStatusThree,
OBJECTID as objectid,
DATE_TIME
FROM
cnprcSrc.ZAN_CYCLE;
