DROP INDEX aa_snps_ref_aa_position_codon ON sequenceanalysis.aa_snps;
DROP INDEX aa_snps_analysis_id ON sequenceanalysis.aa_snps;
DROP INDEX aa_snps_ref_nt_id ON sequenceanalysis.aa_snps;
DROP INDEX aa_snps_alignment_id ON sequenceanalysis.aa_snps;

DROP INDEX alignment_summary_analysis_id ON sequenceanalysis.alignment_summary;

DROP INDEX IDX_alignment_summary_junction_ref_nt_id_status_alignment_id ON sequenceanalysis.alignment_summary_junction;

DROP INDEX sequence_coverage_ref_nt_id ON sequenceanalysis.sequence_coverage;
