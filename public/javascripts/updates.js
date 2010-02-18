$.noConflict();
jQuery(document).ready(function($){
    
    var commentInitial = 'Add a comment here';
    
    function focusComment($frm){
        $txt = $frm.find('.comment-textfield');
        if($txt.val() != commentInitial) return;
        $txt.val('').removeClass('blank');
        $frm.find('.comment-submit').show();
    }
    
    function unfocusComment($frm){
        $txt = $frm.find('.comment-textfield');
        if($txt.val() != '') return;
        $txt.val(commentInitial).addClass('blank');
        $frm.find('.comment-submit').hide();
    }
    
    $('.new_comment').each(function(){
        var $frm = $(this);
        $(this).find('.comment-textfield').focus(function(){  focusComment($frm) })
                                          .blur(function(){ unfocusComment($frm) });
               
        unfocusComment($(this));
    });
	
	// for filters
	var init = 'Search Keywords';

	if ($('#search').val() == '') {
		$('#search').val(init);
	}
	
	$('#search').focus(function(){
		if($(this).val() == init)
			$(this).val('').removeClass('blank');
	}).blur(function(){
		if($(this).val() == '')
			$(this).val(init).addClass('blank');
	});
	
	$('#filters form').submit(function(){
		if($('#search').val() == init)
			$('#search').val('')
		return true;
	});

	$('#showallgroups').live("click",function(){
		$('.allgroups').removeClass('hide');
		$('#showallgroups').addClass('selected');
		$('#showmygroups').removeClass('selected');
		return false;
	});

	$('#showmygroups').live("click",function(){
		$('.allgroups').addClass('hide');
		$('.allgroups input:checkbox').attr('checked',false);
		$('#showmygroups').addClass('selected');
		$('#showallgroups').removeClass('selected');
		return false;
	});

	// for file uploading
	$('#multi').MultiFile({
		
	});
});
