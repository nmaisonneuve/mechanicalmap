/* ============================================================
 * Example of MicroTask Interpreter class
 * NM
 * ============================================================
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================ */


var FTMicroTask = AbstractMicroTask.extend({

    init:function (options) {
        this._super(options);
        this.ft_table = options.ft_table || ft_table;
        this.columns = [];

    },

    start:function () {
        var me = this;
        // once the structure of a task is known
        // we request a task
        this.load_schema(function () {
            //me.request_task(null,function(task){
            me.next_cached_task(function(task) {
                me.load(task);
            });
        });
        this.load_completeness();
    },

    ft_request:function (query, callback_fct) {
        // Builds a Fusion Tables SQL query and hands the result to dataHandler()
        var queryUrlHead = 'http://www.google.com/fusiontables/api/query?sql=';
        var queryUrlTail = '&jsonCallback=?'; // ? could be a function name
        // write your SQL as normal, then encode it
        query = queryUrlHead + query + queryUrlTail;
        var queryurl = encodeURI(query);
        $.get(queryurl, function (data) {
            callback_fct(data);
        }, "jsonp");
    },

    request_task:function (from_task, success_callback) {
        var me = this;
        this._super(from_task, function (task) {
            
            // request more info about the task to the google fusion table
            // and interpret the result to display it
            var query = "SELECT ROWID, " + me.columns.join(",") + " FROM " + me.ft_table + " WHERE "+task.ft_task_column+" = '" + task.task.input + "'";
            if (me.debug){
                console.log("fetching FT input table: "+query);
            }
            me.ft_request(query, function (ft_data) {
                if (me.debug){
                    console.log("Data received from the FT task table: ");
                    console.log(ft_data);
                }
                if (ft_data.table.rows.length == 0) {
                    me.no_available_task();
                } else {
                    task.data=ft_data;
                    if (me.debug){
                       console.log("add ft input data with data from task managers:");
                       console.log(task);
                    }
                    success_callback(task);
                }
            });
        });
    },



    load_schema:function (callback_fct) {
        var me = this;
        this.ft_request("DESCRIBE " + this.ft_table, function (data) {
            $.each(data.table.rows, function (i, row) {
                me.columns.push(row[1]);
            });
            callback_fct();
        });
    }
});