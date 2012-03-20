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
var MicroTask = FTMicroTask.extend({

    init: function(scheduler_url, ft_table) {
        this._super(scheduler_url, ft_table);
        this.markers = [];
        this.map=null;
        this.area = null;
    },

    init_ui:function() {
        this.map = new google.maps.Map(document.getElementById('map'), {
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
        drawingManager.setMap(this.map);

        var self = this;
        google.maps.event.addListener(drawingManager, 'markercomplete', function(marker) {
            // outside the area
            if (!self.area.getBounds().contains(marker.position)) {
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

    load:function(task) {

        // clean map and the area
        for (var i = 0; i < this.markers.length; i++) {
            this.markers[i].setMap(null);
        }
        this.markers.length = 0;
        if (this.area != null) {
            this.area.setMap(null);
        }

        this._super(task, function(data) {

            // parse info to create a google map polygon
            var poly_js = data.table.rows[0][2];
            me.area = new GeoJSON(poly_js);

            // display polygon
            me.area.setOptions({strokeColor:"#FF0000",strokeWeight:"2", fillOpacity:0});
            me.area.setMap(me.map);

            // center the map to the polygon
            var bounds = me.area.getBounds();
            me.map.fitBounds(bounds);
        });
    },

// to generate automatically the google fusion table
    answers_schema:function() {
        var schema = [
            {"name":"user_id","type":"number"},
            // user_id required
            {"name":"task_id","type":"number"},
            // task_id required
            {"name":"annotation","type":"location"}
        ];
        return(schema);
    }
    ,
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
        // no annotation
        } else {
            rows.push({ area_id:this.task.area.id,task_id: this.task.id,annotation: " "});
        }
        $("#task_answer").val(JSON.stringify(rows));
    }
});