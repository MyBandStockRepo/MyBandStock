var currentlyTweeting = false;
jQuery(function() {
/*  alert(#{@currently_tweeting});
  // Parse location to identify currently_tweeting GET or anchor variable
  var currentlyTweeting, temp = 'currently_tweeting'
  currenltyTweeting = temp.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&#]"+currenltyTweeting; //+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    currentlyTweeting = false;
  else
    currentlyTweeting = true;
*/
  if (currentlyTweeting) {
    jQuery('.retweet-status-button a').click();
    document.location.href = document.location.href.replase('currently_tweeting', '');
    currentlyTweeting = false;
  }
});

