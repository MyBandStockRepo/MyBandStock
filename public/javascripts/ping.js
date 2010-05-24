$(document).ready(function() {

}
function startPinger() {
  var waitTime = 1*1000;   // 5 minutes
  var intervalTime = 10*1000; // 30 seconds
  setTimeout(
    function() {
      setInterval(
        function() {
          sendPing();
        }, intervalTime
      );
    }, waitTime
  );
  return;
}
function sendPing() {
  alert('send ping');
  return;
}
