var BasicAppRouter = Backbone.Router.extend({
    
    routes: {
        "play" :"play",
        "tasks/:id" : "task",
        "static/:name" : "static_content"
    },
    
    initialize:function(options){
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
      task.on('answered',function(){
        me.app.navigate("play");
      });
      this.render(task);
    },

    render:function(task){
      //to implement
    }
  });