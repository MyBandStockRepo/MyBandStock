$(document).ready( function() { } );

function startPinger(streamID, viewerKey) {
  var waitTime = 10*1000;   // 5 minutes
  var intervalTime = 1*1000; // 30 seconds
  setTimeout(
    function() {
      setInterval(
        function() {
          sendPing(streamID, viewerKey);
        }, intervalTime
      );
    }, waitTime
  );
  return;
}
function sendPing(streamID, viewerKey) {
  var url = '/streamapi_streams/'+ streamID +'/ping/'+ viewerKey
  $.get(url, function(data) { });
  return;
}
