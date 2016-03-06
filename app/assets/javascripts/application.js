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
//= require bootstrap-sprockets
//= require data-confirm-modal
//= require_tree .



// Set contents of contact copy form
$( "#contacts-table" ).on("click", ".contact", function(event) {
  $('#copy_contact').addClass('md-show');
  var myContactObject = $(event.currentTarget).data('contact');
  $('#contact-name-copy').val(myContactObject.name);
  $('#contact-phone-copy').val(myContactObject.phone);
  $('form#copy-contact').attr('action', '/admin/contacts/' + myContactObject.id);
});

// Set contents of schedule copy form
$( "#schedules-table" ).on("click", ".schedule", function(event) {
  $('#copy_schedule').addClass('md-show');
  var myScheduleObject = $(event.currentTarget).data('schedule');
  console.log(myScheduleObject)
  var contact_id = parseInt(myScheduleObject.contact_id, 10)
  $('#schedule-contact-copy').val(contact_id);
  $('#schedule-message-copy').val(myScheduleObject.message);
  $('#schedule-start-date-copy').val(myScheduleObject.schedule_start_date);
  $('#schedule-time-copy').val(myScheduleObject.schedule_time);
  if (myScheduleObject.repeat == "true") {
    $('#schedule-repeat-copy').prop('checked', true);
    $('#repeat-days-copy').collapse('show');
  }
  if (myScheduleObject.sunday == "true") {
    $('#schedule-sunday-copy').prop('checked', true);
  }
  if (myScheduleObject.monday == "true") {
    $('#schedule-monday-copy').prop('checked', true);
  }
  if (myScheduleObject.tuesday == "true") {
    $('#schedule-tuesday-copy').prop('checked', true);
  }
  if (myScheduleObject.wednesday == "true") {
    $('#schedule-wednesday-copy').prop('checked', true);
  }
  if (myScheduleObject.thursday == "true") {
    $('#schedule-thursday-copy').prop('checked', true);
  }
  if (myScheduleObject.friday == "true") {
    $('#schedule-friday-copy').prop('checked', true);
  }
  if (myScheduleObject.saturday == "true") {
    $('#schedule-saturday-copy').prop('checked', true);
  }
  $('#schedule-timezone-copy').val(myScheduleObject.schedule_timezone);
  $('form#copy-schedule').attr('action', '/admin/schedules/' + myScheduleObject.id);
});

// Clear new schedule form on close
$("#add-new-schedule-close").click(function(){
  $('#schedule-repeat').prop('checked', false);
  $('#schedule-sunday').prop('checked', false);
  $('#schedule-monday').prop('checked', false);
  $('#schedule-tuesday').prop('checked', false);
  $('#schedule-wednesday').prop('checked', false);
  $('#schedule-thursday').prop('checked', false);
  $('#schedule-friday').prop('checked', false);
  $('#schedule-saturday').prop('checked', false);
  $('#repeat-days').collapse('hide');
  $("#schedule_contact_id").val($("#schedule_contact_id option:first").val());
  $("#frequency_timezone").val($("#frequency_timezone option:first").val());
  $("#schedule_message").val('');
  $("#frequency_start_date").val('');
  $("#frequency_time").val('');
});

$("#add-new-schedule-close-top").click(function(){
  $('#schedule-repeat').prop('checked', false);
  $('#schedule-sunday').prop('checked', false);
  $('#schedule-monday').prop('checked', false);
  $('#schedule-tuesday').prop('checked', false);
  $('#schedule-wednesday').prop('checked', false);
  $('#schedule-thursday').prop('checked', false);
  $('#schedule-friday').prop('checked', false);
  $('#schedule-saturday').prop('checked', false);
  $('#repeat-days').collapse('hide');
  $("#schedule_contact_id").val($("#schedule_contact_id option:first").val());
  $("#frequency_timezone").val($("#frequency_timezone option:first").val());
  $("#schedule_message").val('');
  $("#frequency_start_date").val('');
  $("#frequency_time").val('');
});

// Clear new schedule form on add button click
$("#add-schedule-button").click(function(){
  $('#schedule-repeat').prop('checked', false);
  $('#schedule-sunday').prop('checked', false);
  $('#schedule-monday').prop('checked', false);
  $('#schedule-tuesday').prop('checked', false);
  $('#schedule-wednesday').prop('checked', false);
  $('#schedule-thursday').prop('checked', false);
  $('#schedule-friday').prop('checked', false);
  $('#schedule-saturday').prop('checked', false);
  $('#repeat-days').collapse('hide');
  $("#schedule_contact_id").val($("#schedule_contact_id option:first").val());
  $("#frequency_timezone").val($("#frequency_timezone option:first").val());
  $("#schedule_message").val('');
  $("#frequency_start_date").val('');
  $("#frequency_time").val('');
});


// Clear new contact form on close
$("#add-new-contact-close").click(function(){
  $("#contact_name").val('');
  $("#contact_phone").val('');
});

$("#add-new-contact-close-top").click(function(){
  $("#contact_name").val('');
  $("#contact_phone").val('');
});

