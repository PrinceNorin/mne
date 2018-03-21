class App.Views.NewLicense extends Backbone.Marionette.View
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

    @showChildView('modal',
      new App.Views.ModalLicense(
        model: @model
      )
    )

  redirectBack: (childView) ->
    App.router.navigate('/licenses')

  submit: (childView) ->
    @model.save()
      .done (license) =>
        childView.closeModal()
        @collection.add(new App.Models.License(license))
        new Noty(
          type: 'success'
          timeout: 3000
          text: I18n.t('flash.create_success')
        ).show()

      .fail (xhr) =>
        childView.showErrors(xhr.responseJSON)
