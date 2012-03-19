/* ============================================================
 * Abstract MicroTask class
 * NM
 * ============================================================
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================ */

var AbstractMicroTask = Class.extend({

    init:function(scheduler_url) {

        //default parameters
        this.scheduler_url = scheduler_url;
        this.task = null;
        this.initialize_ui();
    },

    initialize_ui:function() {

        var micro_task = this;

        //bind ajax request to function load/save
        $("#skip_task").click(function(event) {
            event.preventDefault();
            micro_task.request_task(micro_task.task.id);
        });

        $("#submit_task").bind('ajax:before',
            function() {
                micro_task.save();
            }).bind('ajax:success',
            function(evt, data, status, xhr) {
                if (data.submit_url) {
                    micro_task.load(data);
                } else
                    micro_task.no_available_task();

            }).bind('ajax:error', function(data, status, xhr) {
            });
    }
    ,

    request_task:function(from_task) {
        var mt = this;
        var query = (from_task == undefined) ? ".js" : ".js?from_task=" + from_task;

        $.getJSON(this.scheduler_url + query,
            function(task) {
                if (task.submit_url) {
                    mt.load(task);
                } else
                    mt.no_task();
            })
            .error(function(data, status, xhr) {
                console.log("error");
                console.log(data);
                console.log(status);
            })
    }
    ,

    load:function(unit) {
        console.log(unit);
        this.task = unit.task;
        $("#submit_task").attr("action", unit.submit_url);
    }
    ,

    /*
     Function called just before submitting data.
     The json format should reflect the structure of the (google fusion) table
     */
    save: function () {
        //abstract function  to implement in the sub class
    }
});


