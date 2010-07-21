// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery(function() {
	var selection = jQuery('#to_field').val();
	if (selection == 'lss')
  	{
		jQuery('#band_field').hide();
		jQuery('#lss_field').show();			
  	}
  	else if (selection == 'band')
  	{
        jQuery('#lss_field').hide();		
		jQuery('#band_field').show();		
  	}	
  	else if (selection == 'bandtop10')
  	{			
        jQuery('#lss_field').hide();	
		jQuery('#band_field').show();		
  	}
  	else
  	{
		jQuery('#lss_field').hide();			
		jQuery('#band_field').hide();
	}
	
	
	jQuery('#to_field').change(function() {
	  	var selection = jQuery('#to_field').val();
	  	if (selection == 'lss')
	  	{
			jQuery('#band_field').fadeOut();
			jQuery('#lss_field').fadeIn();			
	  	}
      	else if (selection == 'band')
	  	{
	        jQuery('#lss_field').fadeOut();		
			jQuery('#band_field').fadeIn();		
	  	}	
	  	else if (selection == 'bandtop10')
	  	{			
	        jQuery('#lss_field').fadeOut();	
			jQuery('#band_field').fadeIn();		
	  	}
	  	else
	  	{
			jQuery('#lss_field').fadeOut();			
			jQuery('#band_field').fadeOut();
		}
	});
});