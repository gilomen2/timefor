$(document).ready(function(){

  $(document).bind('ajaxError', 'form#new_contact', function(event, jqxhr, settings, exception){

  });

});

(function($) {

  $.fn.modal_success = function(){
    // close modal
    this.modal('hide');

    // clear form input elements
    // todo/note: handle textarea, select, etc
    this.find('form input[type="text"]').val('');

  };


}(jQuery));
