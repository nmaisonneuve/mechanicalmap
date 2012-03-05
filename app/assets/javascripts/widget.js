/**
 * Created by JetBrains RubyMine.
 * User: nico2
 * Date: 05.03.12
 * Time: 14:30
 * To change this template use File | Settings | File Templates.
 */


(function() {

// Localize jQuery variable
    var jQuery;

    /******** Load jQuery if not present *********/
    if (window.jQuery === undefined || window.jQuery.fn.jquery !== '1.7.0') {
        var script_tag = document.createElement('script');
        script_tag.setAttribute("type", "text/javascript");
        script_tag.setAttribute("src",
            "http://code.jquery.com/jquery-1.7.1.min.js");
        if (script_tag.readyState) {
            script_tag.onreadystatechange = function () { // For old versions of IE
                if (this.readyState == 'complete' || this.readyState == 'loaded') {
                    scriptLoadHandler();
                }
            };
        } else { // Other browsers
            script_tag.onload = scriptLoadHandler;
        }
        // Try to find the head, otherwise default to the documentElement
        (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(script_tag);
    } else {
        // The jQuery version on the window is the one we want to use
        jQuery = window.jQuery;
        main();
    }

    /******** Called once jQuery has loaded ******/
    function scriptLoadHandler() {
        // Restore $ and window.jQuery to their previous values and store the
        // new jQuery in our local jQuery variable
        jQuery = window.jQuery.noConflict(true);
        // Call our main function
        main();
    }

    /******** Our main function ********/
    function main() {
        jQuery(document).ready(function($) {
            $.getScript("http://maps.google.com/maps/api/js?sensor=false")
                .done(function(script, textStatus) {
                    $('#map_tasks').load('/projects/ajax/test.html', function() {
                        //init_map();
                    });
                    //console.log(textStatus);
                })
        });
    }

})(); // We call our anonymous function immediately