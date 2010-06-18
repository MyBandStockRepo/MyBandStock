jQuery(document).ready( function(){
		
		//LOAD THE SLIDESHOW
		theRotator();

		//AUTOCOMPLETE
		jQuery('#band_search_text').autocomplete('/pledged_bands.js',{ highlightItem: false});

		//LOGOUT FLASH NOTICE FADEOUT
		jQuery("#logout_flash_notice").fadeOut(1000);
	
		//SEARCH INPUT ONFOCUS CLEAR BOX, ENABLE SUBMIT BUTOTN  
		jQuery('#band_search_text').each(function() {
				var default_value = this.value;
				jQuery(this).focus(function() {
						jQuery('#band_search_text_button').removeAttr("disabled");
						if(this.value == default_value) {
								this.value = '';
						}
				});
		})
		
});
