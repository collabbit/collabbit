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
	
	$('#view-options').submit(function(){
		if($('#search').val() == init)
			$('#search').val('')
		return true;
	});

	$('#showallgroups').live("click",function(){
		$('.allgroups').toggleClass('hide');
		return false;
	});


	// for file uploading
	$('#multi').MultiFile({
		
	});
});
