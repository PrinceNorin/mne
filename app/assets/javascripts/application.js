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

$(document).ready(function() {
  $('.date').datepicker({
    changeYear: true,
    dateFormat: 'yy/mm/dd',
    onClose: function(dateText, inst) {
      $(inst.input).change().focusout();
    }
  });
});
