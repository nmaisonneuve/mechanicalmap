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

    initialize_ui:function(submit_id, skip_id) {

        var me = this;
        //bind ajax request to function load/save
        $("#"+skip_id).click(function(event) {
            event.preventDefault();
            me.request_task(me.task.id);
        });

        $("#"+submit_id).bind('ajax:before',
            function() {
                me.save();
            }).bind('ajax:success',
            function(evt, data, status, xhr) {
                me.request_task(me.task);
                //if (data.submit_url) {
                //    me.load(data);
                //} else
                //    me.no_available_task();
            }).bind('ajax:error', function(data, status, xhr) {
            });
    },

    request_task:function(from_task) {
        var me = this;
        var query = (from_task == undefined) ? ".js" : ".js?from_task=" + from_task;

        $.getJSON(this.scheduler_url + query,
            function(task) {
                if (task.submit_url) {
                    me.load(task);
                } else
                    me.no_task();
            })
            .error(function(data, status, xhr) {
                if (data.status == 404) {
                    me.no_available_task();  // no task available
                } else {
                    console.log("error");
                }
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
    no_available_task: function () {
        alert("no task available");
        //abstract function  to implement in the sub class
    }
});


