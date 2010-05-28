$(document).ready(function() {
  var accessScheduleContainer = document.getElementById('mbs-access-schedule-container');
  if (!accessScheduleContainer) return;
  var bandID = accessScheduleContainer.className;
  var frame = document.createElement('iframe');
  frame.onload = 'alert("loaded");';


  accessScheduleContainer.style.margin = '1em';
  accessScheduleContainer.style.width = '500px';
  accessScheduleContainer.style.height = '300px';
  accessScheduleContainer.style.padding = '0px 0px';
  accessScheduleContainer.style.position = 'relative';
  accessScheduleContainer.style.borderTop = '4px solid #CCC';
  accessScheduleContainer.style.borderLeft = '4px solid #CCC';
  accessScheduleContainer.style.borderRight = '4px solid #444';
  accessScheduleContainer.style.borderBottom = '4px solid #444';
  frame.style.position = 'absolute';
  frame.style.height = '100%';
  frame.style.width = '100%';
  frame.style.margin = '0';
  frame.style.left = '0';
  frame.style.top = '0';


  //frame.src = 'http://localhost:3000/live_stream_series/'+ bandID +'/by_band'; //'http://cobain.mybandstock.com/live_stream_series/'+ bandID +'/by_band'; 
  //accessScheduleContainer.appendChild(frame);
  //applyFbListeners();
  //$(frame).load('http://localhost:3000/live_stream_series/'+ bandID +'/by_band');
  //$.getJSON("http://api.flickr.com/services/feeds/photos_public.gne?tags=cat&tagmode=any&format=json&jsoncallback=?", function(data){

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
	});
}

function accessScheduleJsonCallback(data) {
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

  //$('#mbs-access-schedule-container').append(html).append(seriesTitle).append(table);
  applyFbListeners();
}

/*
%h1="#{band.name} - Access Schedule"
-for series in band.live_stream_series
  %h2= series.title
  - if can_broadcast
    =link_to 'Schedule A New Stream', {:controller => 'streamapi_streams', :action => 'new', :band_id => band.id, :live_stream_series_id => series.id }
  %table.access-schedule-list
    -for stream in series.streamapi_streams
      %tr
        %td.stream-name
					= link_to stream.title, { :controller => 'streamapi_streams', :action => 'view', :id => stream.id, :lightbox => true }, :class => 'lightbox stream-title', :fbheight => (viewerTheme.height+46), :fbwidth => (viewerTheme.width+50)
					= stream.starts_at.strftime('%a %b %d, %Y at %I:%M%p')
				- if can_broadcast
					%td.begin-broadcast
						- broadcastTheme = StreamapiStreamTheme.find(stream.broadcast_theme_id)
						=link_to 'Begin broadcast', { :controller => 'streamapi_streams', :action => 'broadcast', :id => stream.id, :lightbox => true }, :class => 'lightbox', :fbheight => (broadcastTheme.height+57), :fbwidth => (broadcastTheme.width+50)
*/

