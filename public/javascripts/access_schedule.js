$(document).ready(function() {

});
$(function() {
  $('a.lightbox').fancybox ({
    'transitionIn': 'fade',
    'transitionOut': 'fade',
    'type': 'iframe',
    'width': 750,
    'height': 740,
    'autoScale': true,        // These two only work with
    'autoDimensions': true,   //  'ajax' (non-'iframe') types,
    'centerOnScroll': true,
    'hideOnOverlayClick': false
  });
});

/*
autoScale	true	If true, FancyBox is scaled to fit in viewport
autoDimensions	true	For inline and ajax views, resizes the view to the element recieves. Make sure it has dimensions otherwise this will give unexpected results
centerOnScroll	false	When true, FancyBox is centered while scrolling page
*/

