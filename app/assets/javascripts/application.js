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

function validatePassword(){
    if ($('#user_password').val().length > 0) {
      $('.validate-me').parsley().destroy();
      $('#user_password').attr('data-parsley-required', 'true');
      $('#user_password_confirmation').attr('data-parsley-required', 'true');
      $('.validate-me').parsley();
    }
    else {
      $('.validate-me').parsley().destroy();
      $('#user_password').attr('data-parsley-required', 'false');
      $('#user_password_confirmation').attr('data-parsley-required', 'false');
      $('.validate-me').parsley();

    }
}

$(document).ready(function (){
    $(".help-form-submit").prop('disabled', true);
    $('#help_ticket_form_message').keyup(validate);
    $('#user_password').keyup(validatePassword);
});


// Getting Started Tour

var tour = new Tour({
  steps: [
  {
    element: "#dashboard_menu_item",
    title: "Dashboard",
    content: "A quick view into your account.",
    path: '/admin/dashboard'
  },
  {
    element: "#contacts_menu_item",
    title: "Add Contacts",
    content: "Contacts hold the contact info for people you will schedule calls to.",
    path: '/admin/contacts',
    onShow: function (tour) {
      $('#add-contact-button').tooltip({placement: 'top',trigger: 'manual'}).tooltip('show');
    },
  },
  {
    element: "#schedules_menu_item",
    title: "Add Schedules",
    content: "Schedules hold info for when to call a contact (repeating or one-time) and what to say during the call.",
    path: '/admin/schedules',
    onShow: function (tour) {
      $('#add-schedule-button').tooltip({placement: 'top',trigger: 'manual'}).tooltip('show');
    },
  },
  {
    element: "#billing_menu_item",
    title: "Start Your Subscription",
    content: "Your have 7 days of full access to try out TimeFor. After your trial ends, head to Billing to start your subscription and manage your billing info.",
    path: '/admin/billing'
  },
  {
    element: ".am-toggle-right-sidebar",
    title: "Sidebar Menu",
    placement: "left",
    content: "Log out and edit your profile from the sidebar.",
    onShow: function (tour) {
      $('#edit-profile-log-out a').tab('show');
      $('body').addClass('open-right-sidebar am-animate');
    },
    onNext: function (tour) {
      $('body').addClass('open-right-sidebar');
    },
  },
  {
    element: "#file-help-ticket a",
    title: "Need Help?",
    placement: "left",
    content: "File a help ticket and we'll get in touch quickly.",
    onShow: function (tour) {
      $('body').addClass('open-right-sidebar');
      $('#file-help-ticket a').tab('show');
    },
    onHide: function (tour) {
      $('body').removeClass('open-right-sidebar').addClass('am-animate');
    }
  }
]});

// Initialize the tour
tour.init();

// Start the tour
tour.start();
