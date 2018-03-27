class App.Routers.Licenses extends Backbone.Router
  routes:
    '': 'indexLicenses'
    'licenses': 'indexLicenses'
    'licenses/new': 'newLicense'
    'licenses/:id': 'showLicense'
    'licenses/:id/edit': 'editLicense'

  initialize: ->
    @collection = new App.Collections.Licenses([], mode: 'server')

  indexLicenses: ->
    if @collection.isEmpty()
      @collection.getFirstPage().done =>
        $('.view').empty().append(
          new App.Views.IndexLicenses(
            collection: @collection
          ).render().el
        )
    else
      $('.view').empty().append(
        new App.Views.IndexLicenses(
          collection: @collection
        ).render().el
      )

  newLicense: ->
    if @collection.isEmpty()
      @collection.getFirstPage()

    model = new App.Models.License()
    $('.view').empty().append(
      new App.Views.NewLicense(
        model: model,
        collection: @collection
      ).render().el
    )

  showLicense: (id) ->
    model = @collection.get(id)
    if model
      $('.view').empty().append(
        new App.Views.ShowLicense(
          model: model
        ).render().el
      )
    else
      model = new App.Models.License(id: id)
      model.fetch
        success: (model) ->
          $('.view').empty().append(
            new App.Views.ShowLicense(
              model: model
            ).render().el
          )
        error: ->
          $('.view').empty().append(
            new App.Views.NotFound().render().el
          )

  editLicense: (id) ->
    if @collection.isEmpty()
      @collection.getFirstPage
        success: (collection) =>
          model = collection.get(id)
          @showEdit(model, collection)

    model = @collection.get(id)
    @showEdit(model, @collection)

  showEdit: (model, collection) ->
    $('.view').empty().append(
      new App.Views.EditLicense(
        model: model,
        collection: collection
      ).render().el
    )

  showDetails: (model, collection) ->
    $('.view').empty().append(
      new App.Views.DetailsLicense(
        model: model,
        collection: collection
      ).render().el
    )
