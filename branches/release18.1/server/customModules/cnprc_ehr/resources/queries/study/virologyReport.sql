/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the License);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an AS IS BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
SELECT
  sub.vi_pk,
  sub.id,
  sub.sampleDate,
  sub.testDoneDate,
  sub.target,
  sub.virus,
  sub.method,
  sub.sampleType,
  sub.purpose,
  sub.results,
  sub.opticalDensity,
  sub.titration,
  sub.lab,
  sub.comment
 FROM
(
    SELECT
    v.seqPk AS vi_pk,
    v.id,
    v.date AS sampleDate,
    v.testDate AS testDoneDate,
    v.target AS target,
    v.virus AS virus,
    v.method AS method,
    v.sampleType AS sampleType,
    v.purpose AS purpose,
    v.result AS results,
    v.opticalDensity AS opticalDensity,
    v.titration AS titration,
    v.lab AS lab,
    v.remark AS comment
  FROM study.virology v
  WHERE
    V.LAB NOT IN ('SRRL', 'CRPRC')

  UNION

  SELECT * FROM
  (SELECT

    t.test_pk AS vi_pk,
    s.animalId AS id,
    s.sampleDate AS sampleDate,
    t.testDoneDate,
    t.type AS target,
    t.type AS virus,
    t.type AS method,
    s.sampleType AS sampleType,
    NULL AS purpose,
    t.results,
    NULL AS opticalDensity,
    NULL AS titration,
    'SRRL' AS lab,
    NULL AS comment
  FROM cnprc_pdl_linked.samples s
    JOIN cnprc_pdl_linked.tests t ON t.sample_fk = s.sample_pk
    JOIN cnprc_pdl_linked.orders o ON o.order_pk = s.order_fk
  WHERE
    t.type NOT LIKE 'ABSCN%'
    AND t.results IS NOT NULL
    AND t.isHideOnReport = 0
    AND o.orderDate IS NOT NULL
    AND o.reportDate IS NOT NULL

  UNION

  SELECT
    st.subtest_pk AS vi_pk,
    s.animalId AS id,
    s.sampleDate AS sampleDate,
    st.testDoneDate,
    t.type || '-' || st.type  AS target,
    t.type || '-' || st.type  AS virus,
    t.type || '-' || st.type  AS method,
    s.sampleType AS sampleType,
    NULL AS purpose,
    st.results,
    NULL AS opticalDensity,
    NULL AS titration,
    'SRRL' AS lab,
    NULL AS comment
  FROM cnprc_pdl_linked.samples s
    JOIN cnprc_pdl_linked.tests t ON t.sample_fk = s.sample_pk
    JOIN cnprc_pdl_linked.sub_tests st ON st.test_fk = t.test_pk
    JOIN cnprc_pdl_linked.orders o ON o.order_pk = s.order_fk
  WHERE
    st.type NOT LIKE 'ABSCN%'
    AND st.results IS NOT NULL
    AND st.isHideOnReport = 0
    AND o.orderDate IS NOT NULL
    AND o.reportDate IS NOT NULL ) pdlSub
    WHERE
    pdlSub.results IN
      (
        'NEGATIVE',
        'NEG',
        'POSITIVE',
        'POS',
        'IND',
        'INDETERMINATE'
      ) AND
      pdlSub.target IN
      (
        'SIV PCR',
        'SRV PCR',
        'STLV PCR',
        'RRV PCR',
        'SFV PCR',
        'SIV WB',
        'SRV WB',
        'SRV1 WB',
        'SRV2 WB',
        'SRV4 WB',
        'SRV5 WB',
        'STLV WB',
        'SFV WB',
        'RRV IFA',
        'SFV IFA',
        'MEASLES IFA',
        'HERPES B MIA',
        'RFHV PCR',
        'RH CMV MIA',
        'RH CMV WB',
        'RHCMV PCR',
        'WNV AB',
        'AAV AB',
        'ZKV AB',
        'HPV2 IFA',
        'HPV2 EIA',
        'HPV2 IFA',
        'HPV2 MIA',
        'SFV EIA',
        'SFV MIA',
        'SIV EIA',
        'SIV MIA',
        'SRV EIA',
        'SRV MIA',
        'SRV1 EIA',
        'SRV2 EIA',
        'SRV5 EIA',
        'STLV EIA',
        'STLV MIA',
        'ABSCN-5-SIV MIA',
        'ABSCN-5-SRV MIA',
        'ABSCN-5-STLV MIA',
        'ABSCN-5-HERPES B MIA',
        'ABSCN-5-MEASLES MIA',
        'ABSCN-8-SIV MIA',
        'ABSCN-8-SRV MIA',
        'ABSCN-8-SFV MIA',
        'ABSCN-8-STLV MIA',
        'ABSCN-8-HERPES B MIA',
        'ABSCN-8-MEASLES MIA',
        'ABSCN-8-RH CMV MIA',
        'ABSCN-8-RRV MIA',
        'ABSCN-SIV MIA',
        'ABSCN-SRV MIA',
        'ABSCN-SFV MIA',
        'ABSCN-STLV MIA',
        'ABSCN-HVP2 MIA',
        'ABSCN-MEASLES MIA',
        'ABSCN-RH CMV MIA') AND
      pdlSub.virus IN
      (
        'SIV PCR',
        'SRV PCR',
        'STLV PCR',
        'RRV PCR',
        'SFV PCR',
        'SIV WB',
        'SRV WB',
        'SRV1 WB',
        'SRV2 WB',
        'SRV4 WB',
        'SRV5 WB',
        'STLV WB',
        'SFV WB',
        'RRV IFA',
        'SFV IFA',
        'MEASLES IFA',
        'HERPES B MIA',
        'RFHV PCR',
        'RH CMV MIA',
        'RH CMV WB',
        'RHCMV PCR',
        'WNV AB',
        'AAV AB',
        'ZKV AB',
        'HPV2 IFA',
        'HPV2 EIA',
        'HPV2 IFA',
        'HPV2 MIA',
        'SFV EIA',
        'SFV MIA',
        'SIV EIA',
        'SIV MIA',
        'SRV EIA',
        'SRV MIA',
        'SRV1 EIA',
        'SRV2 EIA',
        'SRV5 EIA',
        'STLV EIA',
        'STLV MIA',
        'ABSCN-5-SIV MIA',
        'ABSCN-5-SRV MIA',
        'ABSCN-5-STLV MIA',
        'ABSCN-5-HERPES B MIA',
        'ABSCN-5-MEASLES MIA',
        'ABSCN-8-SIV MIA',
        'ABSCN-8-SRV MIA',
        'ABSCN-8-SFV MIA',
        'ABSCN-8-STLV MIA',
        'ABSCN-8-HERPES B MIA',
        'ABSCN-8-MEASLES MIA',
        'ABSCN-8-RH CMV MIA',
        'ABSCN-8-RRV MIA',
        'ABSCN-SIV MIA',
        'ABSCN-SRV MIA',
        'ABSCN-SFV MIA',
        'ABSCN-STLV MIA',
        'ABSCN-HVP2 MIA',
        'ABSCN-MEASLES MIA',
        'ABSCN-RH CMV MIA') AND
      pdlSub.method IN
      (
        'SIV PCR',
        'SRV PCR',
        'STLV PCR',
        'RRV PCR',
        'SFV PCR',
        'SIV WB',
        'SRV WB',
        'SRV1 WB',
        'SRV2 WB',
        'SRV4 WB',
        'SRV5 WB',
        'STLV WB',
        'SFV WB',
        'RRV IFA',
        'SFV IFA',
        'MEASLES IFA',
        'HERPES B MIA',
        'RFHV PCR',
        'RH CMV MIA',
        'RH CMV WB',
        'RHCMV PCR',
        'WNV AB',
        'AAV AB',
        'ZKV AB',
        'HPV2 IFA',
        'HPV2 EIA',
        'HPV2 IFA',
        'HPV2 MIA',
        'SFV EIA',
        'SFV MIA',
        'SIV EIA',
        'SIV MIA',
        'SRV EIA',
        'SRV MIA',
        'SRV1 EIA',
        'SRV2 EIA',
        'SRV5 EIA',
        'STLV EIA',
        'STLV MIA',
        'ABSCN-5-SIV MIA',
				'ABSCN-5-SRV MIA',
				'ABSCN-5-STLV MIA',
				'ABSCN-5-HERPES B MIA',
				'ABSCN-5-MEASLES MIA',
				'ABSCN-8-SIV MIA',
				'ABSCN-8-SRV MIA',
				'ABSCN-8-SFV MIA',
				'ABSCN-8-STLV MIA',
				'ABSCN-8-HERPES B MIA',
				'ABSCN-8-MEASLES MIA',
				'ABSCN-8-RH CMV MIA',
				'ABSCN-8-RRV MIA',
				'ABSCN-SIV MIA',
				'ABSCN-SRV MIA',
				'ABSCN-SFV MIA',
				'ABSCN-STLV MIA',
				'ABSCN-HVP2 MIA',
				'ABSCN-MEASLES MIA',
				'ABSCN-RH CMV MIA')
  ) sub
  JOIN study.demographics d ON d.id = sub.id
  WHERE
      sub.target IS NOT NULL AND
      sub.virus IS NOT NULL AND
      sub.method IS NOT NULL AND
      sub.results IS NOT NULL