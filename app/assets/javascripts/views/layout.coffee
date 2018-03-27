class App.Views.Layout extends Backbone.Marionette.View
  template: JST['layout']

  templateContext: ->
    user: window.user
    token: window.csrfToken
