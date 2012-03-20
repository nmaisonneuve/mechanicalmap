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

    init: function(scheduler_url, ft_table) {
        this._super(scheduler_url);
        this.ft_table = ft_table;
        this.columns = [];
    },

    start
        :
        function() {
            var me = this;
            // once the structure of a task is known
            // we request a task
            this.load_schema(function() {
                me.request_task();
            });
        }
    ,

    load:function(task, callback_fct) {
        this._super(task);

        // request more info about the task to the google fusion table
        // and interpret the result to display it
        var query = "SELECT ROWID, " + this.columns.join(",") + " FROM " + this.ft_table + " WHERE task_id='" + this.task_id + "'";
        ft_request(query, callback_fct);
    },
    load_schema:function(callback_fct) {
        var me = this;
        ft_request("DESCRIBE " + this.ft_table, function(data) {
            $.each(data.table.rows, function(i, row) {
                me.columns.push(row[1]);
            });
            callback_fct();
        });
    }
})
    ;