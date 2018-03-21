class App.Models.License extends Backbone.Model
  urlRoot: '/licenses'

  validation:
    number:
      required: true
      msg: I18n.t('errors.messages.blank')
    area: [
      {
        required: true,
        msg: I18n.t('errors.messages.blank')
      },
      {
        pattern: 'number',
        msg: I18n.t('errors.messages.not_a_number')
      }
    ]
    owner_name:
      required: true
      msg: I18n.t('errors.messages.blank')
    company_name:
      required: true
      msg: I18n.t('errors.messages.blank')
    issued_date:
      required: true
      msg: I18n.t('errors.messages.blank')
    expires_date:
      required: true
      msg: I18n.t('errors.messages.blank')

  defaults:
    area_unit: 'm2'
    province: 'phnom_penh'
    license_type: 'const_sand'
