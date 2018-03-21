class App.Views.FilterLicenseButtonGroup extends Backbone.Marionette.View
  className: 'btn-group'
  template: JST['licenses/buttons/filter']

  events:
    'click .dropdown-item': 'handleItemClick'
    'change .form-control': 'handleChange'

  templateContext: ->
    type: @getOption('type')
    text: @getOption('text')

  onRender: ->
    @$el.find('.date').datepicker(
      dateFormat: 'yy/mm/dd'
    )

    type = @getOption('type')
    if _.contains(['license_type', 'status', 'province'], type)
      @triggerMethod('filter:change', type: type, value: @$el.find('.form-control').val())

  handleItemClick: (event) ->
    event.preventDefault()
    $item = $(event.target)
    type = $item.data('filter')
    if type == 'all'
      @triggerMethod('filter:change', {})
    @triggerMethod('filter:click', type, $item.text())

  handleChange: (event) ->
    type = @getOption('type')
    if type == 'issued_date' || type == 'expires_date'
      f = $('#from').val()
      t = $('#to').val()
      if !_.isEmpty(f) && !_.isEmpty(t)
        @triggerMethod('filter:change',
          type: type, value: "#{f}:#{t}"
        )
    else
      @triggerMethod('filter:change',
        type: type, value: $(event.target).val()
      )
