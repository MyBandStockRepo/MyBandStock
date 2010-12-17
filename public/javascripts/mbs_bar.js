// Make sure jQuery is installed
jQuery.noConflict();

// Set variables
//var mybandstock_bar_css_location = 'http://127.0.0.1:3000/stylesheets/mbs_bar.css';
//var mybandstock_bar_root_url = 'http://127.0.0.1:3000'
var mybandstock_bar_css_location = 'http://mybandstock.com/stylesheets/mbs_bar.css';
var mybandstock_bar_root_url = 'http://mybandstock.com'

// import mbs bar css
jQuery('head').append(
	jQuery('<link href="'+mybandstock_bar_css_location+'" media="screen" rel="stylesheet" type="text/css" />')
);

// Open the popup
function mybandstock_bar_popup_window_link(link_location,name,height,width)
{
	options = 'status=yes,location=no,scrollbars=yes,toolbar=no,directories=no,menubar=no';
	height_offset = 0;
	width_offset = 0;
	if (width != null)
	{
		options += ",width="+width;
		width_offset = width / 2;
	}
	if (height != null)
	{
		options += ",height="+height;
		height_offset = height / 2;
	}
	mywindow = window.open(link_location,name,options);
	mywindow.moveTo(screen.width/2-width_offset,screen.height/2-height_offset)	
	return true
}

// insert the bar
jQuery(document).ready(function() {
	// make space on the website so our bar doesn't cover existing content
	var mybandstock_bar_spacer = jQuery(document.createElement('div')).addClass('mybandstock_bar_spacer');
	jQuery('body').append(mybandstock_bar_spacer);
	// put the bar
	var mybandstock_bar = jQuery(document.createElement('div')).attr('id', 'mybandstock_bar').append(
			jQuery(document.createElement('div')).attr('id', 'bar_branding')
		).append(
			jQuery(document.createElement('div')).addClass('mybandstock_registration').append(
				jQuery(document.createElement('img')).attr('src', mybandstock_bar_root_url+'/images/bar/facebook.png').attr('id', 'mybandstock_bar_facebook_registration_link').addClass('mybandstock_bar_facebook_registration_link').append("Facebook Registration")
			).append(
				jQuery(document.createElement('div')).addClass('mybandstock_clear')
			).append(		
				jQuery(document.createElement('a')).attr('id', 'mybandstock_bar_manual_registration_link').addClass('mybandstock_bar_manual_registration_link').append("Manually Register")			
			)
		).append(
			jQuery(document.createElement('div')).addClass('mybandstock_bar_copy').append("Sign up to start earning BandStock towards rewards!")		
		).append(
			//quantcast
			jQuery('<script type="text/javascript">_qoptions={qacct:"p-f0h8i9mIAp1XU"};</script>')
		).append(
			jQuery('<script type="text/javascript" src="http://edge.quantserve.com/quant.js"></script>')
	);
	jQuery('body').append(mybandstock_bar);	
	
	
	// on click listeners for links (makes it so chrome doesn't put the status bar over the bar)
	jQuery('#mybandstock_bar_manual_registration_link').click(function () {
			mybandstock_bar_popup_window_link(mybandstock_bar_root_url+'/external/registration?band_id='+mybandstock_bar_bandID, "Registration", 500, 620);
		});
	jQuery('#mybandstock_bar_facebook_registration_link').click(function () {
			mybandstock_bar_popup_window_link(mybandstock_bar_root_url+'/external/registration?band_id='+mybandstock_bar_bandID+'&mode=facebook', "Registration", 569, 995);
		});	
});




