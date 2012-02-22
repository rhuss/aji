/*
 * Copyright 2009-2011 Roland Huss
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


var META = new JolokiaClient(new Jolokia("/jolokia"));

// options:


$("#mbean").autocomplete(
{
    source: function(req, resp) {
        var term = $.ui.autocomplete.escapeRegex(req.term);
        resp($.map(
                META.filterNames(term),
                function(name) {
                    var matcher = new RegExp("(" + term + ")", "ig");
                    return {
                        label: name.replace(matcher, "<strong>$1</strong>"),
                        value: name
                    };
                }));
    },
    autoFocus: true,
    minLength: 0,
    delay: 0
}).data("autocomplete")._renderItem = function(ul, item) {
    // only change here was to replace .text() with .html()
    return $("<li></li>")
            .data("item.autocomplete", item)
            .append($("<a></a>").html(item.label))
            .appendTo(ul);
};
$("#mbean").autocomplete(
{
    source: function(req, resp) {
        var term = $.ui.autocomplete.escapeRegex(req.term);
        resp($.map(
                META.filterNames(term),
                function(name) {
                    var matcher = new RegExp("(" + term + ")", "ig");
                    return {
                        label: name.replace(matcher, "<strong>$1</strong>"),
                        value: name
                    };
                }));
    },
    autoFocus: true,
    minLength: 0,
    delay: 0
}).data("autocomplete")._renderItem = function(ul, item) {
    // only change here was to replace .text() with .html()
    return $("<li></li>")
            .data("item.autocomplete", item)
            .append($("<a></a>").html(item.label))
            .appendTo(ul);
};


$("#mbean").bind("autocompleteselect", function(event, ui) {
    var mbean = ui.item;
    $("#attribute").empty();
    var meta = META.getMBeanInfo(mbean.value);
    if (meta.attr) {
        $.each(_.keys(meta.attr).sort(), function(i, key) {
            $("#attribute").append($("<option></option>").text(key));
        });
    }
    $("#attribute").focus();
    ui.disable();
});
