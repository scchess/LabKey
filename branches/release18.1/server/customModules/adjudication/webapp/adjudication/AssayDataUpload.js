/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
(function($) {

    var dataFileName = null;
    var dataContent = null;
    var fileNamePtid = null;
    var dataPtid = null;
    var dataVisits = [];
    var dataAssay = [];
    var nextAdjId = null;
    var updateRows = null;
    var existingCaseId = null;
    var mergeCase = false;
    var uploadData = null;
    var caseCompleted = false;
    var caseUploadInProgress = false;

    // array of steps to be listed as a "menu" for this data upload process
    var steps = {step1: "Step 1: Upload Adjudication Data File",
        step2: "Step 2: Adjudication Case Creation",
        step3: "Step 3: Upload Additional Information",
        step4: "Step 4: Summary of Case Details"};

    var curStep = 1;
    var numSteps = 0;
    var adjUtil = null;

    Ext4.onReady(function() {
        beginUploadProcess();
    });

    function beginUploadProcess()
    {
        adjUtil = Ext4.create('LABKEY.adj.AdjudicationUtil');

        $('#nextButton').click(function() {goToNext();});
        $('#finishButton').click(function() {goToFinish();});

        // loop through the steps and print out the step instruction
        Ext4.iterate(steps, function(step, label) {

            Ext4.get(step).update(label);

            // count of the number of steps in this wizard
            numSteps++;
        });

        // Get SupportedKits
        LABKEY.Query.selectRows({
            schemaName: 'adjudication',
            queryName: 'SupportedKits',
            successCallback: uploadAdjudicationDataStep,
            errorCallback: failureHandler,
            scope: this
        });
    }

    // function that is called when the "Next" button is clicked (to move forward a step in the wizard)
    function goToNext()
    {
        // Issue 31820: initially disable the buttons on click
        document.getElementById('nextButton').disabled = true;
        document.getElementById('finishButton').disabled = true;

        if(curStep == 1)
        {
            if(dataFileName == null)
            {
                showErrorAlert("Error", "No data file uploaded.", reloadPage);
                return;
            }
            else
            {
                //switch the contents of the working area
                document.getElementById('step1Div').style.display = "none";
                Ext4.get('status').update("");

                nextStep();
                checkFileReplacementStep();
            }
        }
        else if(curStep == 2)
        {
            uploadAdjudicationCase(function()
            {
                document.getElementById('step2Div').style.display = "none";
                Ext4.get('status').update("");

                nextStep();
                uploadAdditionalInfoStep();
            });
        }
        else if(curStep == 3)
        {
            //switch the contents of the working area
            document.getElementById('step3Div').style.display = "none";
            Ext4.get('status').update("");

            nextStep();
            displayCaseDetails();
        }
        else if(curStep == 4)
        {
            nextStep();
        }

        // if we have reached the final step, toggle the buttons
        if(curStep == numSteps) {
            // hide and disable the Next button in favor of the Finish button
            document.getElementById('nextButton').disabled = true;
            document.getElementById('nextButton').style.display = 'none';
            document.getElementById('finishButton').disabled = false;
            document.getElementById('finishButton').style.display = 'inline';
        }
    }

    // function to change the UI to display moving to the next step in the wizard
    function nextStep()
    {
        curStep++;

        //switch the classes to move ahead a step (highlight the new current step and un-highlight the last step
        Ext4.get('step' + (curStep-1)).replaceCls('current', 'normal');
        Ext4.get('step' + curStep).replaceCls('normal', 'current');

        // // Issue 31820: re-enable the next/finish button after step is complete
        document.getElementById('nextButton').disabled = curStep == numSteps;
        document.getElementById('finishButton').disabled = curStep != numSteps;
    }

    // function to display the simple form for uploading the assay data TXT file for a new or replacement case
    function uploadAdjudicationDataStep(kitData)
    {
        var uploadFileForm = Ext4.create('Ext.form.Panel', {
            items: [
                {xtype: 'hidden', name: 'X-LABKEY-CSRF', value: LABKEY.CSRF},
                Ext4.create('Ext.form.field.File', {
                    renderTo: 'uploadFileButton',
                    name: 'file',
                    width: 325,
                    listeners: {
                        change: {
                            scope: this,
                            fn: function(cmp, value)
                            {
                                // stash away the file object
                                if (cmp.fileInputEl.dom.files.length)
                                    this.uploadedFile = cmp.fileInputEl.dom.files[0];

                                var formData = new FormData();
                                formData.append('file', this.uploadedFile);

                                LABKEY.Ajax.request({
                                    method  : 'POST',
                                    url     : LABKEY.ActionURL.buildURL('experiment', 'parseFile.api'),
                                    form    : formData,
                                    success: function(response) {
                                        handleDataUpload(Ext4.JSON.decode(response.responseText), kitData);
                                    },
                                    failure: LABKEY.Utils.getCallbackWrapper(function (json, response, options) {
                                        showErrorAlert("Upload Failed", "Adjudication case file upload failed: " + (json ? json.exception : ""), reloadPage);
                                    })
                                });
                            }
                        }
                    }
                })
            ]
        });
    }

    // function called when the TXT file has been selected and loaded into the system
    function handleDataUpload(response, kitData)
    {
        if (!Ext4.isObject(response) || !Ext4.isArray(response.sheets) || response.sheets.length == 0)
        {
            showErrorAlert("Upload Failed", "Failed to upload the data file. Please contact site administrator.", reloadPage);
            return;
        }

        // file name should match file naming convention: ex. <user-specified>_123456679_01JAN2009.txt
        dataFileName = response.originalFileName;
        var escapedPrefix = uploadConfig.adjFilenamePrefix.replace(/([.*+?^${}()|\[\]\/\\])/g, '\\$&');
        var re = new RegExp('^(' + escapedPrefix + ')_(\\d{9})_(\\d\\d[a-zA-Z]{3}\\d{4})\\.[tT][xX][tT]$');

        var tmp = dataFileName.match(re);
        if (tmp == null)
        {
            showErrorAlert(
                "Upload Failed",
                "Unexpected file name: " + dataFileName + ".<br/>File name must be of the following format: "
                    + uploadConfig.adjFilenamePrefix + "_PTID_DDMMMYYYY.txt",
                reloadPage
            );
            return;
        }
        else if (Ext4.isArray(tmp) && tmp.length > 2)
        {
            fileNamePtid = tmp[2];
        }

        // check the data content - first row should be column headers in the specified order
        dataContent = response.sheets[0];
        var headers = dataContent.data[0];

        var errors = "";
        var unknownColumns = "";
        var unknownColumnsSep = "";
        var unknownColumnsCount = 0;
        dataVisits = [];

        // All columns should be in required or allowable
        for (var headerInx = 0; headerInx < headers.length; headerInx++)
        {
            if (-1 == $.inArray(headers[headerInx].toUpperCase(), uploadConfig.requiredFields) &&
                -1 == $.inArray(headers[headerInx].toUpperCase(), uploadConfig.allowedFields))
            {
                unknownColumns += unknownColumnsSep + headers[headerInx];
                unknownColumnsSep = ", ";
                unknownColumnsCount += 1;
            }
            else {
                headers[headerInx] = headers[headerInx].toUpperCase();      // For later checking
            }
        }

        // loop through the rows of the data content
        for (var i = 1; i < dataContent.data.length; i++)
        {
            // check the data content for required fields and data formats (ex. ptid is 9 digits) by calling a validation function
            errors += validateRow(dataContent.data[i], headers, i, kitData.rows);
        }

        // if the validation of the data content has resulted in errors, display them and return
        if (!Ext4.isEmpty(errors))
        {
            showErrorAlert("Upload Failed", errors, reloadPage);
            return;
        }

        if (unknownColumnsCount > 0)
        {
            var message = 'The file contains ' + (unknownColumnsCount > 1 ? 'unknown fields: ' : 'an unknown field: ') +
                    unknownColumns + '. Do you wish to continue uploading this file?';
            Ext4.Msg.confirm(
                'Warning',
                message,
                function(btnId) {
                    if (btnId != 'yes') {
                        reloadPage();
                    }
                });
        }

        // at this point, the data file is loaded and all is well
        Ext4.get('status').update("Data file loaded successfully..." + (dataContent.data.length - 1) + " row(s) of data");
        document.getElementById('step1Div').style.display = "none";
    }

    function updateDate(date)
    {
        var dt = new Date(date);
        var mo = dt.getMonth() + 1;
        if (dt.toString().toLowerCase() == "invalid date" || mo.toString() == "NaN")
            return null;    // invalid date
        return dt.getFullYear() + '/' + mo + '/' + dt.getDate() + ' 00:00:00';
    }

    // function to validate a row of data from the assay TXT file for required fields, reqex checks, etc.
    function validateRow(row, headers, rowNum, kitRows)
    {
        // values coming in as "NETWORK", need to remove the double quotes
        for (var rowMem in row)
            if (row.hasOwnProperty(rowMem) && typeof row[rowMem] == 'string')
                row[rowMem] = row[rowMem].replace(/\"/g, "");

        var errors = "";

        for (var reqMem = 0; reqMem < uploadConfig.requiredFields.length; reqMem++) {
            if (row[headers.indexOf(uploadConfig.requiredFields[reqMem].toUpperCase())] == null)
                errors += "Row " + rowNum + ": " + uploadConfig.requiredFields[reqMem] + " is required.<br>";
        }

        // Check KitCode
        var kitFound = false;
        if (row[headers.indexOf("ASSAYKIT")]) {
            for (var k = 0; k < kitRows.length; k++) {
                var kitRow = kitRows[k];
                if (kitRow.KitCode && row[headers.indexOf("ASSAYKIT")] === kitRow.KitCode) {
                    kitFound = true;
                    break;
                }
            }

            // if we couldn't find an exact match try a more lenient match by converting assay kit values to numbers
            if (!kitFound){
                var rowCode = parseInt(row[headers.indexOf("ASSAYKIT")]);
                if (!isNaN(rowCode)){
                    Ext4.each(kitRows, function(kitRow){
                        if (kitRow.KitCode){
                            var kitCode = parseInt(kitRow.KitCode);
                            if (!isNaN(kitCode) && kitCode === rowCode)
                            {
                                // replace the row value with the kit code in the database
                                row[headers.indexOf("ASSAYKIT")] = kitRow.KitCode;
                                kitFound = true;
                                return false;
                            }
                        }
                        return true;
                    });
                }
            }

            if (!kitFound)
                errors += "Row " + rowNum + ": Assay Kit '" + row[headers.indexOf("ASSAYKIT")] + "' not supported. Contact your administrator."
        }

        // check that only one ptid exists in data file
        if (dataPtid == null)
            dataPtid = row[headers.indexOf("PTID")];
        else if (dataPtid != row[headers.indexOf("PTID")])
            errors += "Row " + rowNum + ": Multiple PTIDs found in uploaded data file.<br>";

        // issue 24775: check that ptid in data content matches the ptid in the file name
        if (row[headers.indexOf("PTID")] != fileNamePtid)
            errors += "Row " + rowNum + ": PTID does not match file name.<br>";

        if (row[headers.indexOf("PROTOCOL")] != null)
            row[headers.indexOf("PROTOCOL")] = Number(row[headers.indexOf("PROTOCOL")]);
        if (row[headers.indexOf("PTID")] != null)
            row[headers.indexOf("PTID")] = Number(row[headers.indexOf("PTID")]);
        if (row[headers.indexOf("VISIT")] != null)
            row[headers.indexOf("VISIT")] = Number(row[headers.indexOf("VISIT")]);

        if (row[headers.indexOf("DRAWDT")] != null) {
            var drawDate = updateDate(row[headers.indexOf("DRAWDT")]);
            if (drawDate == null)
                errors += "Row " + rowNum + ": DRAWDT format error: " + row[headers.indexOf("DRAWDT")] + ". Use yyyy/mm/dd.<br>";
            else
                row[headers.indexOf("DRAWDT")] = drawDate;
        }
        if (row[headers.indexOf("TESTDT")] != null) {
            var testDate = updateDate(row[headers.indexOf("TESTDT")]);
            if (testDate == null)
                errors += "Row " + rowNum + ": TESTDT format error: " + row[headers.indexOf("TESTDT")] + ". Use yyyy/mm/dd.<br>";
            else
                row[headers.indexOf("TESTDT")] = testDate;
        }


        // check some values for data type and format problems (ptid, visit, date, etc.)
        // check ptid for 9 digit number
        var re = /^\d{9}$/;
        var regcheck = row[headers.indexOf("PTID")].toString().match(re);
        if (regcheck != row[headers.indexOf("PTID")].toString())
            errors += "Row " + rowNum + ": PTID format error (" + row[headers.indexOf("PTID")] + "). Expecting 9 digit number.<br>";
        // check visit number for #.#
        re = /^\d+\.?\d*$/;
        regcheck = row[headers.indexOf("VISIT")].toString().match(re);
        if (regcheck != row[headers.indexOf("VISIT")].toString())
            errors += "Row " + rowNum + ": VISIT format error (" + row[headers.indexOf("VISIT")] + "). Expecting #.#.<br>";

        // keep track of the visits in the data file...to be used later
        if (dataVisits.indexOf(row[headers.indexOf("VISIT")]) == -1)
            dataVisits[dataVisits.length] = row[headers.indexOf("VISIT")];

        // store the data in a structure that will be ready for inserting into the dataset
        var index = dataAssay.length;
        dataAssay[index] = {};
        for (var i = 0; i < headers.length; i++)
            dataAssay[index][headers[i]] = row[headers.indexOf(headers[i].toUpperCase())];

        return errors;
    }

    // function that is called at start of step 2 in the wizard
    function checkFileReplacementStep()
    {
        //query the database to see if this file has been previously uploaded
        LABKEY.Query.selectRows({
            schemaName: 'adjudication',
            queryName: 'CasesMatchingFile',
            parameters: {
                filename: dataFileName
            },
            successCallback: queryCaseFileNames,
            errorCallback: failureHandler,
            scope: this
        });
    }

    function displayCreateCase()
    {
        document.getElementById('nextButton').disabled = false;

        if (typeof mergeCase === 'undefined')
            mergeCase = false;

        if (existingCaseId)
        {
            if (mergeCase)
            {
                if (caseCompleted)
                    Ext4.get('status').update("New data file uploaded. Merging with a completed adjudication case...");
                else
                    Ext4.get('status').update("New data file uploaded. Merging with an adjudication case...");
            }
            else
                Ext4.get('status').update("New data file uploaded. Overwriting adjudication case...");
        }
        else
        {
            Ext4.get('status').update("New data file uploaded. Creating adjudication case...");
        }

        var html = "<table border='0'>";
        html += "<tr><td>Participant ID:</td><td id='ptidcell'>" + dataPtid + "</td></tr>";
        html += "<tr><td>Visits:</td><td id='visitscell'>" + dataVisits.join(', ') + "</td></tr>";
        html += "<tr><td valign='top'>Case Comment:</td><td><textarea id='caseComment' cols='40' rows='4'></textarea></td></tr>";
        html += "</table>";
        Ext4.get('step2Div').update(html);

        document.getElementById('step2Div').style.display = "block";
    }

    // callback function for selectRows api call: determine if this is a new or replacement file
    function queryCaseFileNames(data)
    {
        //if data length is 0, then this is a new data file so a new case is to be created
        //if data length is not zero then this is a replacement file and data needs to be updated
        if (data.rows.length == 0)
        {
            displayCreateCase();
        }
        else if (data.rows.length > 1)
        {
            showErrorAlert("Error", "More than one adjudication case exists with file name " + dataFileName + ". Contact site administrator.", reloadPage);
        }
        else // this must be a replacement file
        {
            existingCaseId = data.rows[0].CaseId;

            // disable the next button until Continue is clicked
            document.getElementById('nextButton').disabled = true;

            // don't allow replacement file for Completed cases
            if (data.rows[0].Completed)
            {
                caseCompleted = true;
                Ext4.get('status').update("A <b>completed</b> adjudication case already exists with this file.<br/><br/>"
                        + "<b>Merge</b> will add the assay results from the uploaded TXT file to the completed case. "
                        + "It will not remove any previously uploaded assay results, case details, or determinations.<br/><br/>"
                        + "<b>Exit wizard</b> to exit the upload wizard. Please contact the Adjudication Coordinator or a site "
                        + "administrator if the case is not supposed to have already been completed.");

                // write the html for exiting the wizard
                var html = "<a class='labkey-button' id='mergeButton'><span>Merge</span></a>&nbsp;";
                html += "<a class='labkey-button' id='exitButton'><span>Exit Wizard</span></a>";
                Ext4.get('step2Div').update(html);
                document.getElementById('step2Div').style.display = "block";

                $('#mergeButton').click(function() {
                    mergeCase = true;
                    displayCreateCase();
                });
                $('#exitButton').click(function() {
                    refreshPage();
                });
            }
            // case is still active to proceed with wizard
            else
            {
                Ext4.get('status').update("An adjudication case already exists with this file name.<br/><br/><b>Merge</b>"
                        + " will add assay results from the uploaded TXT file to the existing case for those results"
                        + " which are not exact matches with existing data rows. It will not edit or remove any previously"
                        + " uploaded assay results, case details, or determinations.<br/>"
                        + " <b>Replace</b> will delete the current case including the previously uploaded assay results,"
                        + " the case details, and any determinations."
                        + " A new case will then be created with the new TXT file data.<br/>"
                        + "<b>Cancel</b> to cancel the upload and exit the upload wizard.");

                // write the html for the step2Div for replacing data for existing case
                var html1 = "<a class='labkey-button' id='mergeButton'><span>Merge</span></a>&nbsp;";
                html1 += "<a class='labkey-button' id='replaceButton'><span>Replace</span></a>&nbsp;";
                html1 += "<a class='labkey-button' id='cancelButton'><span>Cancel</span></a>";
                Ext4.get('step2Div').update(html1);
                document.getElementById('step2Div').style.display = "block";

                $('#mergeButton').click(function() {
                    mergeCase = true;
                    displayCreateCase();
                });
                $('#replaceButton').click(function() {
                    mergeCase = false;
                    displayCreateCase();
                });
                $('#cancelButton').click(function() {
                    refreshPage();
                });
            }
        }
    }

    // function called to refresh the page (called when exiting or canceling out of the wizard
    function refreshPage()
    {
        window.location = LABKEY.ActionURL.buildURL('project', 'begin.view', null, {pageId: 'Upload'});
    }

    // function to begin the process of creating a new adjudication case - insert into the Adjudications table
    function uploadAdjudicationCase(successCallback)
    {
        // Issue 31820: don't allow duplicate case create/update
        if (caseUploadInProgress) {
            return;
        }

        var url;
        if (existingCaseId && mergeCase)
            url = LABKEY.ActionURL.buildURL('adjudication', 'updateAdjudicationCase');
        else
            url = LABKEY.ActionURL.buildURL('adjudication', 'createAdjudicationCase');

        if (typeof existingCaseId === "undefined")
            existingCaseId = null;

        // insert new adjudication id into Adjudications table
        caseUploadInProgress = true;
        Ext4.Ajax.request({
            url: url,
            method: 'POST',
            scope : this,
            jsonData: {
                CaseId: existingCaseId,
                ParticipantId: dataPtid,
                AssayFilename: dataFileName,
                Comment: Ext4.get('caseComment').getValue(),
                Visits: dataVisits,
                AssayData: dataAssay,
                CaseCompleted : caseCompleted
            },
            success: function(response)
            {
                var data = Ext4.JSON.decode(response.responseText);
                nextAdjId = data.caseId;
                updateRows = data.rows;

                var formData = new FormData();
                formData.append('file', this.uploadedFile);
                formData.append('caseId', data.caseId);

                // save the uploaded file to the server
                LABKEY.Ajax.request({
                    method  : 'POST',
                    url     : LABKEY.ActionURL.buildURL('adjudication', 'saveAdjudicationCaseFile.api'),
                    form    : formData,
                    success: function() {
                        caseUploadInProgress = false;
                        successCallback.call();
                    },
                    failure: LABKEY.Utils.getCallbackWrapper(function (json, response, options) {
                        showErrorAlert("Upload Failed", "Adjudication case file upload failed: " + (json ? json.exception : ""), reloadPage);
                    })
                });
            },
            failure: LABKEY.Utils.getCallbackWrapper(function (json, response, options)
            {
                showErrorAlert("Upload Failed", "Adjudication case creation failed: " + (json ? json.exception : ""), reloadPage);
            })
        });
    }

    // function to start step 3 of the wizard (uploading additional information files)
    function uploadAdditionalInfoStep()
    {
        Ext4.get('status').update("Upload optional file(s)...");
        Ext4.get('step3Div').update("<em>Loading...</em>");
        document.getElementById('step3Div').style.display = "block";

        var filter;
        if (updateRows) {
            filter = [LABKEY.Filter.create('RowId', updateRows.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)];
            updateRows = null;
        }
        else
            filter = [LABKEY.Filter.create('CaseId', nextAdjId)];

        // query the database to find out what visits and assay types exist for this case
        LABKEY.Query.selectRows({
            schemaName: 'adjudication',
            queryName: 'Adjudication Assay Results',
            containerPath: LABKEY.ActionURL.getContainer(),
            filterArray: filter,
            //filterArray: [LABKEY.Filter.create('CaseId', nextAdjId)],
            columns: 'RowId,EntityId,ParticipantId,Visit,DrawDate,Attachments,CaseId,AssayType',
            sort: 'Created',
            successCallback: queryUploadsForCase,
            errorCallback: failureHandler,
            scope: this
        });
    }


    // callback function of selectRows api call: retrieve data for uploads and build html table for uploading them
    function queryUploadsForCase(data)
    {
        // store upload data
        uploadData = data;

        var styleHeader = "style='border:1px solid #C0C0C0;font-weight:bold;text-align:center'";
        var styleNormal = "style='border:1px solid #C0C0C0;text-align:center'";

        // build html table to display visits and assay types with insert attachment link
        var html = "<table cellpadding='5' cellspacing='0' border='0' style='border-collapse: collapse;'>";
        html += "<tr><td " + styleHeader + ">PTID</td>"
                + "<td " + styleHeader + ">Visit</td>"
                + "<td " + styleHeader + ">Draw Dt</td>"
                + "<td " + styleHeader + ">Assay Type</td>"
                + "<td " + styleHeader + ">Upload File</td>"
                + "<td " + styleHeader + ">&nbsp;</td></tr>";
        for (var i = 0; i < data.rows.length; i++) {
            html += "<tr><td " + styleNormal + ">" + data.rows[i].ParticipantId + "</td>"
                    + "<td " + styleNormal + ">" + data.rows[i].Visit + "</td>"
                    + "<td " + styleNormal + ">" + adjUtil.formatDate(data.rows[i].DrawDate) + "</td>"
                    + "<td " + styleNormal + ">" + data.rows[i].AssayType + "</td>"
                    + "<td " + styleNormal + ">" + (data.rows[i].Attachments ? data.rows[i].Attachments : "") + "</td>"
                    + "<td " + styleNormal + ">" + "[<a href='#' id='fillButton" + i + "'>"
                    + ((data.rows[i].Attachments == null ? 'insert' : 'replace') + '</a>]')
                    + "</td></tr>";

        }
        html += "</table>";

        Ext4.get('step3Div').update(html);

        for (var j = 0; j < data.rows.length; j++) {
            $('#fillButton' + j).click(function (obj) {
                fillUploadForm(obj);
                return false; // issue 25638
            });
        }
    }

    // function called when "insert" or "replace" links are clicked
    function fillUploadForm(targetObj)
    {
        var index = targetObj.target.id.replace('fillButton', ''),
            rowData = uploadData.rows[index],
            items = [];

        items.push({ xtype: 'hidden', name: 'entityId', value: rowData.EntityId });
        items.push({ xtype: 'hidden', name: 'RowId', value: rowData.RowId });
        items.push({ xtype: 'hidden', name: 'CaseId', value: rowData.CaseId });
        items.push({ xtype: 'hidden', name: 'quf_ParticipantId', value: rowData.ParticipantId });
        items.push({ xtype: 'hidden', name: 'quf_Visit', value: rowData.Visit });
        items.push({ xtype: 'hidden', name: 'quf_DrawDt', value: rowData.DrawDate });
        if (rowData.Attachments)
            items.push({ xtype: 'hidden', name: 'toDelete', value: rowData.Attachments });
        items.push({
            xtype: 'filefield',
            name: 'quf_File',
            allowBlank: false,
            anchor: '100%'
        });
        items.push({ xtype: 'hidden', name: 'X-LABKEY-CSRF', value: LABKEY.CSRF });

        Ext4.create('Ext.window.Window', {
            title: (rowData.Attachments ? 'Replace' : 'Insert') + ' Optional File for Visit ' + rowData.Visit + ' ' + rowData.AssayType,
            items: [Ext4.create('Ext.form.Panel', {
                border: false,
                bodyPadding: 10,
                items: items,
                buttons: [{
                    text: 'Upload',
                    formBind: true,
                    handler: function(btn)
                    {
                        var form = this.up('form').getForm();
                        if (form.isValid())
                        {
                            form.submit({
                                url: LABKEY.ActionURL.buildURL('adjudication', 'attachAdjudicationFiles'),
                                waitMsg: 'Uploading file...',
                                success: function() {
                                    btn.up('window').close();
                                    uploadAdditionalInfoStep();
                                }
                            });
                        }
                    }
                },{
                    text: 'Cancel',
                    handler: function(btn)
                    {
                        btn.up('window').close();
                    }
                }]
            })]
        }).show();

        LABKEY.Utils.signalWebDriverTest('optionalUpload', index);
    }

    // function called for step 4 of the wizard: Confirmation of uploaded data
    function displayCaseDetails()
    {
        // make sure that the attachment upload form isn't visible
        document.getElementById('attachmentFormDiv').style.display = 'none';

        Ext4.get('status').update("Summary of case details...");

        // query the database to get the details of case that was just uploaded (new or replaced)
        LABKEY.Query.selectRows({
            schemaName: 'adjudication',
            queryName: 'Case Details',
            filterArray: [LABKEY.Filter.create('CaseId', nextAdjId)],
            successCallback: queryCaseDetails,
            errorCallback: failureHandler,
            scope: this
        });
    }

    // callback function for selectRows api call: get case details for newly uploaded data to display in html table for confirmation
    function queryCaseDetails(data)
    {
        // build html table to display case details
        var html = "<table cellpadding='5' cellspacing='0' border='0' style='border-collapse: collapse;'>";

        // loop through the columns of the data result to display them vertically in the html table
        var row = data.rows[0];
        for (var i = 0; i < data.metaData.fields.length; i++)
        {
            var fieldName = data.metaData.fields[i].name,
                fieldVal = row[fieldName];

            if ("NULL::AssayLabelCount" != fieldName)
            {
                var modifiedFieldName = fieldName.replace("::AssayLabelCount", " Results");
                html += "<tr><td style='font-weight:bold; border: solid #C0C0C0 1px;'>" + modifiedFieldName + ":</td>"
                        + "<td style='border: solid #C0C0C0 1px;'>"
                        + (fieldVal == null ? "&nbsp;" : Ext4.util.Format.htmlEncode(fieldVal).replace(/[\r]?\n/g, "<br/>"))
                        + "</td></tr>";
            }
        }
        html += "</table>";

        Ext4.get('step4Div').update(html);
        document.getElementById('step4Div').style.display = "block";
    }

    // function called when "Finish" button is clicked: changes page location to review details page
    function goToFinish()
    {
        window.location = LABKEY.ActionURL.buildURL('adjudication', 'adjudicationReview', null, {
            adjid: nextAdjId,
            isAdminReview: true
        });
    }

    // error callback function for many api calls
    function failureHandler(errorInfo, response)
    {
        if (errorInfo && errorInfo.exception)
            showErrorAlert("Error", errorInfo.exception);
        else
            showErrorAlert("Error", response.statusText);
    }

    function showErrorAlert(title, msg, callbackFn)
    {
        var config = {
            title: title,
            msg: msg,
            buttons: Ext4.Msg.OK,
            icon: Ext4.Msg.ERROR
        };

        if (Ext4.isDefined(callbackFn))
            config.fn = callbackFn;

        Ext4.Msg.show(config);
    }

    function reloadPage() {
        location.reload();
    }

})(jQuery);