jQuery(function(){
	
	// for filters
	var init = 'Search Keywords';

	if (jQuery('#search').val() == '') {
		jQuery('#search').val(init);
	}
	
	jQuery('#search').focus(function(){
		if(jQuery(this).val() == init)
			jQuery(this).val('').removeClass('blank');
	}).blur(function(){
		if(jQuery(this).val() == '')
			jQuery(this).val(init).addClass('blank');
	});
	
	jQuery('#view-options form').submit(function(){
		if(jQuery('#search').val() == init)
			jQuery('#search').val('')
		return true;
	});

	jQuery('#showallgroups').live("click",function(){
		jQuery('.allgroups').removeClass('hide');
		jQuery('#showallgroups').addClass('selected');
		jQuery('#showmygroups').removeClass('selected');
		return false;
	});

	jQuery('#showmygroups').live("click",function(){
		jQuery('.allgroups').addClass('hide');
		jQuery('.allgroups input:checkbox').attr('checked',false);
		jQuery('#showmygroups').addClass('selected');
		jQuery('#showallgroups').removeClass('selected');
		return false;
	});

	// for file uploading
	jQuery('#multi').MultiFile({
		
	});
});
