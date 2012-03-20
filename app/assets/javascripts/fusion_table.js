function ft_request(query, callback_fct) {
    // Builds a Fusion Tables SQL query and hands the result to dataHandler()
    var queryUrlHead = 'http://www.google.com/fusiontables/api/query?sql=';
    var queryUrlTail = '&jsonCallback=?'; // ? could be a function name
    // write your SQL as normal, then encode it
    query = queryUrlHead + query + queryUrlTail;
    var queryurl = encodeURI(query);
    $.get(queryurl, function(data) {
        callback_fct(data);
    }, "jsonp");
}