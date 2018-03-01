/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* targetedms-17.10-17.11.sql */

ALTER TABLE targetedms.PrecursorChromInfo ADD COLUMN ChromatogramFormat INT;

/* targetedms-17.11-17.12.sql */

CREATE TABLE targetedms.QCMetricExclusion
(
    Id SERIAL NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    ReplicateId INT NOT NULL,
    MetricId INT, -- allow NULL to indicate exclusion of replicate for all metrics

    CONSTRAINT PK_QCMetricExclusion PRIMARY KEY (Id),
    CONSTRAINT FK_QCMetricExclusion_ReplicateId FOREIGN KEY (ReplicateId) REFERENCES targetedms.Replicate (Id),
    CONSTRAINT FK_QCMetricExclusion_MetricId FOREIGN KEY (MetricId) REFERENCES targetedms.QCMetricConfiguration (Id),
    CONSTRAINT UQ_QCMetricExclusion_Replicate_Metric UNIQUE (ReplicateId, MetricId)
);
CREATE INDEX IX_QCMetricExclusion_ReplicateId ON targetedms.QCMetricExclusion(ReplicateId);
CREATE INDEX IX_QCMetricExclusion_MetricId ON targetedms.QCMetricExclusion(MetricId);

/* targetedms-17.12-17.13.sql */

ALTER TABLE targetedms.ExperimentAnnotations ADD COLUMN sourceExperimentId INT;
ALTER TABLE targetedms.ExperimentAnnotations ADD COLUMN sourceExperimentPath VARCHAR(1000);
ALTER TABLE targetedms.ExperimentAnnotations ADD COLUMN shortUrl entityId;

CREATE INDEX IX_ExperimentAnnotations_SourceExperimentId ON targetedms.ExperimentAnnotations (sourceExperimentId);
ALTER TABLE targetedms.ExperimentAnnotations ADD CONSTRAINT UQ_ExperimentAnnotations_ShortUrl UNIQUE (shortUrl);
ALTER TABLE targetedms.ExperimentAnnotations ADD CONSTRAINT FK_ExperimentAnnotations_ShortUrl FOREIGN KEY (shorturl)
REFERENCES core.shorturl (entityId);

SELECT core.executeJavaUpgradeCode('updateExperimentAnnotations');