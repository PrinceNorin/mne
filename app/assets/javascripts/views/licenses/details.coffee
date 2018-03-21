class App.Views.DetailsModal extends Backbone.Marionette.View
  template: JST['licenses/details']

  triggers:
    'hidden.bs.modal #detailsLicense': 'modal:hidden'

  onRender: ->
    if @$modal
      @$modal.show()
    else
      @$modal = @$el.find('#detailsLicense').modal(show: true)
