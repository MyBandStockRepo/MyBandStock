jQuery.noConflict();

var mbsDomain = 'http://cobain.mybandstock.com';

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
    document.getElementById('mbs-redeem-link').href = mbsDomain +'/redeem_code/'+ document.getElementById('mbs-share-code').value;
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
			'hideOnOverlayClick': false,
			'onStart': function() {
			    jQuery('#fancybox-inner').html('aaaaaaaaaaaaaaa');
			  }
		});
    jQuery(this).click(function(e) {
      e.preventDefault(); return false;
    });
	});
}

function accessScheduleJsonCallback(data) {
  // Construct Access Schedule HTML from incoming JSON
  var html = jQuery(document.createElement('h1')).addClass('live-streams-title');
  html.html('Exclusive Live Streams');

  jQuery('#mbs-access-schedule-container').append(html);

  jQuery.each(data.serieses, function(seriesIndex, series) { // for each series
    var seriesTitle = jQuery(document.createElement('h2')).addClass('series-name');
    seriesTitle.html(series.series_title);

    var table = jQuery(document.createElement('table'));
    table.addClass('access-schedule-list');
    jQuery.each(series.streams, function(streamIndex, stream) {  // for each stream
      table.append(
        jQuery(document.createElement('tr')).append(
          jQuery('<td class="stream-start"></td>').html(
            jQuery('<span class="stream-start-day">'+ stream.start_day +'</span>')
          ).append(
            jQuery('<span class="stream-start-date">'+ stream.start_date +'</span>')
          ).append(
            jQuery('<span class="stream-start-time">'+ stream.start_time +'</span>')
          )
        ).append(
          jQuery(document.createElement('td')).addClass('stream-name').append(
            jQuery('<a href="'+ stream.view_link.url +'">'+ stream.title +'</a>')
              .addClass('lightbox stream-title')
              .attr('fbwidth', stream.view_link.width)
              .attr('fbheight', stream.view_link.height)
          )
        ).append(
          jQuery('<td class="stream-location">'+ stream.location +'</td>')
        ).addClass((streamIndex % 2) ? 'even' : 'odd')
      );
    });
    jQuery('#mbs-access-schedule-container').append(seriesTitle).append(table).append(
      jQuery('<div id="mbs-share-code-container"></div>').append(
        '<a href="'+ mbsDomain +'/redeem_code" class="lightbox" id="mbs-redeem-link"> </a>'
      ).append(
        '<label for="mbs-share-code">Enter access code:</label>' +
        '<input id="mbs-share-code" type="text">' +
        '<input id="mbs-redeem-submit" type="submit" value="Redeem">'
      )
    );
  });
  applyFbListeners();
  applyShareCodeListener();
}

