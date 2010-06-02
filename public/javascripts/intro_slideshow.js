function theRotator() {
  //Set the opacity of all images to 0
  jQuery('div#slides ul li').css({opacity: 0.0});

  //Get the first image and display it (gets set to full opacity)
  jQuery('div#slides ul li:first').css({opacity: 1.0});
	
  //Call the rotator function to run the slideshow, 6000 = change to next image after 6 seconds
  setInterval('rotate()',6000);
}
function rotate() {	
  //Get the first image
  var current = (jQuery('div#slides ul li.show')?  jQuery('div#slides ul li.show') : jQuery('div#slides ul li:first'));

  //Get next image, when it reaches the end, rotate it back to the first image
  var next = ((current.next().length) ? ((current.next().hasClass('show')) ? jQuery('div#slides ul li:first') :current.next()) : jQuery('div#slides ul li:first'));	

  //Set the fade in effect for the next image, the show class has higher z-index
  next.css({opacity: 0.0})
  .addClass('show')
  .animate({opacity: 1.0}, 1000);

  //Hide the current image
  current.animate({opacity: 0.0}, 1000)
  .removeClass('show');
};

jQuery(document).ready( function(){
  theRotator();
})
