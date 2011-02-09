// just paste the following into the html to enable the bar
// <script src="http://www.mybandstock.com/javascripts/js_bar.js" type="text/javascript"></script>
// <div id="js-bar-container" class="1234(this is the band id)"><br class="clear" /></div>
// our function starts on line 83, the rest is the cookie plugin and initialization for jquery

/* ///////// SET THE SOURCE URL /////////////// */
var secure_mbs_source_url;
//var mbs_source_url = "http://127.0.0.1:3000";
// var mbs_source_url = "http://mybandstock.com"; secure_mbs_source_url = 'https://mybandstock.com';
// var mbs_source_url = "http://localhost.me:3000";	/* specific to Jason */
//	var mbs_source_url = "http://localhost:3000";
var mbs_source_url = "http://notorious.mybandstock.com";

(function() {
	// Localize jQuery variable
	var jQuery;

  secure_mbs_source_url = (window.secure_mbs_source_url === undefined) ? mbs_source_url : secure_mbs_source_url;
	
	/******** Load jQuery if not present *********/
	if (window.jQuery === undefined || window.jQuery.fn.jquery !== '1.4.2') {
		var script_tag = document.createElement('script');
		script_tag.setAttribute("type","text/javascript");
		script_tag.setAttribute("src", "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js");
	  script_tag.onload = scriptLoadHandler;
		script_tag.onreadystatechange = function () { // Same thing but for IE
			if (this.readyState == 'complete' || this.readyState == 'loaded') {
				scriptLoadHandler();
			}
		};	
		// Try to find the head, otherwise default to the documentElement
		(document.getElementsByTagName("head")[0] || document.documentElement).appendChild(script_tag);
	} else {
		// The jQuery version on the window is the one we want to use
		jQuery = window.jQuery;
		main();
	}

	/******** Called once jQuery has loaded ******/
	function scriptLoadHandler() {
    // Restore $ and window.jQuery to their previous values and store the
    // new jQuery in our local jQuery variable
    jQuery = window.jQuery.noConflict(true);
    // Call our main function
    main(); 
	}

	/****cookie plugin*****/
	function main() { 
		jQuery.cookie = function(name, value, options) 
		{
		  if (typeof value != 'undefined') 
			{ // name and value given, set cookie
				options = options || {};
				if (value === null) {
					value = '';
					options.expires = -1;
				}
				var expires = '';
				if (options.expires && (typeof options.expires == 'number' || options.expires.toUTCString)) 
				{
					var date;
					if (typeof options.expires == 'number') {
						date = new Date();
						date.setTime(date.getTime() + (options.expires * 24 * 60 * 60 * 1000));
					} else {
						date = options.expires;
					}
					expires = '; expires=' + date.toUTCString(); // use expires attribute, max-age is not supported by IE
				}
				// CAUTION: Needed to parenthesize options.path and options.domain
				// in the following expressions, otherwise they evaluate to undefined
				// in the packed version for some reason...
				var path = options.path ? '; path=' + (options.path) : '';
				var domain = options.domain ? '; domain=' + (options.domain) : '';
				var secure = options.secure ? '; secure' : '';
				document.cookie = [name, '=', encodeURIComponent(value), expires, path, domain, secure].join('');
			} else { // only name given, get cookie
				var cookieValue = null;
				if (document.cookie && document.cookie != '') 
				{
					var cookies = document.cookie.split(';');
					for (var i = 0; i < cookies.length; i++) {
						var cookie = jQuery.trim(cookies[i]);
						// Does this cookie string begin with the name we want?
						if (cookie.substring(0, name.length + 1) == (name + '=')) {
							cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
							break;
						}
					}
				}
				return cookieValue;
			}
		};	// end jQuery.cookie = function



		/********************main function***************/ 	
		jQuery(document).ready(function($) 
		{ 
			/******* Load CSS *******/
			var fonts_css_link = jQuery("<link>", { 
				rel: "stylesheet", 
				type: "text/css", 
				href: mbs_source_url+"/stylesheets/fonts.css"
			});


			var css_link = jQuery("<link>", { 
				rel: "stylesheet", 
				type: "text/css", 
				href: mbs_source_url+"/stylesheets/js_bar.css"
			});
        

			css_link.appendTo('head');   
			fonts_css_link.appendTo('head');
			var band_id = mybandstockArtistID;
            var url_host = secure_mbs_source_url+"/bands/"; // AJAX requests with user secrets should be send over the secure URL.
    
			// Build the bar
			var current_url = window.location.href.replace("undefined", "");

			// Initial Bar State
			var mbs_initial_bar_state = "<div class=\"mbs-bar-branding\"></div><div class=\"mbs-bar-login-wrapper\"><div class=\"mbs-bar-login\"><span class=\"mbs-email\">Email: <input id=\"mbs_user_email\" name=\"user[email]\" size=\"30\" type=\"text\" /></span></div><div class=\"clear\"></div><input id=\"mbs_user_submit\" name=\"commit\" type=\"submit\" value=\"Submit\" /><span class=\"mbs-cancel-this\" style=\"display:none;\"><a href=\""+ current_url +"\" title=\"cancel\">cancel</a></span></div><div class=\"mbs-bar-instructions\">Start earning rewards today!<br />Enter an email address to login or sign-up.</div>";

		
			/******* Load HTML *******/
			// make space on the website so our bar doesn't cover existing content
			var mybandstock_bar_spacer = jQuery(document.createElement('div')).addClass('mybandstock_bar_spacer');
			jQuery('body').append(mybandstock_bar_spacer);			
			jQuery('body').append("<div id='js-bar-container'></div>");
			
			// make notification box
			jQuery('body').append('<div id="mbs-bar-message-box" class="mbs-alpha80" style="display:none;"><span id="mbs-bar-notification"></span><a id=\"mbs-bar-close-notifications\">X</a></div>');
						
			// Rewards buttons
			var rewards_buttons = "<div class=\"mbs-points-containers\"><span class=\"mbs-earn-points\"><a id=\"mbs-ways-to-earn-link\" onClick=\"mybandstockToggleWaysToEarn()\">Get Bandstock</a></span><span class=\"mbs-rewards\"><a id=\"mbs-rewards-link\" onClick=\"mybandstockToggleRewardsDiv()\">View Levels</a></span></div>";
						
			// check to see if there's a cookie set, if there is, ping the server to find the user, if not, render the login
			if (jQuery.cookie('_mbs'))
			{ 
				var salt = jQuery.cookie("_mbs");
				var jsonp_url = url_host + band_id + "/shareholders.json?callback=?&salt=" + salt;
				jQuery.getJSON(jsonp_url, function(data) { // send the params to the app and append the response to the main container
					jQuery('#js-bar-container').html(data.html);
					jQuery('#js-bar-container').append(rewards_buttons);
					jQuery('#js-bar-container').append("<div class=\"mbs-bar-login-wrapper\"><span class=\"mbs-logout-link\"><a onClick=\"mybandstock_log_user_out()\"> Logout</a></span></div>");					
				});
			} else {
				//login stuff
				jQuery('#js-bar-container').html(mbs_initial_bar_state);
		  }
	   		
	  	// Listeners
			jQuery('#mbs-bar-close-notifications').click(function() {
				jQuery('#mbs-bar-message-box').hide();
				return false;
			});
	
			jQuery('#js-bar-container .mbs-cancel-this').click(function() {
				jQuery(this).hide();
				jQuery('.mbs-user-form').remove();				
				jQuery('.mbs-bar-login').html("<span class=\"mbs-email\">Email: <input id=\"mbs_user_email\" name=\"user[email]\" size=\"30\" type=\"text\" /></span>");				
				return false;
			});
			
			// User submits their info(either email or password depending on what's being asked for)
			jQuery('#js-bar-container #mbs_user_submit').click(function() {
                var first_name = jQuery('#js-bar-container input#mbs_user_first_name').val();
				var email = jQuery('#js-bar-container input#mbs_user_email').val(); //capture the email entered
                var email_confirmation = jQuery('#js-bar-container input#mbs_user_email_confirmation').val();//capture the email entered if new user
                var pass = jQuery('#js-bar-container input#mbs_user_password').val(); //capture the password entered
                jQuery("js-bar-container").html("<h1>Loading...</h1>");
				if(email_confirmation != null)
					email_confirmation = email_confirmation.replace("+", "%2B");
				if(email != null)
					email = email.replace("+", "%2B");
			    var jsonp_url = url_host + band_id + "/shareholders.json?callback=?&email=" + email + "&password=" + pass + "&email_confirmation=" + email_confirmation + "&first_name=" + first_name; //pass those params to the query string
                if (typeof data != 'undefined' && data.msg && data.msg == "create-new-user"){
	              var jsonp_url = jsonp_url.replace("undefined", "");
                 }

				jQuery.getJSON(jsonp_url, function(data) {
					// show user notification if there is one
				  mybandstockDisplayUserNotification(data.notification);
					
					// BAR STATES
					// Log the user in
	      	      if (data.msg && data.msg != "delete" && data.msg != "need-password" && data.msg != "create-new-user" && data.msg != "user-error"){ //if the app sent a message that is not delete, we set a cookie, log in the user and remove the submit button
		    		jQuery.cookie("_mbs", data.msg);	// sets their session cookie
					jQuery('#js-bar-container').html(data.html);						
					jQuery('#js-bar-container').append(rewards_buttons);
					jQuery('#js-bar-container').append("<div class=\"mbs-bar-login-wrapper\"><span class=\"mbs-logout-link\"><a onClick=\"mybandstock_log_user_out()\"> Logout</a></span></div>");											
	      	       }
					// Need to delete user cookie
	      	       else if (data.msg && data.msg == "delete"){//if the app sent a message of 'delete'(the user couldn't be found from the cookie info), we reset the cookie
		    		jQuery.cookie("_mbs", null);
						//re-do login
					jQuery('#js-bar-container').html(mbs_initial_bar_state);
	       	       }
					// Either wrong password, or need to put in password for the first time
	      	       else if (data.msg && data.msg == "need-password"){
		    		jQuery("span.mbs-cancel-this").show();
					jQuery('.mbs-bar-login').html(data.html);
                   }
					// Need to create a new user
					else if (data.msg && data.msg == "create-new-user"){
						jQuery('.mbs-bar-login').html("");
						jQuery('.mbs-cancel-this').show();
						jQuery('#js-bar-container').append(data.html);
					}
					// Some sort of error
					else if(data.msg && data.msg == "user-error"){
						jQuery('#js-bar-container').html(mbs_initial_bar_state);
						jQuery('.mbs-user-form').remove();				
					}
					else{
						jQuery('#js-bar-container').html(data.html);
					}					
				});
			});
		}); // end doc.ready
	}
})();

