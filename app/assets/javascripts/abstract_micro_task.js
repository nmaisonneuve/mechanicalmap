/* ============================================================
 * Abstract MicroTask class
 * NM
 * http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================ */

var AbstractMicroTask = Class.extend({

    init:function (options) {

        this.scheduler_url = options.scheduler_url;
        this.user = options.user;

        this.options = options;

        // current task
        this.task = null;

        //project completeness
        this.task_completed = 0;
        this.task_done = 0;

        this.cache=[];

        //HTML element id
        this.el_ids = {
            "task_done":"task_done",
            "task_completed":"task_done",
            "progress_bar_id":"progress_bar_id",
            "skip_task":"skip_task",
            "submit_task":"submit_task",
            "task_answer":"task_answer",
            "form_task":"form_task"
        };
        this.initialize_ui();
    },

    update_completeness_ui:function () {
        $("#" + this.el_ids["task_done"]).html(this.task_done);
        $("#" + this.el_ids["task_completed"]).html(this.task_completed);
        $("#" + this.el_ids["progress_bar_id"]).css.width((this.task_done / this.task_completed) * 100 + "%");
    },
    loading:function(){
        console.log("loading");
    },

    initialize_ui:function () {

        var me = this;
        $("#task_user_id").html(user.name);
        //bind ajax request to function load/save
        $("#" + this.el_ids["skip_task"]).click(function (event) {
            event.preventDefault();
            //me.request_task(me.task.id);
            me.request_task_from_cache(me.task.id,me.load);
        });

        $("#" + this.el_ids["form_task"]).bind('ajax:before',
            function () {
                me.save();
            }).bind('ajax:success',
            function (evt, data, status, xhr) {
                //me.request_task(me.task.id);
                me.request_task_from_cache(me.task.id,me.load);
            }).bind('ajax:error', function (data, status, xhr) {
                console.log(data);
            });
    },


    request_task_from_cache:function (from_task, callback) {
        consumed = false;
        var me=this;
        console.log("caching data 1");

        if (me.cache.length < 2) {
            this.request_task(from_task, function (data) {
                me.cache.push(data);
                console.log("caching data");
                if (!consumed) callback(me.cache.pop());
                me.request_task_from_cache(data.task.id);
            });
        }
        if ((me.cache.length > 0) && (callback !== null)) {
            consumed = true;
            callback(me.cache.pop());
        }
    },

    request_task:function (from_task, success_callback) {
        //default value
        if (success_callback == null) {
            success_callback = me.load
        }

        // debug mode
        if (this.options.debug_mode == true) {
            this.options.debug_request_task(from_task);
        } else {

            var me = this;
            var query = (from_task == undefined) ? ".js" : ".js?from_task=" + from_task;
            console.log("pre info loaded." + this.scheduler_url + "" + query);
            $.getJSON(this.scheduler_url + query,
                function (task) {

                    if (task.submit_url) {

                        success_callback(task);
                    } else
                        me.no_available_task();
                })
                .error(function (data, status, xhr) {
                    if (data.status == 404) {
                        me.no_available_task();  // no task available
                    } else {
                        console.log(data);
                    }
                })
        }
    },

    load:function (data) {
        this.task = data.task;
        console.log("loading " + data.submit_url);
        $("#" + this.el_ids["form_task"]).attr("action", data.submit_url);
    },

    no_available_task:function () {
        alert("no task available");
        //abstract function  to implement in the sub class
    }
});


