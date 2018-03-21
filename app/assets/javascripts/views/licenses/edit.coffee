class App.Views.EditLicense extends Backbone.Marionette.View
  template: JST['licenses/form']

  regions:
    index:
      el: '#index'
      replaceElement: true
    modal:
      el: '#modal'
      replaceElement: true

  childViewEvents:
    'modal:submit': 'submit'
    'modal:hidden': 'redirectBack'

  onRender: ->
    @showChildView('index',
      new App.Views.IndexLicenses(
        collection: @collection
      )
    )

    if @model
      @showChildView('modal',
        new App.Views.ModalLicense(
          model: @model
        )
      )

  redirectBack: (childView) ->
    App.router.navigate('/licenses')
    @model.resetAttributes()
    @model.trigger('reset')

  submit: (childView) ->
    @model.save()
      .done (license) =>
        childView.closeModal()
        @collection.add(@model, merge: true)
        new Noty(
          type: 'success'
          timeout: 3000
          text: I18n.t('flash.update_success')
        ).show()

      .fail (xhr) =>
        childView.showErrors(xhr.responseJSON)
