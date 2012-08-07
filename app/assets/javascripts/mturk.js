/**
* Mechanical Turk Facilitator class

add your html code:
  <script src="/assets/mturk.js"></script>

then you can use the class MTurk:

  $(function(){
    var mturk = new MTurk();

    //(optional) to enable sandbox mturk
    mturk.set_sandbox(true);
    
    // to check of if we are in a mturk environment 
    // i.e. if the url contains 'assignmentId' parameters
    // return true or false
    mturk.env_detected
    
    // submit the HIT
    mturk.submit();
    
    // submit the HIT with data
    mturk.submit({param1: val1, param2: val2});
  });
*/

var MTurk = function(options){
    options = options ? options : {};
  // create a form at the end of body
  $("body").append("<form method='POST' id='form_mturk'>");
  this.setup_environment(options.sandbox || false);
};

MTurk.prototype.setup_environment = function (sandbox){
  var assignment=$.urlParam('assignmentId');
  if (assignment !== 0){
    console.log("mturk environment detected.");
    this.env_detected = true;
    this.add_hidden_input("assignmentId",assignment);
    this.set_sandbox(sandbox);
  } else {
    this.env_detected = true;
    console.log("mturk environment not detected.");
  }
  return (this.mturk_detected);
};

MTurk.prototype.set_sandbox = function (sandbox){
  console.log("sandbox env: "+sandbox);
  var turk_url = (sandbox)? "https://workersandbox.mturk.com/mturk/externalSubmit" : "https://www.mturk.com/mturk/externalSubmit";
  $("#form_mturk").attr("action",mturk_url);
};

MTurk.prototype.add_hidden_input = function (name,value){
  $("#form_mturk").append("<input type='hidden' name='" + name + "' value='" + value + "' />");
};

MTurk.prototype.submit = function (hash_data){
  if (hash_data !== undefined){
    $each(hash_data, function(name, value){
      this.add_hidden_input(name,data);
    });
  }
  $("#form_mturk").submit();
};

/**
 * Helper 
 **/
$.urlParam = function(name){
  var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results == null){
    return 0;
  }else{
    return results[1] || 0;
  }
};