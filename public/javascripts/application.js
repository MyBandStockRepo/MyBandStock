function openWelcomeLightbox() {
// Opens a lightbox containing the #welcome-message-container element on the page.
//
  if (!document.getElementById('welcome-message-container'))
    return false;
  var hiddenLink = document.createElement('a');
  hiddenLink.href = '#welcome-message-container';
  hiddenLink.style.display = 'none';
  hiddenLink.style.visibility = 'hidden';
  document.body.appendChild(hiddenLink);
  jQuery(hiddenLink).fancybox()
  
  setTimeout(function() {
    jQuery(hiddenLink).trigger('click');
  }, 1000);
  
  return true;
}


jQuery(function() {
  var selection = jQuery('#to_field').val();
  if (selection == 'lss')
    {
    jQuery('#bandall_field').hide();
    jQuery('#bandtop10_field').hide();    
    jQuery('#lss_field').show();      
    }
    else if (selection == 'band')
    {
        jQuery('#lss_field').hide();    
    jQuery('#bandtop10_field').hide();
    jQuery('#bandall_field').show();    
    }  
    else if (selection == 'bandtop10')
    {      
        jQuery('#lss_field').hide();  
    jQuery('#bandall_field').hide();
    jQuery('#bandtop10_field').show();
    }
    else
    {
    jQuery('#lss_field').hide();      
    jQuery('#bandall_field').hide();
    jQuery('#bandtop10_field').hide();
  }
  
  
  jQuery('#to_field').change(function() {
      var selection = jQuery('#to_field').val();
      if (selection == 'lss')
      {
      jQuery('#bandall_field').fadeOut();
      jQuery('#bandtop10_field').fadeOut();
      jQuery('#lss_field').fadeIn();      
      }
        else if (selection == 'band')
      {
          jQuery('#lss_field').fadeOut();    
      jQuery('#bandtop10_field').fadeOut();
      jQuery('#bandall_field').fadeIn();
      }  
      else if (selection == 'bandtop10')
      {      
          jQuery('#lss_field').fadeOut();  
      jQuery('#bandall_field').fadeOut();
      jQuery('#bandtop10_field').fadeIn();            
      }
      else
      {
      jQuery('#lss_field').fadeOut();      
      jQuery('#bandall_field').fadeOut();
      jQuery('#bandtop10_field').fadeOut();            
    }
  });
});
