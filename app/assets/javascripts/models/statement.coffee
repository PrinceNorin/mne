class App.Models.Statement extends Backbone.Model
  url: ->
    url = "/api/licenses/#{@get('license_id')}/statements"
    url += "/#{@get('id')}" if @get('id') != undefined
    url

  validation:
    number:
      required: true
      msg: I18n.t('errors.messages.blank')
    license_id:
      required: true
      msg: I18n.t('errors.messages.blank')
    issued_date:
      required: true
      msg: I18n.t('errors.messages.blank')

  defaults:
    statement_type: 'dispute'
