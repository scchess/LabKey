/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
pc.offspringId AS Id,
pc.conNum AS conceptionNumber,
pc.BRType AS breedingType,
pc.pgType AS pregnancyType,
pc.femaleGeneticsVerify,
pc.maleGeneticsVerify
FROM study.pregnancyConfirmations pc
WHERE pc.offspringId IS NOT NULL;