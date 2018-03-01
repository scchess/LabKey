/*
 * Copyright (c) 2015 LabKey Corporation. All rights reserved. No portion of this work may be reproduced in
 * any form or by any electronic or mechanical means without written permission from LabKey Corporation.
 */
package org.labkey.nlp.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.Container;

import java.util.Date;
import java.util.Map;

/**
 * User: tgaluhn
 * Date: 1/9/2015
 *
 * Jackson databinding bean for the controlInfo object in the json results
 * Database table bean for the nlp.JobRun table.
 */


@JsonIgnoreProperties(ignoreUnknown = false) //Do not flip this! If a json property name gets changed accidentally in the NLP Engine, we want to fail the job!
public class ControlInfo
{
    // JSON and database fields
    private String diseaseGroup;
    private String docType; // maps to DocumentType in db
    private String engineVersion;
    private String metadata;

    // JSON only fields. TBD if we want some of these in the db
    private String docDate;
    private String docName;
    private String docVersion;
    private String processDate;
    private String referenceId;
    private String source;

    // Database only fields
    @JsonIgnore
    private Container container;
    @JsonIgnore
    private Date startTime;
    @JsonIgnore
    private Date endTime;
    @JsonIgnore
    private String inputFile;
    @JsonIgnore
    private String inputFileName;
    @JsonIgnore
    private String result;
    @JsonIgnore
    private int expRunId;
    @JsonIgnore
    private int jobRunId;
    @JsonIgnore
    private String status;
    @JsonIgnore
    private String errors;

    public String getDiseaseGroup()
    {
        return diseaseGroup;
    }

    public void setDiseaseGroup(String diseaseGroup)
    {
        this.diseaseGroup = diseaseGroup;
    }

    public String getDocDate()
    {
        return docDate;
    }

    public void setDocDate(String docDate)
    {
        this.docDate = docDate;
    }

    public String getDocName()
    {
        return docName;
    }

    public void setDocName(String docName)
    {
        this.docName = docName;
    }

    public String getDocType()
    {
        return docType;
    }

    public void setDocType(String docType)
    {
        this.docType = docType;
    }

    public String getDocumentType()
    {
        return docType;
    }

    public void setDocumentType(String docType)
    {
        this.docType = docType;
    }

    public String getDocVersion()
    {
        return docVersion;
    }

    public void setDocVersion(String docVersion)
    {
        this.docVersion = docVersion;
    }

    public String getEngineVersion()
    {
        return engineVersion;
    }

    public void setEngineVersion(String engineVersion)
    {
        this.engineVersion = engineVersion;
    }

    public String getProcessDate()
    {
        return processDate;
    }

    public void setProcessDate(String processDate)
    {
        this.processDate = processDate;
    }

    public String getReferenceId()
    {
        return referenceId;
    }

    public void setReferenceId(String referenceId)
    {
        this.referenceId = referenceId;
    }

    public String getSource()
    {
        return source;
    }

    public void setSource(String source)
    {
        this.source = source;
    }

    public Container getContainer()
    {
        return container;
    }

    public void setContainer(Container container)
    {
        this.container = container;
    }

    public Date getStartTime()
    {
        return startTime;
    }

    public void setStartTime(Date startTime)
    {
        this.startTime = startTime;
    }

    public Date getEndTime()
    {
        return endTime;
    }

    public void setEndTime(Date endTime)
    {
        this.endTime = endTime;
    }

    public String getInputFile()
    {
        return inputFile;
    }

    public void setInputFile(String inputFile)
    {
        this.inputFile = inputFile;
    }

    public String getInputFileName()
    {
        return inputFileName;
    }

    public void setInputFileName(String inputFileName)
    {
        this.inputFileName = inputFileName;
    }

    public String getResult()
    {
        return result;
    }

    public void setResult(String result)
    {
        this.result = result;
    }

    public int getExpRunId()
    {
        return expRunId;
    }

    public void setExpRunId(int expRunId)
    {
        this.expRunId = expRunId;
    }

    public int getJobRunId()
    {
        return jobRunId;
    }

    public void setJobRunId(int jobRunId)
    {
        this.jobRunId = jobRunId;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getErrors()
    {
        return errors;
    }

    public void setErrors(String errors)
    {
        this.errors = errors;
    }

    public String getMetadata()
    {
        return metadata;
    }

    public void setMetadata(ObjectNode metadata)
    {
        if (null != metadata.get("tables"))
        {
            transformMetadata(metadata);
        }
        // TODO: Proper error handling behavior
    }

    private void transformMetadata(ObjectNode md)
    {
        JsonNodeFactory factory = new JsonNodeFactory(false);
        ObjectNode target = factory.objectNode();
        ArrayNode tables = target.putArray("tables");
        md.get("tables").forEach(mdTable ->
        {
            ObjectNode table = tables.addObject();
            table.put("name", mdTable.get("table").textValue());
            ArrayNode fields = table.putArray("fields");
            mdTable.get("fields").forEach(mdField ->
            {
                ObjectNode field = fields.addObject();
                field.put("name", mdField.get("field").textValue());

            /*
            Get the md diseaseProperties for the disease group
            Datatype = string
            closedClass = False & no disease prop values = jsonType string
            closeClass = false & disease prop values = closed false, options == values, and xtype : combo, no jsontype
            closedClass = True = closed true, options = values xtype : combo, no jsontype
            Datatype != string, map datatype, ignore closedClass & values for now
             */

                String mdDatatype = mapDatatype(mdField);
                if (!"string".equalsIgnoreCase(mdDatatype))
                {
                    field.put("jsonType", mdDatatype);
                }
                else
                {
                    Map<String, ArrayNode> diseaseGroups = new CaseInsensitiveHashMap<>();
                    mdField.get("diseaseProperties").forEach(mdDiseaseProp ->
                    {
                        ArrayNode values = (ArrayNode) mdDiseaseProp.get("values");
                        // diseaseGroup is an array of applicable disease groups, or could be single element exact match, or could be '*' wildcard.
                        mdDiseaseProp.get("diseaseGroup").forEach(mdDiseaseGroup ->
                        {
                            diseaseGroups.put(mdDiseaseGroup.asText(), values);
                        });
                    });

                    ArrayNode foundValues = diseaseGroups.get(diseaseGroup);
                    if (null == foundValues)
                    {
                        foundValues = diseaseGroups.get("*");
                    }
                    if (null == foundValues || foundValues.size() == 0)
                    {
                        field.put("jsonType", mdDatatype);
                    }
                    else
                    {
                        // can't use TextNode.booleanValue(), as it translates "True" as false
                        field.put("closed", Boolean.parseBoolean(mdField.get("closedClass").textValue()));
                        field.put("xtype", "combo");
                        field.putArray("options").addAll(foundValues);
                    }
                }
            });
        });

        this.metadata = target.toString();
    }

    private String mapDatatype(JsonNode mdField)   // TODO: Finish mappings
    {
        String datatype = mdField.get("datatype").textValue();
        switch (datatype)
        {
            case "integer":
                return "int";
            case "datetime":
                return "date";
            default:
                return datatype;
        }
    }
}
