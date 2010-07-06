$j = jQuery.noConflict();
$j(document).ready(function() {
  $j('.jqAccordion').each(function(i) {
    $j(this).accordion({
      header: '.accordion_header',
      change: function(event, element) {
      }
    });
  });
});
