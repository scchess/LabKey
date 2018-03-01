SELECT
    allRows.Id,
    allRows.date,
    CONVERT(YEAR(allRows.date), INTEGER) AS year,
    MONTHNAME(allRows.date) AS monthName,
    CONVERT(MONTH(allRows.date), INTEGER) AS monthNum,
    CONVERT(DAYOFMONTH(allRows.date), INTEGER) AS day,
    '' as ind
FROM
(
    SELECT demo.Id,
        TIMESTAMPADD('SQL_TSI_MONTH', -(monthNumbers.monthNum), COALESCE(lastHousing.endDate, now())) AS date
    FROM study.demographics demo
    LEFT JOIN study.demographicsLastHousing lastHousing
           ON lastHousing.Id = demo.Id
    CROSS JOIN
      (SELECT integers.value AS monthNum
       FROM ldk.integers
       WHERE integers.value < 24) monthNumbers
) allRows