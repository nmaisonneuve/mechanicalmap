var BasicAppRouter = Backbone.Router.extend({
    routes: {
        "play" :"play",
        "tasks/:id" : "task",
        "static/:name" : "static_content"
    },
    initialize:function(options){
        console.log(options);
     this.app=options.app;   
    },
    static_content:function(name){
       $("section").hide(); $("#"+name).show();
    },
    
    play:function(){
      this.static_content("task");
      this.app.tasks.next();
    },
    
    task:function(id){
      var me=this;
      task=this.app.tasks.get(id);
      task.on('answer_saved',function(){
        me.app.navigate("play");
      });
      var view=new TaskView({model:task});
      view.render();
    },
  });

window.GFAnswer = Backbone.Model.extend({
  initialize: function(options) {
    this.url = function(){return options.app_root+"/tasks";};
  },
});

window.GFTask = Backbone.Model.extend({

  save_answer:function (data){
    var  me=this;
    answer = new GFAnswer({id: this.get('answer_id'), rows: data});
    answer.on('sync',function (answer){
      me.trigger('answer_saved',answer);
    }, answer);
    var url = this.url()+"/answers" +((answer.isNew())? "" : "/"+answer.id);
    answer.save(undefined,{url:url});
  },

  // parse differently according to the provider (volatiletask vs google fusion)
  parse: function(resp) {
    if (resp.columns) {
      data = {
        gftable: {
          columns: resp.columns,
          rows: resp.rows
        }
      };
      if (resp.rows.length == 1) {
        _.each(resp.columns, function(column, i) {
          data[column] = resp.rows[0][i];
        });
      }
      return data;
    } else return resp;
  },

  sync: function (method, model, options){
    if (method == "read")
      options.url = this.url_google();
      Backbone.sync(method,model,options);
  },

  url_google: function() {
    var gftable = this.get('gftable');
    var key = 'AIzaSyDaD2I-HSjUXgmQr9uOvF5-wZTwgfLgW-Q';
    var sqlquery = "SELECT * FROM " + gftable.ft_table + " WHERE " + gftable.ft_task_column + " = '" + this.id + "'";
    return 'https://www.googleapis.com/fusiontables/v1/query?sql=' + encodeURI(sqlquery) + "&key=" + key;
  }
});

window.DefaultVolatileTasks = Backbone.Collection.extend({
  fetch: function(options) {
    options = options ? _.clone(options) : {};
    var collection = this;
    var success_fct = function(resp, status, xhr) {
        collection.models[collection.models.length-1].fetch(options);
      };
    var error_fct = Backbone.wrapError(options.error, this, options);
    Backbone.Collection.prototype.fetch.call(this, {add:true,
      success: success_fct, error:error_fct,
      url:options.url});
  }
});

var DefaultTaskManager = Class.extend({

  init: function(options){
    _.extend(this, Backbone.Events); // mixed with event
    this.tasks = new DefaultVolatileTasks();
    this.tasks.model = options.task_model || GFTask;
    this.tasks.url   = options.root_url + "tasks";
    this.notask = false;
    this.models = this.tasks.models;
    this.tasks.on("no_task",function(){this.notask = true;},this);
  },
  
  caching: function(last_task, callback,no_task_handler){
      
    if ((this.tasks.models.length <= 2 && (!this.notask))) {
      
      var me = this;
      
      var success = function(task){
        if (callback) callback();
        me.caching(task.id); //and cache further tasks
      };
      
      console.log("caching a task  (from previous task " + last_task + ") - cache size " + this.tasks.models.length);
      
      this.tasks.fetch({url: this.tasks.url+"/next.js?from_task="+last_task, success:success, error:function(){
          me.notask = true;
          if (no_task_handler) no_task_handler.trigger("no_task");
      }});
    }
  },
  
  last_task_id:function (){
    return (this.models.length === 0 || this.models[this.models.length - 1].isNew())? "" : this.models[this.models.length - 1].id;
  },
  
  get :function(id){
    return this.tasks.get(id);
  },

  next: function(options){

    var last_task_id = this.last_task_id();
    
    var me = this;
    
    var consume = function(){
      me.trigger("next_task",me.models.shift());
    };
    
    if (this.tasks.models.length > 0){
      consume();
      this.caching(last_task_id);  //and cache further tasks
    }
    
    else{
      if (!this.notask){
        this.trigger("loading_task");
        this.caching(last_task_id,consume,this);
      }else{
        this.trigger("no_task");
      }
    }
  }
});

VolatileTaskApp = Class.extend({

 init: function (options){
    this.root_url = options.root_url;
    this.tasks = new DefaultTaskManager(options);
    this.router = options.router || new BasicAppRouter({app:this});
  },

  navigate: function(route){
    return this.router.navigate(route,{trigger:true});
  },

  add_route: function(route, callback){
    return this.router.route(route,"#_"+route,callback);
  },

  start: function(route) {
  // Trigger the initial route and enable HTML5 History API support, set the
  // root folder to '/' by default.  Change in app.js.
  // pushState: true,
    Backbone.history.start({root: this.root_url}); 
    this.navigate(route);
 }
});