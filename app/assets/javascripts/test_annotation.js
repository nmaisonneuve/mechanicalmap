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

    init: function(scheduler_url) {

        this._super(scheduler_url);

        this.markers = [];
        this.rectangle = null;


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

    table_schema:function() {
        var schema = [
            {"name":"area_id","type":"number"},
            {"name":"user_id","type":"number"},
            {"name":"task_id","type":"number"},
            {"name":"annotation","type":"location"}
        ];
        return(schema);
    },

    load:function(task) {
        this._super(task);
        // clean markers
        for (var i = 0; i < this.markers.length; i++) {
            this.markers[i].setMap(null);
        }
        this.markers.length = 0;

        // draw rectangle
        var area = task.area;

        this.create_area(area.lat_sw, area.lng_sw, area.lat_ne, area.lng_ne);
    },

    create_area:function (lat_sw, lng_sw, lat_ne, lng_ne) {
        if (this.rectangle != null) this.rectangle.setMap(null);
        var bounds = new google.maps.LatLngBounds(
            new google.maps.LatLng(lat_sw, lng_sw),
            new google.maps.LatLng(lat_ne, lng_ne));

        map.fitBounds(bounds);

        this.rectangle = new google.maps.Rectangle({
            map: map,
            bounds:bounds,
            strokeColor:"#FF0000",
            strokeWeight:"2",
            fillOpacity:0
        });
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
    },
    no_task:function(){

    }
});
