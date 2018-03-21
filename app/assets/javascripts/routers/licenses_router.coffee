class App.Routers.Licenses extends Backbone.Router
  routes:
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
    if @collection.isEmpty()
      @collection.getFirstPage
        success: (collection) =>
          model = @collection.get(id)
          @showDetails(model, @collection)

    model = @collection.get(id)
    @showDetails(model, @collection)

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
