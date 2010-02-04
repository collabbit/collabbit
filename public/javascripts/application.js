jQuery.noConflict();

jQuery(document).ready(function() {          
    jQuery('#incidents-li').hover(
        function() {
            var height = jQuery('#incidents-li').height();
            var pos = jQuery('#incidents-li').offset();
            jQuery("#incidents-menu").css({ 
                "left": (pos.left-10)+"px",
                "top":(pos.top+height+2)+"px"
            });
            jQuery('#incidents-menu').show();
        },
        function() {jQuery('#incidents-menu').hide();
    });
});
