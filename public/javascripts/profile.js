var currentlyTweeting = false;

var mycarousel_buttonNextCallback = function(carousel, el, enable) { jQuery('#logo_float').append('Prev enable: ' + enable + '<br />'); };

jQuery(function() {
  if (currentlyTweeting) {
    jQuery('.retweet-status-button a').click();
    currentlyTweeting = false;
  }
  jQuery('.statuses_wrap').jcarousel({
    vertical: true,
    scroll:   1,
    animation: 800,
    initCallback: initializeViewMore,
    buttonNextCallback: function(c, el, enable) { jQuery('.socialshare_next').toggleClass('disabled', !enable); },
    buttonPrevCallback: function(c, el, enable) { jQuery('.socialshare_prev').toggleClass('disabled', !enable); },
    buttonNextHTML: '<span></span>',
    buttonPrevHTML: '<span></span>'
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

