// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require payola
//= require jquery_ujs
//= require bootstrap-sprockets
//= require data-confirm-modal
//= require_tree ../../../vendor/assets/javascripts/app/.



dataConfirmModal.setDefaults({
  modalClass: 'colored-header'
});

$(document).ajaxStart(function() {
   $('.sb-content').addClass('masked').delay(600);
});
$(document).ajaxStop(function() {
	$(".sb-content .loading").addClass('success');
	$('#help_ticket_form_message').val('')
  $(".help-form-submit").prop('disabled', true)
	$('.sb-content').removeClass('masked');
});
function validate(){
    if ($('#help_ticket_form_message').val().length > 0) {
    	$('.help-form-submit').removeClass('disabled').prop("disabled", false);
    }
    else {
      $('.help-form-submit').prop("disabled", true);
    }
}

$(document).ready(function (){
    $(".help-form-submit").prop('disabled', true);
    $('#help_ticket_form_message').keyup(validate);
});

