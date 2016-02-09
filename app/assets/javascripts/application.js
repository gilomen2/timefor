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
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require data-confirm-modal
//= require jquery.turbolinks
//= require_tree .


var ready;
ready = function() {
	$( "#contacts-table" ).on("click", ".contact", function(event) {
	  $('#edit_contact').addClass('md-show');
	  var myContactObject = $(event.currentTarget).data('contact');
	  $('#contact-name-edit').val(myContactObject.name);
	  $('#contact-phone-edit').val(myContactObject.phone);
	  $('form#edit-contact').attr('action', '/admin/contacts/' + myContactObject.id);
	});

  $( "#schedules-table" ).on("click", ".schedule", function(event) {
    $('#edit_schedule').addClass('md-show');
    var myScheduleObject = $(event.currentTarget).data('schedule');
    console.log(myScheduleObject)
    var contact_id = parseInt(myScheduleObject.contact_id, 10)
    $('#schedule-contact-edit').val(contact_id);
    $('#schedule-message-edit').val(myScheduleObject.message);
    $('form#edit-schedule').attr('action', '/admin/schedules/' + myScheduleObject.id);
  });
};

$(document).ready(ready);
$(document).on('page:load', ready);
