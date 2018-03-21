# window.App =
#   Models: {}
#   Collections: {}
#   Views: {}
#   Routers: {}
#   initialize: ->
#     for _, Router of @Routers
#       new Router()
#     @router = new Backbone.Router()
#     Backbone.history.start()

class Application extends Backbone.Marionette.Application
  onStart: (app) ->
    for _, Router of app.Routers
      new Router()
    app.router = new Backbone.Router()
    Backbone.history.start()

window.App = new Application()

App.Views = {}
App.Models = {}
App.Routers = {}
App.Collections = {}

$(document).ready ->
  App.start()
