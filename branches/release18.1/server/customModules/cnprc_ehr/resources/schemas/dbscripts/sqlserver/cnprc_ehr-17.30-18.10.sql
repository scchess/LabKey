/* cnprc_ehr-17.30-17.31.sql */

ALTER TABLE cnprc_ehr.cage_location_history ADD room nvarchar(10);
ALTER TABLE cnprc_ehr.cage_location_history ADD cage nvarchar(5);