// Show/hide rewards
function mybandstockToggleRewardsDiv(){
	jQuery('div#mbs-rewards').toggle();
	if(jQuery('#mbs-rewards-link').html() == "View Levels")
	{
		jQuery('#mbs-rewards-link').html("Hide Levels");
	}
	else
	{
		jQuery('#mbs-rewards-link').html("View Levels");					
	}				
	return;
}

// Show/hide ways to earn
function mybandstockToggleWaysToEarn(){
	jQuery('div#mbs-ways-to-earn').toggle();
	return;
}

/******** Display a notification to the user ****/
function mybandstockDisplayUserNotification(notification)
{
	if (notification != "" && notification != null){	// if a user should be presented with a notification
		jQuery('#mbs-bar-notification').html(""+notification);
		jQuery('#mbs-bar-message-box').show();
	}
	return;
}

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

//log out user
function mybandstock_log_user_out()
{
	var email = null
	var email_confirmation = null
	var first_name = null
	var pass = null
	var salt = null
	var jsonp_url = mbs_source_url + '/login/logout.json?callback=?';
	jQuery.cookie("_mbs", null); //kill the cookie
	jQuery('#js-bar-container').html("");
	mybandstockDisplayUserNotification('Logged out.');
	jQuery.ajax({
	  url: jsonp_url,
	  dataType: 'json',
	  async: false,
	});
	window.location.reload();
}

function mybandstockShowProgressTooltip()
{
	jQuery('.mbs-level-progress-tooltip').show()
}
function mybandstockHideProgressTooltip()
{
	jQuery('.mbs-level-progress-tooltip').hide()	
}
