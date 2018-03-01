/*
        * Copyright (c) 2017 LabKey Corporation
        *
        * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
        */

        SELECT
        w.id,
        w.MostRecentBCSDate,
        (SELECT max(BodyConditionScore)


        FROM study.weight w2
        WHERE w.id=w2.id AND w.MostRecentBCSDate=w2.date
        ) AS BodyConditionScore

        FROM (
        SELECT
        w.Id AS Id,
        max(w.date) AS MostRecentBCSDate,
        FROM study.weight w
        WHERE w.qcstate.publicdata = true and w.BodyConditionScore is not null
        GROUP BY w.id
        ) w

