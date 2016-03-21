var App = (function () {
  'use strict';

  App.masks = function( ){

    $("[data-mask='date']").mask("9999-99-99");
    $("[data-mask='phone']").mask("(999) 999-9999");
    $("[data-mask='phone-ext']").mask("(999) 999-9999? x99999");
    $("[data-mask='phone-int']").mask("+33 999 999 999");
    $("[data-mask='taxid']").mask("9999 9999 9999 9999");
    $("[data-mask='ssn']").mask("999-99-9999");
    $("[data-mask='product-key']").mask("a*-999-a999");
    $("[data-mask='percent']").mask("99%");
    $("[data-mask='currency']").mask("$999,999,999.99");
    $("[data-mask='time']").mask('99:99');
    $("[data-mask='cc']").mask('9999 9999 9999 9999');
    $("[data-mask='month']").mask('99');
    $("[data-mask='year']").mask('9999');
    $("[data-mask='cvc']").mask('999');


  };

  return App;
})(App || {});
