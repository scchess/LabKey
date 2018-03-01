/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.ns('CNPRC.Utils');

CNPRC.Utils = (function(){

    return {
        legendEntry: function (value, description, beginRow, endRow) {
            return (beginRow ? "<tr>" : "") +
                    "<td class='ehr-legend-value'>" + value + "</td><td>" + description + "</td>" +
                    (endRow ? "</tr>" : "");
        },

        legendTitle: function (value, beginRow, endRow) {
            return (beginRow ? "<tr>" : "") +
                    "<td colspan='2'>" + value + "</td>" +
                    (endRow ? "</tr>" : "");
        }
    };
})();