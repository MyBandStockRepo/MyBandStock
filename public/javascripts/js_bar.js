// just paste the following into the html to enable the bar
// <script src="http://www.mybandstock.com/javascripts/js_bar.js" type="text/javascript"></script>
// <div id="js-bar-container" class="1234(this is the band id)"><br class="clear" /></div>
// our function starts on line 83, the rest is the cookie plugin and initialization for jquery
(function() {

// Localize jQuery variable
var jQuery;

/******** Load jQuery if not present *********/
if (window.jQuery === undefined || window.jQuery.fn.jquery !== '1.4.2') {
    var script_tag = document.createElement('script');
    script_tag.setAttribute("type","text/javascript");
    script_tag.setAttribute("src",
        "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js");
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
	jQuery.cookie = function(name, value, options) {
	    if (typeof value != 'undefined') { // name and value given, set cookie
	        options = options || {};
	        if (value === null) {
	            value = '';
	            options.expires = -1;
	        }
	        var expires = '';
	        if (options.expires && (typeof options.expires == 'number' || options.expires.toUTCString)) {
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
	        if (document.cookie && document.cookie != '') {
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
	};

/********************main function***************/ 
    jQuery(document).ready(function($) { 
        /******* Load CSS *******/
        var css_link = $("<link>", { 
            rel: "stylesheet", 
            type: "text/css", 
            href: "http://notorious.mybandstock.com/stylesheets/js_bar.css" 
        });
        css_link.appendTo('head');          
        var band_id = jQuery('#js-bar-container').attr('class'); // get the band id from the class attribute
        var url_host = "http://notorious.mybandstock.com/bands/"
        /******* Load HTML *******/
        // check to see if there's a cookie set, if there is, ping the server to find the user, if not, render the login
        if (jQuery.cookie('_mbs')){ 
           var salt = jQuery.cookie("_mbs");
           var current_url = window.location.href.replace("undefined", "");
           var jsonp_url = url_host + band_id + "/shareholders.json?callback=?&salt=" + salt; 
           jQuery('#js-bar-container').remove('span.logout-link');
		   jQuery('#js-bar-container').append("<span class=\"logout-link\"><a href=\"" + current_url + "\"> logout</a></span></span><span class=\"rewards\"><a href=\"#\">View Rewards</a></span>");
		   jQuery.getJSON(jsonp_url, function(data) { // send the params to the app and append the response to the main container
           jQuery('#js-bar-container').append(data.html);
           jQuery('span.cancel').css("display","none");
		   jQuery('span.rewards').fadeIn("fast");
           });
         }else
          {
	       jQuery('#js-bar-container').append("<span class=\"logout-link\"><a href=\"" + current_url + "\"> logout</a></span><span class=\"rewards\"><a href=\"#\">View Rewards</a></span>");
	       jQuery('#js-bar-container').append("<div class =\"bar-login\"><span class=\"email\">Email: <input id=\"user_email\" name=\"user[email]\" size=\"30\" type=\"text\" /></span></div><input id=\"user_submit\" name=\"commit\" type=\"submit\" value=\"POW!\" /><span class=\"cancel-this\"><a href=\"http://localhost.me:3000\" title=\"cancel\">cancel</a></span>");
	       jQuery('span.logout-link, span.rewards').css("display","none");
		  };
	   	  jQuery('#js-bar-container .cancel-this').click(function() {
		    jQuery(this).hide("fast");
		    jQuery('div.bar-login').remove();
		    jQuery('p.message, div.user-form').remove();
	   	    jQuery('#js-bar-container').append("<div class =\"bar-login\"><span class=\"email\">Email: <input id=\"user_email\" name=\"user[email]\" size=\"30\" type=\"text\" /></span></div>");
	        return false;
	      });
	      jQuery('span.rewards').click(function() {
	      	jQuery('div#rewards').toggle("fast");
	        return false;
	      })
	       jQuery('body').not('span.rewards').not('div#rewards').click(function() {
	       	jQuery('div#rewards').hide("fast");
	       })
	      jQuery('#js-bar-container span.logout-link a').click(function() { //click the logout button
         	var email = null
			var email_confirmation = null
			var first_name = null
			var pass = null
			var salt = null
			jQuery.cookie("_mbs", null); //kill the cookie
            jQuery.getJSON(jsonp_url, function(data) { //call the server to reset the bar
	          jQuery('#js-bar-container').append(data.html);
	        });
           });
        // User submits their info(either email or password depending on what's being asked for)
        jQuery('#js-bar-container #user_submit').click(function() {
	        var first_name = jQuery('input#user_first_name').val();
			var email = jQuery('input#user_email').val(); //capture the email entered
	        var email_confirmation = jQuery('input#user_email_confirmation').val();//capture the email entered if new user
	        var pass = jQuery('input#user_password').val(); //capture the password entered
	        var jsonp_url = url_host + band_id + "/shareholders.json?callback=?&email=" + email + "&password=" + pass + "&email_confirmation=" + email_confirmation + "&first_name=" + first_name; //pass those params to the query string
	        jQuery.getJSON(jsonp_url, function(data) {
		      if (data.msg && data.msg != "delete" && data.msg != "need-password"){ //if the app sent a message that is not delete, we set a cookie, log in the user and remove the submit button
			    jQuery.cookie("_mbs", data.msg);
			    jQuery('span.cancel-this, #user_submit, div.user-form').remove();
	            jQuery('span.logout-link, span.rewards').show('fast');
		      };
		      if (data.msg && data.msg == "delete" && data.msg != "need-password"){//if the app sent a message of 'delete'(the user couldn't be found from the cookie info), we reset the cookie
			    jQuery.cookie("_mbs", null);
		       };
		      if (data.msg && data.msg == "need-password"){
			    jQuery("span.cancel").show("fast");
	           };
		      jQuery("div.bar-login, p.message").remove();
	          jQuery('#js-bar-container').append(data.html);
	          if (data.msg && data.msg == 'need password'){
		        jQuery('span.cancel').css('display', 'inline');
			  };
	        });
          });
       

         // jQuery("#js-bar-container span.email").mouseenter( function() {
         // 	      	jQuery(this).append("<div id=\"reward-box\">hello world</>");
         // 	      }).mouseleave( function() {
         // 	      	jQuery("div#box").remove();
         // 	      });
      });
}

})();