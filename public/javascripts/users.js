$(function(){
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

	// for alert menu
	var upArrow = '&#9650;'
	var downArrow = '&#9660;'

	$('#alerts-toggle').live("click",function(){
		if ($('#alerts-individual').hasClass('hidden')) {
			$('#alerts-individual').removeClass('hidden');
			$('#alerts-toggle .arrow').html(upArrow);
		} else {
			$('#alerts-individual').addClass('hidden');
			$('#alerts-toggle .arrow').html(downArrow);
		}
		return false;
	});

	// enable/disable single feed checkboxes based on master settings
	$('#user_text_alert').live("click", function() {
		if (this.checked) {
			$('.feed-text-setting input').removeAttr('disabled');
		} else {
			$('.feed-text-setting input').attr('disabled','disabled');
		}
	});
	$('#user_email_alert').live("click", function() {
		if (this.checked) {
			$('.feed-email-setting input').removeAttr('disabled');
		} else {
			$('.feed-email-setting input').attr('disabled','disabled');
		}
	});
});
