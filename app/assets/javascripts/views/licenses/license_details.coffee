class App.Views.DetailsLicense extends Backbone.Marionette.View
  template: JST['licenses/form']

  regions:
    index:
      el: '#index'
      replaceElement: true
    modal:
      el: '#modal'
      replaceElement: true

  childViewEvents:
    'modal:hidden': 'redirectBack'

  onRender: ->
    @showChildView('index',
      new App.Views.IndexLicenses(
        collection: @collection
      )
    )

    if @model
      @showChildView('modal',
        new App.Views.DetailsModal(
          model: @model
        )
      )

  redirectBack: (childView) ->
    App.router.navigate('/licenses')
