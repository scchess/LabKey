/*
 * Copyright (c) 2011-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
select
DisplayName as UserId
from core.users
where ISMEMBEROF((SELECT MIN(UserId) FROM core.Groups WHERE Name like '%pathology%'), UserId)
and DisplayName is not null and DisplayName !=''
;
