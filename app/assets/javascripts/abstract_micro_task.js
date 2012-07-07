/* ============================================================
 * Abstract MicroTask class
 * NM
 * http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================ */

var AbstractMicroTask = Class.extend({

    init:function (options) {

        this.options = options;

        this.scheduler_url = options.scheduler_url;
        this.user = options.user;
        this.debug=options.debug || false;

     
        // current task
        this.task = null;

        //project completeness
        this.task_done = 0;
        this.task_total = 1;

        // task cache
        this.cache = [];

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
    load_completeness:function () {
        var me = this;
        $.get(application_url + "/user_state.js", function (data) {
            me.task_done = data.completed;
            me.task_total = me.task_done + data.opened;
            me.task_done--; //loading the current task
            me. update_completeness_ui();
        });
    },

    update_completeness_ui:function () {
        var ratio = (this.task_done / this.task_total) * 100;
        if ($("#progress_bar").length > 0)
            $("#progress_bar").width(ratio + "%");
        if ($("#" + this.el_ids["task_done"]).length > 0)
            $("#" + this.el_ids["task_done"]).html(this.task_done);


    },

    loading:function () {

    },

    initialize_ui:function () {

        var me = this;
        $("#task_user_id").html(user.name);
        //bind ajax request to function load/save
        $("#" + this.el_ids["skip_task"]).click(function (event) {
            event.preventDefault();
            //me.request_task(me.task.id);
            me.next_cached_task(function(data){me.load(data);});
        });

        $("#" + this.el_ids["form_task"]).bind('ajax:before',
            function () {
                me.save();
            }).bind('ajax:success',
            function (evt, data, status, xhr) {
                //me.request_task(me.task.id);
                me.next_cached_task(function(data){me.load(data);});
            }).bind('ajax:error', function (data, status, xhr) {
                console.log("error saving");
                console.log(data);
            });
    },

    caching_task:function (callback) {
        var me = this;

        var from_task = (me.cache.length == 0) ? null : me.cache[me.cache.length - 1].task.id;
        console.log("caching new task  (from task " + from_task + ") - cache size "+me.cache.length);

        this.request_task(from_task, function (data) {
            me.cache.push(data);

            if (me.cache.length < 2) me.caching_task(function () {
            });
            callback();


        });
    },
    // abstract function
    loading:function(){},
    loaded:function(){},

    no_available_task:function () {
        alert("no task available");
        //abstract function  to implement in the sub class
    },
    next_cached_task:function (callback) {


        console.log("request cached task");
        var me = this;
        this.loading();
        this.task_done++;
        this.update_completeness_ui();
        // if cache empty we wait
        if (this.cache.length == 0) {
            this.caching_task(function () {
                callback(me.cache.shift());
                me.loaded();
            });
        } else {
            // else we consume directly
            callback(this.cache.shift());
            //and cache asynchronously
            this.caching_task(function () {
                me.loaded();
            });
        }

    },

    request_task:function (from_task, success_callback) {
        // debug mode
        if (this.options.debug_request_task) {
            this.options.debug_request_task(from_task);
        } else {
            var me = this;
            var query = (from_task == undefined) ? ".js" : ".js?from_task=" + from_task;
            if (this.debug){
                console.log("requesting the scheduler: " + this.scheduler_url + "" + query);
            }
            var me=this;
            $.getJSON(this.scheduler_url + query,
                function (task) {
                    if (me.debug){
                        console.log("data received from the scheduler:")
                        console.log(task);
                    }
                    if (task.submit_url) {
                        success_callback(task);
                    } else
                        me.no_available_task();
                })
                .error(function (data, status, xhr) {
                    console.log("error get task");
                    if (data.status == 404) {
                        me.no_available_task();  // no task available
                    } else {
                        console.log("error requesting task");
                        console.log(data);
                    }
                })
        }
    },

    load:function (data) {
        this.task = data.task;
        $("#" + this.el_ids["form_task"]).attr("action", data.submit_url);
    }

});


