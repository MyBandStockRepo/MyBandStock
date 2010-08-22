var currentlyTweeting = false;

jQuery(function() {
  if (currentlyTweeting) {
    jQuery('.retweet-status-button a').click();
    currentlyTweeting = false;
  }
  jQuery('.statuses_wrap').jcarousel({
    vertical: true,
    scroll:   1,
    animation: 'fast',
    initCallback: initializeViewMore,
    buttonNextHTML:   null,
    buittonPrevHTML:  null
  })
});





function initializeViewMore(carousel) {
  jQuery('.socialshare_next').bind('click', function() {
    carousel.next();
    return false;
  });

  jQuery('.socialshare_prev').bind('click', function() {
    carousel.prev();
    return false;
  });
};

