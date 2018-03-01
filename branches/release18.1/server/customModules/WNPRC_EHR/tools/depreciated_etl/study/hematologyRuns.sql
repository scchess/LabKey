/*
 * Copyright (c) 2010-2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT lower(id) as Id, FixDate(date) AS Date, lower(account) AS account, FixNewlines(remark) AS remark, FixNewlines(clinremark) AS clinremark,
uuid as runid,
ts,
uuid AS objectid
FROM hematology
WHERE ts > ?  AND length(id) > 1
