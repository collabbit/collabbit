$(function(){
	
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
	
	$('#view-options form').submit(function(){
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
		$('.allgroups input:checkbox').attr('checked',false)
		$('#showmygroups').addClass('selected');
		$('#showallgroups').removeClass('selected');
		return false;
	});

	// for file uploading
	$('#multi').MultiFile({
		
	});
});
