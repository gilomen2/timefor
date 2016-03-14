var PayolaCheckout = {
    initialize: function() {
        $(document).on('click', '.payola-checkout-button', function(e) {
            e.preventDefault();
            PayolaCheckout.handleCheckoutButtonClick($(this));
        });
    },

    handleCheckoutButtonClick: function(button) {
        var form = button.parent('form');
        var options = form.data();

        var handler = StripeCheckout.configure({
            key: options.publishable_key,
            image: options.product_image_path,
            token: function(token) { PayolaCheckout.tokenHandler(token, options); },
            name: options.name,
            description: options.description,
            amount: options.price,
            panelLabel: options.panel_label,
            allowRememberMe: options.allow_remember_me,
            zipCode: options.verify_zip_code,
            billingAddress: options.billing_address,
            shippingAddress: options.shipping_address,
            currency: options.currency,
            email: options.email || undefined
        });

        handler.open();
    },

    tokenHandler: function(token, options) {
        var form = $("#" + options.form_id);
        console.log(options.form_id);
        form.append($('<input type="hidden" name="stripeToken">').val(token.id));
        form.append($('<input type="hidden" name="stripeEmail">').val(token.email));
        if (options.signed_custom_fields) {
          form.append($('<input type="hidden" name="signed_custom_fields">').val(options.signed_custom_fields));
        }

        $(".payola-checkout-button").prop("disabled", true);
        $(".payola-checkout-button-text").hide();
        $(".payola-checkout-button-spinner").show();
        $.ajax({
            type: "POST",
            url: options.base_path + "/buy/" + options.product_class + "/" + options.product_permalink,
            data: form.serialize(),
            success: function(data) { PayolaCheckout.poll(data.guid, 60, options); },
            error: function(data) { PayolaCheckout.showError(data.responseJSON.error, options); }
        });
    },

    showError: function(error, options) {
        var error_div = $("#" + options.error_div_id);
        error_div.html(error);
        error_div.show();
        $(".payola-checkout-button").prop("disabled", false);
        $(".payola-checkout-button-spinner").hide();
        $(".payola-checkout-button-text").show();
    },

    poll: function(guid, num_retries_left, options) {
        if (num_retries_left === 0) {
            PayolaCheckout.showError("This seems to be taking too long. Please contact support and give them transaction ID: " + guid, options);
            return;
        }

        var handler = function(data) {
            if (data.status === "finished") {
                window.location = options.base_path + "/confirm/" + guid;
            } else if (data.status === "errored") {
                PayolaCheckout.showError(data.error, options);
            } else {
                setTimeout(function() { PayolaCheckout.poll(guid, num_retries_left - 1, options); }, 500);
            }
        };

        $.ajax({
            type: "GET",
            url: options.base_path + "/status/" + guid,
            success: handler,
            error: handler
        });
    }
};
$(function() { PayolaCheckout.initialize(); });
var PayolaPaymentForm = {
    initialize: function() {
        $(document).on('submit', '.payola-payment-form', function() {
            return PayolaPaymentForm.handleSubmit($(this));
        });
    },

    handleSubmit: function(form) {
        form.find(':submit').prop('disabled', true);
        $('.payola-spinner').show();
        Stripe.card.createToken(form, function(status, response) {
            PayolaPaymentForm.stripeResponseHandler(form, status, response);
        });
        return false;
    },

    stripeResponseHandler: function(form, status, response) {
        if (response.error) {
            PayolaPaymentForm.showError(form, response.error.message);
        } else {
            var email = form.find("[data-payola='email']").val();

            var base_path = form.data('payola-base-path');
            var product = form.data('payola-product');
            var permalink = form.data('payola-permalink');

            var data_form = $('<form></form>');
            data_form.append($('<input type="hidden" name="stripeToken">').val(response.id));
            data_form.append($('<input type="hidden" name="stripeEmail">').val(email));
            data_form.append(PayolaPaymentForm.authenticityTokenInput());
            
            $.ajax({
                type: "POST",
                url: base_path + "/buy/" + product + "/" + permalink,
                data: data_form.serialize(),
                success: function(data) { PayolaPaymentForm.poll(form, 60, data.guid, base_path); },
                error: function(data) { PayolaPaymentForm.showError(form, data.responseJSON.error); }
            });
        }
    },

    poll: function(form, num_retries_left, guid, base_path) {
        if (num_retries_left === 0) {
            PayolaPaymentForm.showError(form, "This seems to be taking too long. Please contact support and give them transaction ID: " + guid);
        }
        $.get(base_path + '/status/' + guid, function(data) {
            if (data.status === "finished") {
                form.append($('<input type="hidden" name="payola_sale_guid"></input>').val(guid));
                form.append(PayolaPaymentForm.authenticityTokenInput());
                form.get(0).submit();
            } else if (data.status === "errored") {
                PayolaPaymentForm.showError(form, data.error);
            } else {
                setTimeout(function() { PayolaPaymentForm.poll(form, num_retries_left - 1, guid, base_path); }, 500);
            }
        });
    },

    showError: function(form, message) {
        $('.payola-spinner').hide();
        form.find(':submit').prop('disabled', false);
        var error_selector = form.data('payola-error-selector');
        if (error_selector) {
            $(error_selector).text(message);
        } else {
            form.find('.payola-payment-error').text(message);
        }
    },

    authenticityTokenInput: function() {
        return $('<input type="hidden" name="authenticity_token"></input>').val($('meta[name="csrf-token"]').attr("content"))
    }
};

