var currentlyTweeting = false;

jQuery(function() {
  if (currentlyTweeting) {
    jQuery('.retweet-status-button a').click();
    document.location.href = document.location.href.replase('currently_tweeting', '');
    currentlyTweeting = false;
  }
});

