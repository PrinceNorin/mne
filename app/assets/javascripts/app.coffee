class Application extends Backbone.Marionette.Application
  region: '.root'

  onStart: (app) ->
    for _, Router of app.Routers
      new Router()

    @showView(new App.Views.Layout())
    app.router = new Backbone.Router()
    Backbone.history.start(pushState: true)

window.App = new Application()

App.Views = {}
App.Models = {}
App.Routers = {}
App.Collections = {}

$(document).ready ->
  I18n.locale = $('html').attr('lang')
  if $('.root').length > 0
    App.start()
