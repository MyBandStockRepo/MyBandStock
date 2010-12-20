// just paste the following into the html to enable the bar
// <script src="http://www.mybandstock.com/javascripts/js_bar.js" type="text/javascript"></script>
// <div id="js-bar-container"><br class="clear" /></div>
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
            href: "/stylesheets/js_bar.css" 
        });
        css_link.appendTo('head');          

        /******* Load HTML *******/
        // check to see if there's a cookie set, if there is, ping the server to find the user, if not, render the login
        if (jQuery.cookie('_mbs')){
           var salt = jQuery.cookie("_mbs");
           var jsonp_url = "http://notorious.mybandstock.com/bands/1/shareholders.json?callback=?&salt=" + salt; 
           jQuery.getJSON(jsonp_url, function(data) {
           jQuery('#js-bar-container').append(data.html);
           });
         }else
          {
	       jQuery('#js-bar-container').append("<div class =\"bar-login\"><span class=\"email\">Email: <input id=\"user_email\" name=\"user[email]\" size=\"30\" type=\"text\" /></span></div><input id=\"user_submit\" name=\"commit\" type=\"submit\" value=\"SUBMIT\" />");
	      };
        // User submits their info(either email or password depending on what's being asked for)
        jQuery('#js-bar-container #user_submit').click(function() {
	        var email = jQuery('input#user_email').val();
	        var pass = jQuery('input#user_password').val();
	        var jsonp_url = "http://notorious.mybandstock.com/bands/1/shareholders.json?callback=?&email=" + email + "&password=" + pass;
	        jQuery.getJSON(jsonp_url, function(data) {
		      if (data.msg && data.msg != "delete"){ 
			    jQuery.cookie("_mbs", data.msg);
			    jQuery("#user_submit").remove();
		      };
		      if (data.msg && data.msg == "delete"){//if the user can't be found from the cookie, pass "delete" to js to set the cookie to null and reset the bar
			    jQuery.cookie("_mbs", null);
		       };
		      jQuery("div.bar-login, p.message").remove();
	          jQuery('#js-bar-container').append(data.html);
	        });
          });
         jQuery("span.logout").click(function() { //click the logout button
         	jQuery.cookie("_mbs", null); //kill the cookie
            jQuery.getJSON(jsonp_url, function(data) { //call the server to reset the bar
	          jQuery('#js-bar-container').append(data.html);
	        });
         });
         jQuery("#js-bar-container span.email").mouseenter( function() {
	      	jQuery(this).append("<div id=\"reward-box\">hello world</>");
	      }).mouseleave( function() {
	      	jQuery("div#box").remove();
	      });
      });
}

})();