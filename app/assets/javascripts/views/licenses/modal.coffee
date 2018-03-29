class App.Views.ModalLicense extends Backbone.Marionette.View
  template: JST['licenses/modal']

  triggers:
    'submit #licenseForm': 'modal:submit'
    'hidden.bs.modal #showLicense': 'modal:hidden'

  bindings:
    '[name=area]': 'area'
    '[name=number]': 'number'
    '[name=owner_name]': 'owner_name'
    '[name=issued_date]': 'issued_date'
    '[name=company_name]': 'company_name'
    '[name=expires_date]': 'expires_date'
    '[name=area_unit]': 'area_unit'
    '[name=province]': 'province'
    '[name=license_type]': 'license_type'
    '[name=address]': 'address'
    '[name=note]': 'note'

  templateContext: ->
    labels =
      if @model.isNew()
        ['create', 'new_license']
      else
        ['update', 'edit_license']
    title: I18n.t(labels[1])
    btnLabel: I18n.t(labels[0])

  onBeforeRender: ->
    Backbone.Validation.bind @,
      valid: @valid.bind(@)
      invalid: @invalid.bind(@)

    @listenTo @model, 'change', @validate
    @model.startTracking()

  onRender: ->
    if @$modal
      @$modal.show()
    else
      @$modal = @$el.find('#showLicense').modal(show: true)

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

  setError: (view, attr, msg) ->
    input = view.$el.find("[name=#{attr}]")
    input.addClass('is-invalid')
    $parent = input.parent()

    label = $parent.find('label.invalid-feedback')
    if label.length is 0
      label = $('<label />', class: 'invalid-feedback')
      $parent.append(label)

    label.html(msg)

  setLoading: (value) ->
    $btn = @.$el.find('#btnSubmit')
    $loading = @.$el.find('#btnSubmit i')

    if $loading.length is 0
      $loading = $('<i />', class: 'fa fa-spinner fa-spin')
      $loading.hide()
      $btn.prepend($loading)

    if value
      $loading.show()
    else
      $loading.hide()

    $btn.attr('disabled', value)

  setDisable: (value) ->
    @.$el.find('#btnSubmit').attr('disabled', value)

  setFocus: ->
    @.$el.find('input[name=number]').focus()

  closeModal: ->
    if @$modal
      @$modal.modal('hide')

  showErrors: (errors) ->
    for attr, msg of errors
      @setError(@, attr, msg[0])

    @setLoading(false)
    @setFocus()
    @setDisable(true)
