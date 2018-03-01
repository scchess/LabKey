/*
 * Copyright (c) 2009-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var BoundField = Ext.extend(Ext.form.TextField, {
    initComponent : function () {
        BoundField.superclass.initComponent.call(this);
    },

    initEvents : function () {
        BoundField.superclass.initEvents.call(this);
        this._originalValue = this.getValue();
        this.on('specialkey', this.handleSpecial, this);
    },

    handleSpecial : function (self, e) {
        var key = e.getKey();
        if (key == Ext.EventObject.ESC)
        {
            this.setValue(this._originalValue);
        }
        else if (key == Ext.EventObject.ENTER)
        {
            if (this.getValue() !== this._originalValue)
            {
                this.fireEvent('change', this, this.getValue(), this._originalValue);
            }
        }
    }
});

function h(str) {
    if (null == str)
        return "";
    else
        return Ext.util.Format.htmlEncode(str);
}

function showButtonBar(assay)
{
    var id = (typeof assay == "object") ? assay.id : LABKEY.ActionURL.getParameter("rowId");
    var buttons = [{url:LABKEY.ActionURL.buildURL("iavielisa", "begin", null, {rowId:id}), title:"Overview"},
    {title:"Add Data", url:LABKEY.ActionURL.buildURL("assay", "moduleAssayUpload", null, {rowId:id})},
        {title:"View Results", url:LABKEY.ActionURL.buildURL("assay", "assayData", null, {rowId:id})}];    
    if (LABKEY.Security.currentUser.isAdmin)
        buttons.push({url:LABKEY.ActionURL.buildURL("assay", "designer", null, {rowId:id, providerName:"elisa"}), title:"Manage"});

    LABKEY.NavTrail.setTrail("IAVI Elisa", []);
    Ext.get("labkey-nav-trail-current-page").update(buildButtonBar("IAVI Assay", buttons));
}

function buildButtonBar(pageTitle, buttonArray)
{
    var html = '<table style="width:100%;border-top:1px solid white;margin:0;padding:0">\
    <tr><td class="labkey-nav-page-header" style="padding:0pt;width:100%">' + pageTitle + '</td><td>\
            <table class="labkey-app-button-bar labkey-no-spacing" >\
                <tr><td class="labkey-app-button-bar-left"><img width="13" src="/labkey/_.gif" alt=""/></td>';

    for (var i = 0; i < buttonArray.length; i++)
        html += '<td class="labkey-app-button-bar-button"><a href="' + buttonArray[i].url + '">'+ buttonArray[i].title +'</a></td>'

    html += '<td class="labkey-app-button-bar-right"><img width="13" src="/labkey/_.gif" alt=""/></td></tr>' +
            '</table></td></tr></tbody></table>';

    return html;
}

function getDateField(config)
{
    Ext.applyIf(config, {
        altFormats: "j M Y H:i:s O|Y-m-d" +
                  'n/j/y g:i:s a|n/j/Y g:i:s a|n/j/y G:i:s|n/j/Y G:i:s|' +
                  'n-j-y g:i:s a|n-j-Y g:i:s a|n-j-y G:i:s|n-j-Y G:i:s|' +
                  'n/j/y g:i a|n/j/Y g:i a|n/j/y G:i|n/j/Y G:i|' +
                  'n-j-y g:i a|n-j-Y g:i a|n-j-y G:i|n-j-Y G:i|' +
                  'j-M-y g:i a|j-M-Y g:i a|j-M-y G:i|j-M-Y G:i|' +
                  'n/j/y|n/j/Y|' +
                  'n-j-y|n-j-Y|' +
                  'j-M-y|j-M-Y|' +
                  'Y-n-d H:i:s|Y-n-d',
        width: 200
    });
    var field = new Ext.form.DateField(config);
    field.menu = new Ext.menu.DateMenu({cls: 'extContainer'});

    return field;
}

function getProjPath()
{
    var projName = LABKEY.ActionURL.getContainer();
    var slashPos = projName.indexOf("/", 1);
    projName = projName.substring(0, slashPos == -1 ? projName.length: slashPos);
    return projName;
}


function configCreateStudy(linkParentEl)
{
    LABKEY.Security.getContainers({includeSubfolders:true,
        containerPath:getProjPath(),
        successCallback:function(containerInfo) {
            //See if we already have a "Studies" container. If so, check to see if the user has permissions to create studies
            for (var i = 0; i < containerInfo.children.length; i++)
            {
                var container = containerInfo.children[i];
                if (container.name == "Studies")
                {
                    if(LABKEY.Security.hasPermission(container.userPermissions, LABKEY.Security.permissions.admin))
                        Ext.get(linkParentEl).update("<a href='#' class='labkey-text-link' onclick='showCreateStudy()'>New Study</a>");

                    return;
                }
            }
            //NO studies folder. Remind admins that they could create one
            if (LABKEY.Security.hasPermission(container.userPermissions, LABKEY.Security.permissions.admin))
                Ext.get(linkParentEl).update("Admin note: <a href='" + LABKEY.ActionURL.buildURL("admin", "createFolder", getProjPath()) +"' class='labkey-text-link'>Create 'Studies' folder</a>" )
        }
    });
}


var possibleVisits = [{label:'Day 0', minDays:0, maxDays:0, group:'Days'},
{label:'Day 1', minDays:1, maxDays:1, group:'Days'},
{label:'Day 2', minDays:2, maxDays:2, group:'Days'},
{label:'Day 3', minDays:3, maxDays:3, group:'Days'},
{label:'Day 4', minDays:4, maxDays:4, group:'Days'},
{label:'Day 5', minDays:5, maxDays:5, group:'Days'},
{label:'Week 1', minDays:5, maxDays:10, group:'Weeks'},
{label:'Week 2', minDays:12, maxDays:17, group:'Weeks'},
{label:'Week 3', minDays:19, maxDays:24, group:'Weeks'},
{label:'Week 4', minDays:26, maxDays:31, group:'Weeks'},
{label:'Week 5', minDays:33, maxDays:38, group:'Weeks'},
{label:'Week 6', minDays:40, maxDays:45, group:'Weeks'},
{label:'Week 7', minDays:47, maxDays:52, group:'Weeks'},
{label:'Week 8', minDays:54, maxDays:59, group:'Weeks'},
{label:'Week 9', minDays:61, maxDays:66, group:'Weeks'},
{label:'Week 10', minDays:68, maxDays:73, group:'Weeks'},
{label:'Week 11', minDays:75, maxDays:80, group:'Weeks'},
{label:'Week 12', minDays:82, maxDays:87, group:'Weeks'},
{label:'Week 13', minDays:89, maxDays:94, group:'Weeks'},
{label:'Week 14', minDays:96, maxDays:101, group:'Weeks'},
{label:'Week 15', minDays:103, maxDays:108, group:'Weeks'},
{label:'Week 16', minDays:110, maxDays:115, group:'Weeks'},
{label:'Week 17', minDays:117, maxDays:122, group:'Weeks'},
{label:'Week 18', minDays:124, maxDays:129, group:'Weeks'},
{label:'Week 19', minDays:131, maxDays:136, group:'Weeks'},
{label:'Week 20', minDays:138, maxDays:143, group:'Weeks'},
{label:'Week 21', minDays:145, maxDays:150, group:'Weeks'},
{label:'Week 22', minDays:152, maxDays:157, group:'Weeks'},
{label:'Week 23', minDays:159, maxDays:164, group:'Weeks'},
{label:'Week 24', minDays:166, maxDays:171, group:'Weeks'}
]; //Default set of visits. Can also get them from a list called 'Visits' at the project level

function showCreateStudy()
{
    var studyInfo = {name:"", startDate:new Date().format("n/d/Y"), cohortDataset:"Subjects", cohortProperty:"Cohort",
        visits:[],
        webParts:[{partName:"Study Overview"}, {partName:"Datasets"}, {partName:"IAVI Elisa Results"}, {partName:"Files", location:"right"}],
        datasets:[{name:"Subjects", demographicData:true}]};

    var visits = [];


    function addVisit(visit) {
        var visits = studyInfo.visits;
        for (var i = 0; i < visits.length; i++)
        {
            if (visits[i].minDays < visit.minDays)
            {
                visits.splice(i, 0, visit);
                return;
            }
        }
        visits.push(visit);
    }

    function removeVisit(visit) {
        var visits = studyInfo.visits;
        for (var i = 0; i < visits.length; i++)
        {
            if (visits[i].minDays < visit.minDays)
            {
                visits.splice(i, 1);
                return;
            }
        }
    }

    function addVisitCheckbox(visit) {
        var cb = new Ext.form.Checkbox ({
            listeners: {
                check:function(field, checked)
                {
                    if (checked)
                        addVisit(visit);
                    else
                        removeVisit(visit);
                }
            },
            renderTo:"visit",
            boxLabel:visit.label
        });
    }



    function doCreate()
    {
        if (studyInfo.startDate == null || studyInfo.startDate == "" || studyInfo.name == null || studyInfo.name == "")
        {
            alert("Start date and name are required");
            return;
        }
        
        Ext.Ajax.request({
            url : LABKEY.ActionURL.buildURL("study", "quickCreateStudy", getProjPath() + "/Studies"),
            method : 'POST',
            success: function(response, options) {
                var data = Ext.util.JSON.decode(response.responseText);

                //Now edit the domain
                LABKEY.Domain.get(
                        function (domain) {
                            domain.fields.push({name:"Cohort", rangeURI:"http://www.w3.org/2001/XMLSchema#string"});
                            LABKEY.Domain.save(function () {
                                    window.location = LABKEY.ActionURL.buildURL("project", "begin", data.containerPath);
                                },
                                function() {
                                    alert("Failure saving domain");
                                },
                                domain,
                                "study",
                                "Subjects",
                                data.containerPath);
                            },
                        function() {alert("Getting domain failed");},
                        "study",
                        "Subjects",
                        data.containerPath);
             },
            failure: function() { alert("Create study failed"); },
            jsonData : studyInfo,
            headers : {
                'Content-Type' : 'application/json'
            }
        });
    }

        var field = getDateField({
          listeners: {
            'change': function (field, newValue, oldValue) {
              studyInfo.startDate = newValue.format("n/d/Y");
            }
          },
            fieldLabel:"StartDate",
            allowBlank:false,
          value: new Date(new Date().format("n/d/Y")) //Easiest way to trim off the time...
        });

        var nameField = new Ext.form.TextField({
          listeners: {
            'change': function (field, newValue, oldValue) {
              studyInfo.name = newValue;
            }
          },
          allowBlank:false,
          fieldLabel:"Study Name",
          width: 200
        });

        var createWin = new Ext.Window({
            title:"Create Study",
            layout:"form",
            width:500,
            items:[field,nameField,{xtype:'container', autoEl:{tag:'div', id:'visit'}}],
            bbar:[{text:"Create", handler:doCreate}]
        });
        createWin.show();

        Ext.get("visit").insertHtml('beforeEnd', "<div style='width:100%;border-bottom:1px solid black;font-size:larger'>Choose timepoints</div>");
                    LABKEY.Query.selectRows({schemaName:"lists", queryName:"Visits", containerPath:getProjPath(), sort:"group,minDays",
                        successCallback:function(data) {
                            addVisitCheckboxes(data.rows);
                            },
                        errorCallback:function() {
                            addVisitCheckboxes(possibleVisits);
                        }
                    });

    function addVisitCheckboxes(visitRows)
    {
        var group = null;
        for (var i = 0; i < visitRows.length; i++)
            {
                var visit = visitRows[i];
                if (group != visit.group)
                {
                    group = visit.group;
                    Ext.get("visit").insertHtml('beforeEnd', "<br><b>" + h(group) + "</b><hr>");
                }
                addVisitCheckbox(visit);
            }
    }

}

var IaviElisa = {
    assayTypeName:"IAVI Elisa",
    getProtocols:function(callback) {
        LABKEY.Assay.getByType({type:this.assayTypeName,
            successCallback:callback,
            failureCallback:function() {Ext.Msg.alert("Couldn't get assays");}});
    },
    percentDiffCutoff:.20
};


