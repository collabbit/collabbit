$(function(){
	var init = 'Search Keywords';
	
	$('#search').val(init);
	
	$('#search').focus(function(){
		if($(this).val() == init)
			$(this).val('').removeClass('blank');
	}).blur(function(){
		if($(this).val() == '')
			$(this).val(init).addClass('blank');
	});
	
	$('#filter-bar').submit(function(){
		if($('#search').val() == init)
			$('#search').val('')
		return true;
	});
});