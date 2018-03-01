-- Adapted from mensCalendar

SELECT
    all_rows.Id,
    all_rows.date,
    all_rows.year,
    all_rows.monthName,
    all_rows.monthNum,
    all_rows.day,
    all_rows.ind
FROM
(
    -- Weight changes (adapted from weightPctChange)

    SELECT
      weight_changes.Id,
      weight_changes.date,
      weight_changes.year,
      weight_changes.monthName,
      weight_changes.monthNum,
      weight_changes.day,
      CASE WHEN weight_changes.PctChangePerDay >= 1.0
        THEN '+'
      WHEN weight_changes.PctChangePerDay <= -1.0
        THEN '-'
      ELSE '~'
      END AS ind
    FROM
      (
        SELECT
          w.Id,
          w.date,
          CONVERT(YEAR(w.date), INTEGER)       AS year,
          MONTHNAME(
              w.date)                          AS monthName,
          CONVERT(MONTH(w.date),
                  INTEGER)                     AS monthNum,
          CONVERT(DAYOFMONTH(w.date), INTEGER) AS day,
          CASE WHEN timestampdiff('SQL_TSI_DAY', w3.date, w.date) = 0 THEN NULL
               ELSE Round(((w.weight - w3.weight) * 100 / w3.weight) / timestampdiff('SQL_TSI_DAY', w3.date, w.date), 2) END AS PctChangePerDay

        FROM study.weight w
          --Find the next most recent weight date before this one
          JOIN
          (SELECT
             T2.Id,
             T2.date,
             max(T1.date) AS PrevDate
           FROM study.weight T1
             JOIN study.weight T2 ON (T1.Id = T2.Id AND T1.date < T2.date)
           GROUP BY T2.Id, T2.date) w2
            ON (w.Id = w2.Id AND w.date = w2.date)

          --and the weight associated with that date
          JOIN study.weight w3
            ON (w.Id = w3.Id AND w3.date = w2.prevdate)
      ) weight_changes

    UNION ALL

    -- Moves (non-departure)

    SELECT
      idsAndDates.Id,
      idsAndDates.date,
      CONVERT(YEAR(idsAndDates.date), INTEGER)       AS year,
      MONTHNAME(idsAndDates.date)                    AS monthName,
      CONVERT(MONTH(idsAndDates.date), INTEGER)      AS monthNum,
      CONVERT(DAYOFMONTH(idsAndDates.date), INTEGER) AS day,
      'M'                                           AS ind
    FROM
    (
      -- get all unique dates
      SELECT housing.Id, housing.date
      FROM study.housing
      UNION
      SELECT housing.Id, housing.enddate AS date
      FROM study.housing
    ) idsAndDates

    UNION  -- only get departures which are not in housing

    -- Moves (departure)

    SELECT
      departure.Id,
      departure.date,
      CONVERT(YEAR(departure.date), INTEGER)        AS year,
      MONTHNAME(departure.date)                     AS monthName,
      CONVERT(MONTH(departure.date), INTEGER)       AS monthNum,
      CONVERT(DAYOFMONTH(departure.date), INTEGER)  AS day,
      'M'                                           AS ind
    FROM study.departure
    -- only get shipped, not other departures
    WHERE relocType = 'Shipped'

    UNION ALL

    -- Diarrhea from morningHealthObs

    SELECT DISTINCT
      -- can be multiple obs per day
      mho.Id,
      mho.date,
      CONVERT(YEAR(mho.date), INTEGER)       AS year,
      MONTHNAME(mho.date)                    AS monthName,
      CONVERT(MONTH(mho.date), INTEGER)      AS monthNum,
      CONVERT(DAYOFMONTH(mho.date), INTEGER) AS day,
      'D'                                    AS ind
    FROM study.morningHealthObs mho
    WHERE mho.observation LIKE '%LIQDSTL%'

    UNION ALL

    -- Diarrhea from clinical_observations

    SELECT
      clinObs.Id,
      clinObs.date,
      CONVERT(YEAR(clinObs.date), INTEGER)       AS year,
      MONTHNAME(clinObs.date)                    AS monthName,
      CONVERT(MONTH(clinObs.date), INTEGER)      AS monthNum,
      CONVERT(DAYOFMONTH(clinObs.date), INTEGER) AS day,
      'Dc'                                       AS ind
    FROM study.clinical_observations clinObs
    WHERE clinObs.category = 'Stool'
          AND clinObs.observation = 'L'

    -- UNION ALL

    -- Diarrhea from morning health confirmations

    -- TODO
) all_rows