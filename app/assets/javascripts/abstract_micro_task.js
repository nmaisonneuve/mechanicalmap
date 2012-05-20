 /* ============================================================
 * Abstract MicroTask class
 * NM
 * http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================ */

var AbstractMicroTask = Class.extend({

    init:function(options) {

        this.scheduler_url = options.scheduler_url;
        this.user = options.user;

        this.options=options;

        // current task
        this.task = null;

        //project completeness
        this.task_completed = 0;
        this.task_done = 0;

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

    caching:function(current_task){
        var from_task=current_task;
        this.request_task(current_task);
    },

    request_task:function(from_task) {
        // debug mode
        if (this.options.debug_mode== true){
            this.options.debug_request_task(from_task);
        }else {

        var me = this;
        var query = (from_task == undefined) ? ".js" : ".js?from_task=" + from_task;
          console.log("pre info loaded."+this.scheduler_url+""+query);
        $.getJSON(this.scheduler_url + query,
            function(task) {

                if (task.submit_url) {
                    me.load(task);
                } else
                    me.no_available_task();
            })
            .error(function(data, status, xhr) {
                if (data.status == 404) {
                    me.no_available_task();  // no task available
                } else {
                    console.log(data);
                }
            })
        }
    },

    load:function(unit) {
        this.task = unit.task;
        console.log("loading "+unit.submit_url);
        $("#" + this.el_ids["form_task"]).attr("action", unit.submit_url);
    },

    no_available_task: function () {
        alert("no task available");
        //abstract function  to implement in the sub class
    }
});


