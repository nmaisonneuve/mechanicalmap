
GF_TABLE_BASE_URL = "https://www.google.com/fusiontables/DataSource?docid=";

function create_gf_table(mode, form_field, callback) {
  $('#create_' + mode).attr("disabled", true);
  $('#create_' + mode).html("Creating table...");
  $.getJSON("/apps/create_gf_table.json?table=" + mode, function(data) {
      $(form_field).val(GF_TABLE_BASE_URL + data.ft_table_id);
      $('#create_' + mode).hide();
      link = $("<a href='" + GF_TABLE_BASE_URL + data.ft_table_id + "' target='_blank' >see/modify the table</a>");
      $('#link_' + mode).append(link);
  });
}

function url_google(ft_table) {
    var key = 'AIzaSyDaD2I-HSjUXgmQr9uOvF5-wZTwgfLgW-Q';
    var sqlquery = "DESCRIBE " + ft_table;
    return 'https://www.googleapis.com/fusiontables/v1/query?sql=' + encodeURI(sqlquery) + "&key=" + key;
}

function load_schema(url, callback_fct) {
    var columns = [];
    $.ajax({
        url: url,
        success: function(data) {
            $.each(data.rows, function(i, row) {
                columns.push(row[1]);
            });
            $("#task_state").attr("src","");
            $("#task_state").show();
            callback_fct(columns);
        },
        error: function(data) {
            $("#task_state").attr("src","");
            $("#task_state").show();
            $("#task_column").hide();
        }
    });
}

function retrieve_columns_names() {
    var ft_table = $('#app_challenges_table_url').val().replace(GF_TABLE_BASE_URL, "");
    load_schema(url_google(ft_table), function(columns) {
        select = $("#app_task_column");
        select.html("");
        options = "";
        for (var i = 0; i < columns.length; i++) {
            options += "<option value='" + columns[i] + "'>" + columns[i] + "</option>";
        }
        select.append(options)
        $("#task_column").show();
    });
}

$(function() {
    $('a[rel=popover]').popover({
        placement: 'right',
        offset: 5,
        html: true
    });


    $('#create_tasks').click(function(event) {
      create_gf_table("tasks", '#app_challenges_table_url', function(){
        retrieve_columns_names();
      });
      return false;
    });

    $('#create_answers').click(function(event) {
      create_gf_table("answers", '#app_answers_table_url', function(){});
      return false;
    });

    $('#app_challenges_table_url').change(function() {
        retrieve_columns_names();
    });

    $("#save").click(function() {
        $("#form_app").submit();
    });

    if ($('#app_challenges_table_url').val() != "") {
      retrieve_columns_names();
    }
});