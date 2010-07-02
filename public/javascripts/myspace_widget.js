jQuery.noConflict();
var mbsDomain = 'http://localhost:3000';
var redeemDefaultText = 'Or Enter Your Share Code Here';


jQuery('head').append(
	jQuery('<link href="'+mbsDomain+'/stylesheets/fonts.css" media="screen" rel="stylesheet" type="text/css" />')
).append(
	jQuery('<link href="'+mbsDomain+'/stylesheets/myspace_widget.css" media="screen" rel="stylesheet" type="text/css" />')
);

jQuery(document).ready(function() {
  var accessScheduleContainer = document.getElementById('mbs-access-schedule-container');
  if (!accessScheduleContainer)
    return;
  var bandID = accessScheduleContainer.className;
  var start = bandID.indexOf('band=')+5, end = bandID.indexOf(' ', start);
  if (end == -1)
    end = bandID.length;
  bandID = bandID.substring(start, end);

  // accessScheduleContainer.style.margin = '5px';
  // accessScheduleContainer.style.height = '300px';
  accessScheduleContainer.style.padding = '0px 0px';
  accessScheduleContainer.style.position = 'relative';
  // accessScheduleContainer.style.borderTop = '4px solid #CCC';
  // accessScheduleContainer.style.borderLeft = '4px solid #CCC';
  // accessScheduleContainer.style.borderRight = '4px solid #444';
  // accessScheduleContainer.style.borderBottom = '4px solid #444';

  jQuery.getJSON(mbsDomain +'/live_stream_series/jsonp/'+ bandID +'/?jsoncallback=?', function(data){ });

  applyShareCodeListener();
});

function applyShareCodeListener() {
  return;
  jQuery('#mbs-redeem-submit').click(function(e) {
    document.getElementById('mbs-redeem-link').href = mbsDomain +'/redeem_code/'+ escape(document.getElementById('mbs-share-code').value.replace(/\./g,""));
    jQuery('#mbs-redeem-link').click();
  });
};

function accessScheduleJsonCallback(data) {
  // Construct Access Schedule HTML from incoming JSON
  var title = jQuery(document.createElement('h1')).addClass('live-streams-title').html('Exclusive Live Streams');
  var redeemCodeSection =
        jQuery('<div id="mbs-share-code-container"></div>').append(
          '<a href="'+ mbsDomain +'/redeem_code" class="lightbox" id="mbs-redeem-link"> </a>'
        ).append(
          jQuery(
            '<form></form>'
          )
          .append(
            '<input id="mbs-share-code" type="text" value="'+ redeemDefaultText +'" onfocus="this.value = (this.value == redeemDefaultText) ? this.value=\'\' : this.value">' +
            '<input id="mbs-redeem-submit" type="submit" value="Redeem!">'
          )
        )
  ;

  jQuery('#mbs-access-schedule-container').append(
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
          jQuery('<td class="stream-start-day">'+ stream.start_day +'</td>')
        ).append(
          jQuery('<td class="stream-start-date">'+ stream.start_date +'</span>')
        ).append(
          jQuery('<td class="stream-start-time">'+ stream.start_time +'</span>')
        ).append(
          jQuery(document.createElement('td')).addClass('stream-name').append(
            jQuery('<a \
                      href="'+ stream.view_link.url +'" \
                      class="'+ ((stream.past) ? 'mbs-past' : '') +'" \
                      title="'+ ((stream.past) ? 'Stream has ended. Click the title to see recorded show.' : stream.title ) +'" \
                      target="_blank"' +
                  '>'+ stream.title +
                  '</a>')
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
  applyShareCodeListener();
}

