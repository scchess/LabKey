/*
 * Copyright (c) 2010-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT  weight.Id,
        weight.date,
        weight.weight,
        weightRelChange.LatestWeight,
        weightRelChange.PctChange,
        weightRelChange.IntervalInMonths,
        weight.remark,
        weight.qcstate,
        weight.taskid
FROM study.weight
JOIN study.weightRelChange
  ON weightRelChange.Id = weight.Id