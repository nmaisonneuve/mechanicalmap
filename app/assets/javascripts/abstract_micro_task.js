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
     
        this.size_cache_queue=options.size_cache_queue || 1;
        this.task_url=null;
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
        $.getJSON(application_url + "/user_state.js?callback=?", function (data) {
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
    
    send_answer:function(){
        var me = this;
        var answer=JSON.stringify(me.save());
<<<<<<< HEAD
        
=======
        console.log(answer);
        this.task_done++;
>>>>>>> 45d3f52d97bd33013ae8153f6ed83caa8d5ece44
        $.ajax({
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            type: "PUT",
            url: me.task_url,
            contentType: "application/json",
            data: {answer: answer},
            success: function(){
                me.next_cached_task(function(data){me.load(data)});
            },error:function(data){
                console.log("error saving");
            }
        });
    },

    initialize_ui:function () {

        var me = this;
        $("#task_user_id").html(user.name);
        //bind ajax request to function load/save
        $("#" + this.el_ids["skip_task"]).click(function (event) {
            event.preventDefault();
            me.next_cached_task(function(data){me.load(data);});
        });
    },

    caching_task:function (callback) {
        var me = this;
        if (me.cache.length <= me.size_cache_queue){ 
            var from_task = (me.cache.length == 0) ? null : me.cache[me.cache.length - 1].task.id;
            console.log("caching new task  (from task " + from_task + ") - cache size "+me.cache.length);
            this.request_task(from_task, function (data) {
                me.cache.push(data);
                callback();
                // recursive cache if required
                me.caching_task(function () {
                });
          
        });
    },

    //answer task
    worflow:function(){
        // function generate by users
        // give me a random task where status=0 order by priority

        //get the available tasks, status, priority, input_data(json)
        //see the number of answers
        // if too many answers
        // go to the next task
        // save parameters    
        // too hard, I want to solve it
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
      
      
        this.update_completeness_ui();
        // if cache empty we wait
        if (this.cache.length == 0) {
            this.loading();
            this.caching_task(function () {
                callback(me.cache.shift());
                me.loaded();
            });
        } else {
            // else we consume directly
            callback(this.cache.shift());
            //and cache a new tqsk asynchronouslyif reauired
            this.caching_task(function () {
                // background
                //me.loaded();

            });
        }
    },

    request_task:function (from_task, success_callback) {
        // debug mode
        if (this.options.debug_request_task) {
            this.options.debug_request_task(from_task);
        } else {
            var me = this;
            var query = (from_task == undefined) ? ".js?callback=?" : ".js?from_task=" + from_task+"&callback=?";
            if (this.debug){
                console.log("requesting the scheduler: " + this.scheduler_url + "" + query);
            }
            var me=this;
            console.log(this.scheduler_url + query);
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
                    console.log(data);
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
        this.task_url=data.submit_url;
        $("#" + this.el_ids["form_task"]).attr("action", data.submit_url);
    }

});


