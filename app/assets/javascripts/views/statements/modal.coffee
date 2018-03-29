class App.Views.StatementModal extends Backbone.Marionette.View
  template: JST['statements/modal']

  events:
    'submit .form': 'createStatement'

  bindings:
    '[name=number]': 'number'
    '[name=issued_date]': 'issued_date'
    '[name=statement_type]': 'statement_type'
    '[name=reference_id]':
      observe: 'reference_id'
      onGet: 'numToStr'
      onSet: 'strToNum'

  templateContext: ->
    title =
      if @model.isNew()
        I18n.t('new_statement')
      else
        I18n.t('edit_statement')
    statements = @getOption('license').get('statements')
    banIds = _.pluck(statements, 'reference_id')
    statements = statements.filter (s) =>
      @model.get('reference_id') == s.id || !_.contains(banIds, s.id)

    title: title
    statements: statements

  onBeforeRender: ->
    Backbone.Validation.bind @,
      valid: @valid.bind(@)
      invalid: @invalid.bind(@)

    @listenTo @model, 'change', @validate
    @model.startTracking()

  createStatement: (event) ->
    event.preventDefault()
    @model.save()
      .done (statement) =>
        message =
          if @model.isNew()
            I18n.t('flash.create_success')
          else
            I18n.t('flash.update_success')

        @$modal.modal('hide') if @$modal
        new Noty(
          type: 'success'
          timeout: 3000
          text: message
        ).show()
        @triggerMethod('statements:change', statement)

      .fail (xhr) =>
        @showErrors(xhr.responseJSON)

  onRender: ->
    if @$modal
      @$modal.show()
    else
      @$modal = @$el.find('#newStatement').modal(show: true)

    @stickit()
    @$el.find('.date').datepicker(dateFormat: 'yy/mm/dd')

  valid: (view, attr) ->
    input = view.$el.find("[name=#{attr}]")
    input.removeClass('is-invalid')
    input.next('label.invalid-feedback').remove()

  invalid: (view, attr, msg) ->
    @setError(view, attr, msg)

  validate: ->
    @model.validate()
    @setDisable(!@model.isValid())

  setDisable: (value) ->
    @$el.find('#btnSubmit').attr('disabled', value)

  setError: (view, attr, msg) ->
    attr = 'reference_id' if attr is 'reference'

    input = view.$el.find("[name=#{attr}]")
    input.addClass('is-invalid')
    $parent = input.parent()

    label = $parent.find('label.invalid-feedback')
    if label.length is 0
      label = $('<label />', class: 'invalid-feedback')
      $parent.append(label)

    label.html(msg)

  showErrors: (errors) ->
    for attr, msg of errors
      @setError(@, attr, msg[0])
    @setDisable(true)

  numToStr: (ref_id) ->
    if ref_id
      ref_id.toString()

  strToNum: (ref_id) ->
    if ref_id
      parseInt(ref_id)
