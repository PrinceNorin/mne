class App.Views.ShowLicense extends Backbone.Marionette.View
  template: JST['licenses/show']

  events:
    'click #btnStatus': 'openStatementModal'
    'click #btnEdit': 'editStatement'

  regions:
    statementModal:
      el: '#statementModal'
      replaceElement: true

  childViewEvents:
    'statements:change': 'updateStatement'

  templateContext: ->
    colorCodes:
      'suspense': 'danger'
      'resolved': 'success'
      'dispute': 'warning'

  onBeforeRender: ->
    @listenTo @model, 'change', =>
      @render()

  openStatementModal: ->
    statementModel = new App.Models.Statement(
      license_id: @model.id
    )
    @showChildView('statementModal',
      new App.Views.StatementModal(
        model: statementModel
        license: @model
      )
    )

  editStatement: (event) ->
    event.preventDefault()

    id = $(event.target).parents('td').data('id')
    statement = @model.get('statements').find (s) ->
      parseInt(s.id) == parseInt(id)

    statementModel = new App.Models.Statement(statement)
    @showChildView('statementModal',
      new App.Views.StatementModal(
        model: statementModel
        license: @model
      )
    )

  updateStatement: (statement) ->
    @model.set(statement.license)