$(function() { PayolaPaymentForm.initialize(); } );
var PayolaSubscriptionCheckout = {
    initialize: function() {
        $(document).on('click', '.payola-subscription-checkout-button', function(e) {
            e.preventDefault();
            PayolaSubscriptionCheckout.handleCheckoutButtonClick($(this));
        });
    },

    handleCheckoutButtonClick: function(button) {
        var form = button.parent('form');
        var options = form.data();

        var handler = StripeCheckout.configure({
            key: options.publishable_key,
            image: options.plan_image_path,
            token: function(token) { PayolaSubscriptionCheckout.tokenHandler(token, options); },
            name: options.name,
            description: options.description,
            amount: options.price,
            panelLabel: options.panel_label,
            allowRememberMe: options.allow_remember_me,
            zipCode: options.verify_zip_code,
            billingAddress: options.billing_address,
            shippingAddress: options.shipping_address,
            currency: options.currency,
            email: options.email || undefined
        });

        handler.open();
    },

    tokenHandler: function(token, options) {
        var form = $("#" + options.form_id);
        console.log(options.form_id);
        form.append($('<input type="hidden" name="stripeToken">').val(token.id));
        form.append($('<input type="hidden" name="stripeEmail">').val(token.email));
        form.append($('<input type="hidden" name="quantity">').val(options.quantity));
        if (options.signed_custom_fields) {
          form.append($('<input type="hidden" name="signed_custom_fields">').val(options.signed_custom_fields));
        }

        $(".payola-subscription-checkout-button").prop("disabled", true);
        $(".payola-subscription-checkout-button-text").hide();
        $(".payola-subscription-checkout-button-spinner").show();
        $.ajax({
            type: "POST",
            url: options.base_path + "/subscribe/" + options.plan_class + "/" + options.plan_id,
            data: form.serialize(),
            success: function(data) { PayolaSubscriptionCheckout.poll(data.guid, 60, options); },
            error: function(data) { PayolaSubscriptionCheckout.showError(data.responseJSON.error, options); }
        });
    },

    showError: function(error, options) {
        var error_div = $("#" + options.error_div_id);
        error_div.html(error);
        error_div.show();
        $(".payola-subscription-checkout-button").prop("disabled", false);
        $(".payola-subscription-checkout-button-spinner").hide();
        $(".payola-subscription-checkout-button-text").show();
    },

    poll: function(guid, num_retries_left, options) {
        if (num_retries_left === 0) {
            PayolaSubscriptionCheckout.showError("This seems to be taking too long. Please contact support and give them transaction ID: " + guid, options);
            return;
        }

        var handler = function(data) {
            if (data.status === "active") {
                window.location = options.base_path + "/confirm_subscription/" + guid;
            } else if (data.status === "errored") {
                PayolaSubscriptionCheckout.showError(data.error, options);
            } else {
                setTimeout(function() { PayolaSubscriptionCheckout.poll(guid, num_retries_left - 1, options); }, 500);
            }
        };

        $.ajax({
            type: "GET",
            url: options.base_path + "/subscription_status/" + guid,
            success: handler,
            error: handler
        });
    }
};
$(function() { PayolaSubscriptionCheckout.initialize(); });
var PayolaOnestepSubscriptionForm = {
    initialize: function() {
        $(document).on('submit', '.payola-onestep-subscription-form', function() {
            return PayolaOnestepSubscriptionForm.handleSubmit($(this));
        });
    },

    handleSubmit: function(form) {
        $(':submit').prop('disabled', true);
        $('.payola-spinner').show();
        Stripe.card.createToken(form, function(status, response) {
            PayolaOnestepSubscriptionForm.stripeResponseHandler(form, status, response);
        });
        return false;
    },

    stripeResponseHandler: function(form, status, response) {
        if (response.error) {
            PayolaOnestepSubscriptionForm.showError(form, response.error.message);
        } else {
            var email = form.find("[data-payola='email']").val();
            var coupon = form.find("[data-payola='coupon']").val();
            var quantity = form.find("[data-payola='quantity']").val();

            var base_path = form.data('payola-base-path');
            var plan_type = form.data('payola-plan-type');
            var plan_id = form.data('payola-plan-id');

            var action = $(form).attr('action');

            form.append($('<input type="hidden" name="plan_type">').val(plan_type));
            form.append($('<input type="hidden" name="plan_id">').val(plan_id));
            form.append($('<input type="hidden" name="stripeToken">').val(response.id));
            form.append($('<input type="hidden" name="stripeEmail">').val(email));
            form.append($('<input type="hidden" name="coupon">').val(coupon));
            form.append($('<input type="hidden" name="quantity">').val(quantity));
            form.append(PayolaOnestepSubscriptionForm.authenticityTokenInput());
            $.ajax({
                type: "POST",
                url: action,
                data: form.serialize(),
                success: function(data) { PayolaOnestepSubscriptionForm.poll(form, 60, data.guid, base_path); },
                error: function(data) { PayolaOnestepSubscriptionForm.showError(form, data.responseJSON.error); }
            });
        }
    },

    poll: function(form, num_retries_left, guid, base_path) {
        if (num_retries_left === 0) {
            PayolaOnestepSubscriptionForm.showError(form, "This seems to be taking too long. Please contact support and give them transaction ID: " + guid);
        }
        var handler = function(data) {
            if (data.status === "active") {
                window.location = base_path + '/confirm_subscription/' + guid;
            } else {
                setTimeout(function() { PayolaOnestepSubscriptionForm.poll(form, num_retries_left - 1, guid, base_path); }, 500);
            }
        };
        var errorHandler = function(jqXHR){
            PayolaOnestepSubscriptionForm.showError(form, jqXHR.responseJSON.error);
        };

        $.ajax({
            type: 'GET',
            dataType: 'json',
            url: base_path + '/subscription_status/' + guid,
            success: handler,
            error: errorHandler
        });
    },

    showError: function(form, message) {
        $('.payola-spinner').hide();
        $(':submit').prop('disabled', false);
        var error_selector = form.data('payola-error-selector');
        if (error_selector) {
            $(error_selector).text(message);
            $(error_selector).show();
        } else {
            form.find('.payola-payment-error').text(message);
            form.find('.payola-payment-error').show();
        }
    },

    authenticityTokenInput: function() {
        return $('<input type="hidden" name="authenticity_token"></input>').val($('meta[name="csrf-token"]').attr("content"));
    }
};

