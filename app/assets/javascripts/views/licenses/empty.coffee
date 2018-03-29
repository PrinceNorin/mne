class App.Views.EmptyLicense extends Backbone.Marionette.View
  tagName: 'tr'
  template: ->
    "<td colspan='8' class='text-center'>#{I18n.t('no_license')}</td>"
