var widthvar = 560
var heightvar = 560

function setwh(w, h) {
	widthvar = w;
	heightvar = h;
	
	alert('w and h are '+widthvar+'x'+heightvar);
}


$(document).ready(function() {
	$(function() {
		$('a.lightbox').each(function(index){
			$(this).fancybox ({
				'transitionIn': 'fade',
				'transitionOut': 'fade',
				'overlayOpacity' : 0.6,
				'overlayColor' : 'black',      
				'type': 'iframe',
				'width': ( ($(this).attr('fbwidth') == null) ? 560 : parseInt($(this).attr('fbwidth')) ),
				'height': ( ($(this).attr('fbheight') == null) ? 560 : parseInt($(this).attr('fbheight')) ),
				'autoScale': true,        // These two only work with
				'autoDimensions': true,   //  'ajax' (non-'iframe') types,
				'centerOnScroll': true,
				'hideOnOverlayClick': false
			});
		});
	});
});
/*
autoScale	true	If true, FancyBox is scaled to fit in viewport
autoDimensions	true	For inline and ajax views, resizes the view to the element recieves. Make sure it has dimensions otherwise this will give unexpected results
centerOnScroll	false	When true, FancyBox is centered while scrolling page

$(document).ready(function() {

});
$(function() {
  $('a.lightbox').fancybox ({
    'transitionIn': 'fade',
    'transitionOut': 'fade',
    'overlayOpacity' : 0.6,
    'overlayColor' : 'black',      
    'type': 'iframe',
    'width': widthvar,
    'height': heightvar,
    'autoScale': true,        // These two only work with
    'autoDimensions': true,   //  'ajax' (non-'iframe') types,
    'centerOnScroll': true,
    'hideOnOverlayClick': false
  });
});

*/

