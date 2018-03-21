class App.Views.ShowLicenseButtonGroup extends Backbone.Marionette.View
  className: 'btn-group'
  template: JST['licenses/buttons/show']

  templateContext: ->
    perPage: @getOption('perPage')

  events:
    'click .dropdown-item': 'changeShow'

  changeShow: (event) ->
    event.preventDefault()
    @triggerMethod('show:change', $(event.target).data('show'))
