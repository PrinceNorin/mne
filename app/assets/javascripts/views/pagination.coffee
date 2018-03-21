class App.Views.Pagination extends Backbone.Marionette.View
  template: JST['pagination']

  events:
    'click .page-link': 'changePage'

  templateContext: ->
    page: @getOption('page')
    total: @getOption('total')

  changePage: (event) ->
    event.preventDefault()
    @triggerMethod('page:change', $(event.target).data('page'))
