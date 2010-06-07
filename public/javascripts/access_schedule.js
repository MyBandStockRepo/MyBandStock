jQuery.noConflict();

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

  accessScheduleContainer.style.margin = '1em';
  //accessScheduleContainer.style.width = '500px';
  //accessScheduleContainer.style.height = '300px';
  accessScheduleContainer.style.padding = '0px 0px';
  accessScheduleContainer.style.position = 'relative';
  //accessScheduleContainer.style.borderTop = '4px solid #CCC';
  //accessScheduleContainer.style.borderLeft = '4px solid #CCC';
  //accessScheduleContainer.style.borderRight = '4px solid #444';
  //accessScheduleContainer.style.borderBottom = '4px solid #444';

  jQuery.getJSON('http://cobain.mybandstock.com/live_stream_series/jsonp/'+ bandID +'/?jsoncallback=?', function(data){ });

});


jQuery(function() {
  applyFbListeners();
});

function applyFbListeners() {
	jQuery('a.lightbox').each(function(index){
		jQuery(this).fancybox ({
			'transitionIn': 'fade',
			'transitionOut': 'fade',
			'overlayOpacity' : 0.6,
			'overlayColor' : 'black',      
			'type': 'iframe',
			'width': ( (jQuery(this).attr('fbwidth') == null) ? 560 : parseInt(jQuery(this).attr('fbwidth')) ),
			'height': ( (jQuery(this).attr('fbheight') == null) ? 560 : parseInt(jQuery(this).attr('fbheight')) ),
			'autoScale': false,        // These two only work with
			'autoDimensions': true,   //  'ajax' (non-'iframe') types,
			'centerOnScroll': true,
			'hideOnOverlayClick': false
		});
    jQuery(this).click(function(e) { e.preventDefault(); });
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
          jQuery(document.createElement('td')).addClass('stream-name').append(
            jQuery('<a href="'+ stream.view_link.url +'">'+ stream.title +'</a>')
              .addClass('lightbox stream-title')
              .attr('fbwidth', stream.view_link.width)
              .attr('fbheight', stream.view_link.height)
          )
        )
      );
    });
    jQuery('#mbs-access-schedule-container').append(seriesTitle).append(table);
  });
  applyFbListeners();
}

