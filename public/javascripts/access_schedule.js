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

  /*
  $.getJSON('http://localhost:3000/live_stream_series/'+ bandID +'/by_band?jsoncallback=?', function(data){
    console.log(data);
    $('#content-utility').append(data);
    //alert(data);
  });
  */
  $.ajax({
    url: 'http://localhost:3000/live_stream_series/jsonp?jsoncallback=?',
    dataType: 'jsonp',
    success: function(data) {
      $('#content-utility').append(data.toString());
    }
  });

});


$(function() {
  applyFbListeners();
});

function applyFbListeners() {
  $('a.lightbox').fancybox ({
    'transitionIn': 'fade',
    'transitionOut': 'fade',
    'overlayOpacity' : 0.6,
    'overlayColor' : 'black',
    'type': 'ajax',
    'width': 560,
    'height': 560,
    'autoScale': false,        // These two only work with
    'autoDimensions': true,   //  'ajax' (non-'iframe') types,
    'centerOnScroll': true,
    'hideOnOverlayClick': false
  });
}

function accessScheduleJsonCallback(data) {
  alert(data);
}

/*
autoScale	true	If true, FancyBox is scaled to fit in viewport
autoDimensions	true	For inline and ajax views, resizes the view to the element recieves. Make sure it has dimensions otherwise this will give unexpected results
centerOnScroll	false	When true, FancyBox is centered while scrolling page
*/

