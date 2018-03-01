CREATE UNIQUE INDEX ix_name_lower_unique ON adjudication.assaytype (Container, LOWER(Name));
