$(document).ready(function() {          
    $('#incidents-li').hover(
        function() {
            var height = $('#incidents-li').height();
            var pos = $('#incidents-li').offset();
            $("#incidents-menu").css({ 
                "left": (pos.left-10)+"px",
                "top":(pos.top+height+2)+"px"
            });
            $('#incidents-menu').show();
        },
        function() {$('#incidents-menu').hide();
    });

});
