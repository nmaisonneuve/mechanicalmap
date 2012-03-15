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


    table_schema:function() {
        //abstract function  to implement in the sub class
    },

    initialize_ui:function() {

        var micro_task = this;

        //bind ajax request to function load/save
        $("#skip_task").click(function(event) {
            event.preventDefault();
            micro_task.request_task(micro_task.task.area.id);
        });

        $("#submit_task").bind('ajax:before',
            function() {
                micro_task.save();
            }).bind('ajax:success',
            function(evt, data, status, xhr) {
                console.log(data);
                if (data.submit_url){
                    micro_task.load(data);
                }else
                    micro_task.no_task();

            }).bind('ajax:error', function(data, status, xhr) {
            });
    }
    ,

    request_task:function(from_task) {
        var mt = this;
        var query = (from_task == undefined) ? ".json" : ".json?from_area=" + from_task;
        $.getJSON(this.scheduler_url + query,
            function(task) {
                console.log(task);
              if (task.submit_url){
                    mt.load(task);
                }else
                    mt.no_task();
            })
            .error(function(data, status, xhr) {
                console.log("error");
                console.log(data);
                console.log(status);
            })
    }
    ,

    load:function(task) {
        this.task = task;
        $("#submit_task").attr("action", task.submit_url);
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


