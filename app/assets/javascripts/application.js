//= require ./alert
//= require rails-ujs
//= require jquery3
//= require jquery-ui
//= require popper
//= require bootstrap
//= require rails.validations
//= require rails.validations.simple_form
//= require i18n.js
//= require i18n/translations
// require underscore
// require_tree ./vendors
// require backbone
// require backbone.stickit
// require backbone.validation
// require app
// require_tree ../templates
// require_tree ./models
// require_tree ./collections
// require_tree ./views
// require_tree ./routers
//= require ./vendors/typeahead.bundle.min
//= require ./vendors/lodash
//= require ./vendors/vue
//= require ./vue/tax_form

$(document).ready(function() {
  $('.date').datepicker({
    changeYear: true,
    dateFormat: 'yy-mm-dd',
    onClose: function(dateText, inst) {
      $(inst.input).change().focusout();
    }
  });

  $('.date-year').datepicker({
    changeYear: true,
    changeMonth: true,
    dateFormat: 'yy-mm-dd',
    onClose: function(dateText, inst) {
      $(inst.input).change().focusout();
      $(this).datepicker('setDate', new Date(inst.selectedYear,
        inst.selectedMonth, 1));
    },
    beforeShow: function(input, inst) {
      $('#ui-datepicker-div').addClass('no-day')
    }
  });

  function calculateTotalTax(event, baseName, name) {
    var input = $(this)
    var form = input.closest('form');
    var totalInput = form.find('input.tax-input[name="' + baseName + '[' + name + ']"]');

    var val = input.val() || 0;
    var rate = form.find('input.tax-input[name="' + baseName + '[tax_rate]"]').val() || 0;

    totalInput.val(val * rate)
  }

  $('select[name="tax[tax_type]"]').on('change', function(event) {
    var rate = TAX_RATES[event.target.value];
    var form = $(this).closest('form');

    form.find('input.tax-input[name="tax[tax_rate]"]').val(rate);
    form.find('input.tax-input[name="tax[unit]"]').trigger('keyup');
  });

  $('input.tax-input[name="tax[unit]"]').on('keyup', function(event) {
    calculateTotalTax.call(this, event, 'tax', 'total');
  });

  $('input.tax-input[name="tax_env_recovery[unit_1]"]').on('keyup', function(event) {
    calculateTotalTax.call(this, event, 'tax_env_recovery', 'total_1');
  });

  $('input.tax-input[name="tax_env_recovery[unit_2]"]').on('keyup', function(event) {
    calculateTotalTax.call(this, event, 'tax_env_recovery', 'total_2');
  });
});
