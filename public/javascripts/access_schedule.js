$(document).ready(function() {
  var accessScheduleContainer = document.getElementById('mbs-access-schedule-container');
  if (!accessScheduleContainer) {
    // This script was loaded from a viewer lightbox
    return;
  }
  var bandID = accessScheduleContainer.className;

  accessScheduleContainer.style.margin = '1em';
  accessScheduleContainer.style.width = '500px';
  accessScheduleContainer.style.height = '300px';
  accessScheduleContainer.style.padding = '0px 0px';
  accessScheduleContainer.style.position = 'relative';
  accessScheduleContainer.style.borderTop = '4px solid #CCC';
  accessScheduleContainer.style.borderLeft = '4px solid #CCC';
  accessScheduleContainer.style.borderRight = '4px solid #444';
  accessScheduleContainer.style.borderBottom = '4px solid #444';

  $.getJSON('http://cobain.mybandstock.com/live_stream_series/jsonp/'+ bandID +'/?jsoncallback=?', function(data){ });

  /*
  $.ajax({
    url: 'http://localhost:3000/live_stream_series/jsonp/'+ bandID +'/?jsoncallback=?',
    dataType: 'jsonp',
    success: function(data) {
      $('#content-utility').append(data.toString());
    }
  });
  */
});


$(function() {
  applyFbListeners();
});

function applyFbListeners() {
	$('a.lightbox').each(function(index){
		$(this).fancybox ({
			'transitionIn': 'fade',
			'transitionOut': 'fade',
			'overlayOpacity' : 0.6,
			'overlayColor' : 'black',      
			'type': 'iframe',
			'width': ( ($(this).attr('fbwidth') == null) ? 560 : parseInt($(this).attr('fbwidth')) ),
			'height': ( ($(this).attr('fbheight') == null) ? 560 : parseInt($(this).attr('fbheight')) ),
			'autoScale': false,        // These two only work with
			'autoDimensions': true,   //  'ajax' (non-'iframe') types,
			'centerOnScroll': true,
			'hideOnOverlayClick': false
		});
    $(this).click(function(e) { e.preventDefault(); });
	});
}

function accessScheduleJsonCallback(data) {
  // Construct Access Schedule HTML from incoming JSON
  var html = document.createElement('h1');
  html.innerHTML = data.band_name + ' - Access Schedule';

  $('#mbs-access-schedule-container').append(html);

  $.each(data.serieses, function(seriesIndex, series) { // for each series
    var seriesTitle = document.createElement('h2');
    seriesTitle.innerHTML = series.series_title;

    var table = $(document.createElement('table'));
    table.addClass('access-schedule-list');
    $.each(series.streams, function(streamIndex, stream) {  // for each stream
      table.append(
        $(document.createElement('tr')).append(
          $(document.createElement('td')).addClass('stream-name').append(
            $('<a href="'+ stream.view_link.url +'">'+ stream.title +'</a>')
              .addClass('lightbox stream-title')
              .attr('fbwidth', stream.view_link.width)
              .attr('fbheight', stream.view_link.height)
          )
        )
      );
    });
    $('#mbs-access-schedule-container').append(seriesTitle).append(table);
  });
  applyFbListeners();
}

