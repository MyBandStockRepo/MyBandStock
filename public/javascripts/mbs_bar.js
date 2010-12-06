function mybandstock_bar_popup_window_link(link_location,name,width,height)
{
	options = "status=1,scrollbars=1";
	if (width != null)
		options += ",width="+width;
	if (height != null)
		options += ",height="+height;
	mywindow = window.open(link_location,name,options);
//	mywindow.moveTo(0,0);
	return true
}

jQuery.noConflict();
var mybandstock_bar_css_location = 'http://127.0.0.1:3000/stylesheets/mbs_bar.css';
var mybandstock_bar_root_url = 'http://127.0.0.1:3000'
var mybandstock_bar_bandID = 2;

// import mbs bar css
jQuery('head').append(
	jQuery('<link href="'+mybandstock_bar_css_location+'" media="screen" rel="stylesheet" type="text/css" />')
);

jQuery(document).ready(function() {
	// make space on the website so our bar doesn't cover existing content
	var mybandstock_bar_spacer = jQuery(document.createElement('div')).addClass('mybandstock_bar_spacer');
	jQuery('body').append(mybandstock_bar_spacer);
	// put the bar
	var mybandstock_bar = jQuery(document.createElement('div')).attr('id', 'mybandstock_bar').append(
		jQuery(document.createElement('div')).addClass('mybandstock_registration').append(
			jQuery(document.createElement('a')).addClass('mybandstock_bar_manual_registration_link').click(mybandstock_bar_popup_window_link(mybandstock_bar_root_url+'/external/registration?band_id='+mybandstock_bar_bandID)).append("Manual Registration")
		).append(
			jQuery(document.createElement('a')).addClass('mybandstock_bar_facebook_registration_link').click(mybandstock_bar_popup_window_link(mybandstock_bar_root_url+'/external/registration?band_id='+mybandstock_bar_bandID+'&mode=facebook')).append("Facebook Registration")
		)
	);
	jQuery('body').append(mybandstock_bar);
});


