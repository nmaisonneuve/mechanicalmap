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


$("#task_user_id").html(user.name);
table_data = new google.visualization.DataTable();
table_data.addColumn('string', 'Author Name');
table_data.addColumn('string', 'Author affiliation (address)');
table_data.addColumn('string', 'Doc title');
table_data.addColumn('string', 'Belongs to');
table = new google.visualization.Table(document.getElementById('table_div'));
$("#submit_button").click(function () {
    $("#form_task").submit();
});