$(function() { PayolaOnestepSubscriptionForm.initialize() } );
var PayolaSubscriptionForm = {
    initialize: function() {
        $(document).on('submit', '.payola-subscription-form', function() {
            return PayolaSubscriptionForm.handleSubmit($(this));
        });
    },

    handleSubmit: function(form) {
        $(':submit').prop('disabled', true);
        $('.payola-spinner').show();
        Stripe.card.createToken(form, function(status, response) {
            PayolaSubscriptionForm.stripeResponseHandler(form, status, response);
        });
        return false;
    },

    stripeResponseHandler: function(form, status, response) {
        if (response.error) {
            PayolaSubscriptionForm.showError(form, response.error.message);
        } else {
            var email = form.find("[data-payola='email']").val();
            var coupon = form.find("[data-payola='coupon']").val();
            var quantity = form.find("[data-payola='quantity']").val();

            var base_path = form.data('payola-base-path');
            var plan_type = form.data('payola-plan-type');
            var plan_id = form.data('payola-plan-id');

            var data_form = $('<form></form>');
            data_form.append($('<input type="hidden" name="stripeToken">').val(response.id));
            data_form.append($('<input type="hidden" name="stripeEmail">').val(email));
            data_form.append($('<input type="hidden" name="coupon">').val(coupon));
            data_form.append($('<input type="hidden" name="quantity">').val(quantity));
            data_form.append(PayolaSubscriptionForm.authenticityTokenInput());
            $.ajax({
                type: "POST",
                url: base_path + "/subscribe/" + plan_type + "/" + plan_id,
                data: data_form.serialize(),
                success: function(data) { PayolaSubscriptionForm.poll(form, 60, data.guid, base_path); },
                error: function(data) { PayolaSubscriptionForm.showError(form, data.responseJSON.error); }
            });
        }
    },

    poll: function(form, num_retries_left, guid, base_path) {
        if (num_retries_left === 0) {
            PayolaSubscriptionForm.showError(form, "This seems to be taking too long. Please contact support and give them transaction ID: " + guid);
        }
        var handler = function(data) {
            if (data.status === "active") {
                form.append($('<input type="hidden" name="payola_subscription_guid"></input>').val(guid));
                form.append(PayolaSubscriptionForm.authenticityTokenInput());
                form.get(0).submit();
            } else {
                setTimeout(function() { PayolaSubscriptionForm.poll(form, num_retries_left - 1, guid, base_path); }, 500);
            }
        };
        var errorHandler = function(jqXHR){
          if(jqXHR.responseJSON.status === "errored"){
            PayolaSubscriptionForm.showError(form, jqXHR.responseJSON.error);
          }
        };

        $.ajax({
            type: 'GET',
            dataType: 'json',
            url: base_path + '/subscription_status/' + guid,
            success: handler,
            error: errorHandler
        });
    },

    showError: function(form, message) {
        $('.payola-spinner').hide();
        $(':submit').prop('disabled', false);
        var error_selector = form.data('payola-error-selector');
        if (error_selector) {
            $(error_selector).text(message);
            $(error_selector).show();
        } else {
            form.find('.payola-payment-error').text(message);
            form.find('.payola-payment-error').show();
        }
    },

    authenticityTokenInput: function() {
        return $('<input type="hidden" name="authenticity_token"></input>').val($('meta[name="csrf-token"]').attr("content"));
    }
};

$(function() { PayolaSubscriptionForm.initialize() } );
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//

