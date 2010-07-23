/*
jQuery(function() {
  jQuery('.retweet-status-button').click(function(e) {
    var twBody = jQuery('.twtr-timeline');
    twBody.fadeTo(600, 0);
    twBody.parent().load('/twitter_api/retweet?band_id=1&latest=true&lightbox=true'); //, function() { alert('done'); jQuery(this).toggle(); });
    e.preventDefault();
    return false;
  });
});
*/
jQuery("#login_form").bind("submit", function() {
  alert('sub');
/*
	if (jQuery("#login_name").val().length < 1 || jQuery("#login_pass").val().length < 1) {
	    jQuery("#login_error").show();
	    jQuery.fancybox.resize();
	    return false;
	}

	jQuery.fancybox.showActivity();

	jQuery.ajax({
		type		: "POST",
		cache	: false,
		url		: "/data/login.php",
		data		: jQuery(this).serializeArray(),
		success: function(data) {
			jQuery.fancybox(data);
		}
	});
*/
	return false;
});
