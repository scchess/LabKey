ALTER TABLE sequenceanalysis.sequence_readsets ADD sampledate DATETIME;
ALTER TABLE sequenceanalysis.sequence_readsets DROP COLUMN raw_input_file;
ALTER TABLE sequenceanalysis.sequence_readsets DROP COLUMN raw_input_file2;