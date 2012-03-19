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


var MicroTask = AbstractMicroTask.extend({

    init: function(scheduler_url, ft_table) {

        this._super(scheduler_url);


        this.markers = [];
        this.area = null;
        this.ft_table = ft_table;

        this.columns = [];


        map = new google.maps.Map(document.getElementById('map'), {
            zoom: 3,
            center: new google.maps.LatLng(70, 0),
            mapTypeId: google.maps.MapTypeId.SATELLITE,
            panControl: false,
            zoomControl: true,
            scaleControl: false,
            streetViewControl: false,
            overviewMapControl: false
        });

        var drawingManager = new google.maps.drawing.DrawingManager({
            drawingMode: google.maps.drawing.OverlayType.MARKER,
            drawingControl: true,
            drawingControlOptions: {
                position: google.maps.ControlPosition.TOP_CENTER,
                drawingModes: [google.maps.drawing.OverlayType.MARKER]
            },
            markerOptions: {zIndex:1,draggable:true}
        });
        drawingManager.setMap(map);

        var self = this;
        google.maps.event.addListener(drawingManager, 'markercomplete', function(marker) {
            // outside the area
            if (!self.rectangle.getBounds().contains(marker.position)) {
                marker.setMap(null);
                return;
            }
            // we remove the marker if we click on it
            google.maps.event.addListener(marker, 'click', function() {
                self.markers = jQuery.grep(self.markers, function(value) {
                    return value != marker;
                });
                marker.setMap(null);
            });
            self.markers.push(marker);
        });
    },

    start:function() {
        var me = this;
        this.schema_ft_data(function() {
            me.request_task();
        });
    },
    load:function(task) {
        this._super(task);
        var me = this;

        // clean map
        for (var i = 0; i < me.markers.length; i++) {
            me.markers[i].setMap(null);
        }
        me.markers.length = 0;

        // load task
        this.load_ft_data(task.task.id, function(data) {

            var poly_js = data.table.rows[0][2];
            me.area = new GeoJSON(poly_js);
            console.log(me.area);
            if (me.area.error) {
                console.log(me.area.error)
            } else {
                me.area.setOptions({strokeColor:"#FF0000",
                    strokeWeight:"2",
                    fillOpacity:0});

                me.area.setMap(map);
                var bounds = me.area.getBounds();
                console.log(bounds);
                map.fitBounds(bounds);
            }
        });
    },
    schema_ft_data:function(callback_fct) {

        var queryUrlHead = 'http://www.google.com/fusiontables/api/query?sql=';
        var queryUrlTail = '&jsonCallback=?'; // ? could be a function name
        // write your SQL as normal, then encode it
        var query = "DESCRIBE " + this.ft_table;
        query = queryUrlHead + query + queryUrlTail;
        //console.log(query);
        var queryurl = encodeURI(query);
        var me = this;
        $.get(queryurl, function(data) {
            $.each(data.table.rows, function(i, row) {
                me.columns.push(row[1]);
            });
            callback_fct();
        }, "jsonp");
    }
    ,
    load_ft_data:function(task_id, callback_fct) {
        // Builds a Fusion Tables SQL query and hands the result to dataHandler()

        var queryUrlHead = 'http://www.google.com/fusiontables/api/query?sql=';
        var queryUrlTail = '&jsonCallback=?'; // ? could be a function name

        // write your SQL as normal, then encode it
        var query = "SELECT ROWID, " + this.columns.join(",") + " FROM " + this.ft_table + " WHERE task_id='" + task_id + "'";
        query = queryUrlHead + query + queryUrlTail;
        var queryurl = encodeURI(query);
        $.get(queryurl, function(data) {
            callback_fct(data);
        }, "jsonp");
    },


    /*
     Function called just before submitting data.
     The json format should reflect the structure of the (google fusion) table
     */
    save: function () {
        var rows = [];
        if (this.markers.length > 0) {
            for (var i = 0; i < this.markers.length; i++) {
                rows.push({ area_id:this.task.area.id,
                    task_id: this.task.id,
                    annotation: this.markers[i].position.lat() + " " + this.markers[i].position.lng()});
            }
        } else {
            // no annotation
            rows.push({ area_id:this.task.area.id,
                task_id: this.task.id,
                annotation: " "});
        }
        $("#task_answer").val(JSON.stringify(rows));
    }
    ,
    no_available_task:function() {

    }
})
    ;