// Schedule copy - Fix for bizarro way that checkboxes are handled in theme
$("#repeat-copy-div" ).on("click", "label", function(event) {
   if ($('#schedule-repeat-copy').prop('checked') == true ) {
      $('#schedule-repeat-copy').prop('checked', false);
      $('#repeat-days-copy').collapse('hide');
   } else if ($('#schedule-repeat-copy').prop('checked') == false ) {
      $('#schedule-repeat-copy').prop('checked', true);
      $('#repeat-days-copy').collapse('show');
   }
});
$("#repeat-days-copy" ).on("click", "label#frequency_sunday_copy", function(event) {
   if ($('#schedule-sunday-copy').prop('checked') == true ) {
      $('#schedule-sunday-copy').prop('checked', false);
   } else if ($('#schedule-sunday-copy').prop('checked') == false ) {
      $('#schedule-sunday-copy').prop('checked', true);
   }
});
$("#repeat-days-copy" ).on("click", "label#frequency_monday_copy", function(event) {
   if ($('#schedule-monday-copy').prop('checked') == true ) {
      $('#schedule-monday-copy').prop('checked', false);
   } else if ($('#schedule-monday-copy').prop('checked') == false ) {
      $('#schedule-monday-copy').prop('checked', true);
   }
});
$("#repeat-days-copy" ).on("click", "label#frequency_tuesday_copy", function(event) {
   if ($('#schedule-tuesday-copy').prop('checked') == true ) {
      $('#schedule-tuesday-copy').prop('checked', false);
   } else if ($('#schedule-tuesday-copy').prop('checked') == false ) {
      $('#schedule-tuesday-copy').prop('checked', true);
   }
});
$("#repeat-days-copy" ).on("click", "label#frequency_wednesday_copy", function(event) {
   if ($('#schedule-wednesday-copy').prop('checked') == true ) {
      $('#schedule-wednesday-copy').prop('checked', false);
   } else if ($('#schedule-wednesday-copy').prop('checked') == false ) {
      $('#schedule-wednesday-copy').prop('checked', true);
   }
});
$("#repeat-days-copy" ).on("click", "label#frequency_thursday_copy", function(event) {
   if ($('#schedule-thursday-copy').prop('checked') == true ) {
      $('#schedule-thursday-copy').prop('checked', false);
   } else if ($('#schedule-thursday-copy').prop('checked') == false ) {
      $('#schedule-thursday-copy').prop('checked', true);
   }
});
$("#repeat-days-copy" ).on("click", "label#frequency_friday_copy", function(event) {
   if ($('#schedule-friday-copy').prop('checked') == true ) {
      $('#schedule-friday-copy').prop('checked', false);
   } else if ($('#schedule-friday-copy').prop('checked') == false ) {
      $('#schedule-friday-copy').prop('checked', true);
   }
});
$("#repeat-days-copy" ).on("click", "label#frequency_saturday_copy", function(event) {
   if ($('#schedule-saturday-copy').prop('checked') == true ) {
      $('#schedule-saturday-copy').prop('checked', false);
   } else if ($('#schedule-saturday-copy').prop('checked') == false ) {
      $('#schedule-saturday-copy').prop('checked', true);
   }
});




// Schedule new - Fix for bizarro way that checkboxes are handled in theme
$("#repeat-div" ).on("click", "label", function(event) {
   if ($('#schedule-repeat').prop('checked') == true ) {
      $('#schedule-repeat').prop('checked', false);
      $('#repeat-days').collapse('hide');
   } else if ($('#schedule-repeat').prop('checked') == false ) {
      $('#schedule-repeat').prop('checked', true);
      $('#repeat-days').collapse('show');
   }
});
$("#repeat-days" ).on("click", "label#frequency_sunday", function(event) {
   if ($('#schedule-sunday').prop('checked') == true ) {
      $('#schedule-sunday').prop('checked', false);
   } else if ($('#schedule-sunday').prop('checked') == false ) {
      $('#schedule-sunday').prop('checked', true);
   }
});
$("#repeat-days" ).on("click", "label#frequency_monday", function(event) {
   if ($('#schedule-monday').prop('checked') == true ) {
      $('#schedule-monday').prop('checked', false);
   } else if ($('#schedule-monday').prop('checked') == false ) {
      $('#schedule-monday').prop('checked', true);
   }
});
$("#repeat-days" ).on("click", "label#frequency_tuesday", function(event) {
   if ($('#schedule-tuesday').prop('checked') == true ) {
      $('#schedule-tuesday').prop('checked', false);
   } else if ($('#schedule-tuesday').prop('checked') == false ) {
      $('#schedule-tuesday').prop('checked', true);
   }
});
$("#repeat-days" ).on("click", "label#frequency_wednesday", function(event) {
   if ($('#schedule-wednesday').prop('checked') == true ) {
      $('#schedule-wednesday').prop('checked', false);
   } else if ($('#schedule-wednesday').prop('checked') == false ) {
      $('#schedule-wednesday').prop('checked', true);
   }
});
$("#repeat-days" ).on("click", "label#frequency_thursday", function(event) {
   if ($('#schedule-thursday').prop('checked') == true ) {
      $('#schedule-thursday').prop('checked', false);
   } else if ($('#schedule-thursday').prop('checked') == false ) {
      $('#schedule-thursday').prop('checked', true);
   }
});
$("#repeat-days" ).on("click", "label#frequency_friday", function(event) {
   if ($('#schedule-friday').prop('checked') == true ) {
      $('#schedule-friday').prop('checked', false);
   } else if ($('#schedule-friday').prop('checked') == false ) {
      $('#schedule-friday').prop('checked', true);
   }
});
$("#repeat-days" ).on("click", "label#frequency_saturday", function(event) {
   if ($('#schedule-saturday').prop('checked') == true ) {
      $('#schedule-saturday').prop('checked', false);
   } else if ($('#schedule-saturday').prop('checked') == false ) {
      $('#schedule-saturday').prop('checked', true);
   }
});
