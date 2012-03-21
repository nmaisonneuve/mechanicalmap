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

    init:function(options) {


        this.scheduler_url = options.scheduler_url;
        this.user=options.user;

        // current task
        this.task = null;

        //project completeness
        this.task_completed = 0;
        this.task_done = 0;

        //HTML element id
        this.el_ids={
            "task_done":"task_done",
            "task_completed":"task_done",
            "progress_bar_id":"progress_bar_id",
            "skip_task":"skip_task",
            "submit_task":"submit_task",
            "task_answer":"task_answer",
            "form_task":"form_task"
        };
    },

    update_completeness_ui:function() {
        $("#" + this.el_ids["task_done"]).html(this.task_done);
        $("#" + this.el_ids["task_completed"]).html(this.task_completed);
        $("#" + this.el_ids["progress_bar_id"]).css.width((this.task_done / this.task_completed) * 100 + "%");
    },

    initialize_ui:function() {

        var me = this;
        //bind ajax request to function load/save
        $("#" + this.el_ids["skip_task"]).click(function(event) {
            event.preventDefault();
            me.request_task(me.task.id);
        });

        $("#" + this.el_ids["form_task"]).bind('ajax:before',
            function() {
                me.save();
            }).bind('ajax:success',
            function(evt, data, status, xhr) {
                me.request_task(me.task.id);
            }).bind('ajax:error', function(data, status, xhr) {
                console.log(data);

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
        this.task = unit.task;
        $("#"+this.el_ids["form_task"]).attr("action", unit.submit_url);
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


