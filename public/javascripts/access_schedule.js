jQuery.noConflict();
var mbsDomain = 'http://localhost:3000';
var redeemDefaultText = 'Or Enter Your Share Code Here';


var script = document.createElement('script');
script.src = 'http://www.peekok.com/js/peekokLibrary.js';
script.type = 'text/javascript';
jQuery('head').append(script);

jQuery('head').append(
	jQuery('<link href="'+mbsDomain+'/stylesheets/access_schedule.css" media="screen" rel="stylesheet" type="text/css" />')
).append(
	jQuery('<link href="'+mbsDomain+'/stylesheets/lightbox.css" media="screen" rel="stylesheet" type="text/css" />')
);

jQuery(document).ready(function() {
  var accessScheduleContainer = document.getElementById('mbs-access-schedule-container');
  if (!accessScheduleContainer) {
    // This script was loaded from a viewer lightbox
    return;
  }
  var bandID = accessScheduleContainer.className;
  var start = bandID.indexOf('band=')+5, end = bandID.indexOf(' ', start);
  if (end == -1)
    end = bandID.length;
  bandID = bandID.substring(start, end);

  accessScheduleContainer.style.margin = '5px';
  //accessScheduleContainer.style.width = '500px';
  //accessScheduleContainer.style.height = '300px';
  accessScheduleContainer.style.padding = '0px 0px';
  accessScheduleContainer.style.position = 'relative';
  //accessScheduleContainer.style.borderTop = '4px solid #CCC';
  //accessScheduleContainer.style.borderLeft = '4px solid #CCC';
  //accessScheduleContainer.style.borderRight = '4px solid #444';
  //accessScheduleContainer.style.borderBottom = '4px solid #444';

  jQuery.getJSON(mbsDomain +'/live_stream_series/jsonp/'+ bandID +'/?jsoncallback=?', function(data){ });

});

jQuery(function() {
  applyFbListeners();
  applyShareCodeListener();
});

function applyShareCodeListener() {
  jQuery('#mbs-redeem-submit').click(function(e) {
    document.getElementById('mbs-redeem-link').href = mbsDomain +'/redeem_code/'+ escape(document.getElementById('mbs-share-code').value.replace(/\./g,"")) + '?lightbox=true';
    jQuery('#mbs-redeem-link').click();
  });
};

function applyFbListeners() {
	jQuery('.lightbox').each(function(index){
		jQuery(this).fancybox ({
			'transitionIn': 'fade',
			'transitionOut': 'fade',
			'overlayOpacity' : 0.6,
			'overlayColor' : 'black',      
			'type': 'iframe',
			'width': 880, //( (jQuery(this).attr('fbwidth') == null) ? 560 : parseInt(jQuery(this).attr('fbwidth')) ),
			'height': ( (jQuery(this).attr('fbheight') == null) ? 560 : parseInt(jQuery(this).attr('fbheight')) ),
			'autoScale': false,        // These two only work with
			'autoDimensions': true,   //  'ajax' (non-'iframe') types,
			'centerOnScroll': true,
			'hideOnOverlayClick': false
		});
    jQuery(this).click(function(e) {
      e.preventDefault(); return false;
    });
  });
}

function accessScheduleJsonCallback(data) {
  // Construct Access Schedule HTML from incoming JSON
  var title = jQuery(document.createElement('h1')).addClass('live-streams-title').html('Exclusive Live Streams');
  var redeemCodeSection =
        jQuery('<div id="mbs-share-code-container"></div>').append(
          '<a href="'+ mbsDomain +'/redeem_code" class="lightbox" id="mbs-redeem-link"> </a>'
        ).append(
          '<input id="mbs-share-code" type="text" value="'+ redeemDefaultText +'" onfocus="this.value = (this.value == redeemDefaultText) ? this.value=\'\' : this.value">' +
          '<input type="hidden" name="lightbox" value="true">' +
          '<input id="mbs-redeem-submit" type="submit" value="Redeem!">'
        )
  ;

  jQuery('#mbs-access-schedule-container').append(
    jQuery('<script type="text/javascript" src="http://www.peekok.com/jswidget/button/id/799">You must enable javascript in order to purchase</script>')
  ).append(
    jQuery('<a href="#" class="mbs-exclusive-access-banner" onclick="peekok_button_submit(799)"><img src="'+ mbsDomain + data.banner_image +'" /></a>')
  ).append(
    redeemCodeSection
  ).append(title);

  jQuery.each(data.serieses, function(seriesIndex, series) { // for each series
    var seriesTitle = jQuery(document.createElement('h2')).addClass('series-name');
    seriesTitle.html(series.series_title);

    var table = jQuery(document.createElement('table'));
    table.addClass('access-schedule-list');
    jQuery.each(series.streams, function(streamIndex, stream) {  // for each stream
      table.append(
        jQuery(document.createElement('tr')).append(
          //jQuery('<td class="stream-start"></td>').html(
          jQuery('<td class="stream-start-day">'+ stream.start_day +'</td>')
        ).append(
          jQuery('<td class="stream-start-date">'+ stream.start_date +'</span>')
        ).append(
          jQuery('<td class="stream-start-time">'+ stream.start_time +'</span>')
        ).append(
          jQuery(document.createElement('td')).addClass('stream-name').append(
            jQuery('<a href="'+ stream.view_link.url +'">'+ stream.title +'</a>')
              .addClass('lightbox stream-title')
              .attr('fbwidth', stream.view_link.width)
              .attr('fbheight', stream.view_link.height)
          )
        ).append(
          jQuery('<td class="stream-location">'+ stream.location +'</td>')
        ).addClass((streamIndex % 2) ? 'odd' : 'even')
      );
    });
    jQuery('#mbs-access-schedule-container').append(seriesTitle).append(table).append(
      jQuery('<a id="mbs-powered-by" href="'+ mbsDomain +'" title="mybandstock.com"> </a>')
    );
  });
  applyFbListeners();
  applyShareCodeListener();
}

