/**

this is a backbone router ( http://backbonetutorials.com/what-is-a-router/ ) for a basic microapp 

by convention:

app.navigate("static/mysection") will display 
 <section id="mysection">...</section> and hide the other <section> tags

e.g. app.navigate("static/intro") to start your app with an intruction panel <section id="intro">

app.navigate("play") will load the next task e.g. task with ID =12
and then executes app.navigate("tasks/12")
that call router.task:function(id)
*/
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