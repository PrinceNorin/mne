class App.Views.Layout extends Backbone.Marionette.View
  template: JST['layout']

  templateContext: ->
    locale =
      if I18n.locale == 'en'
        'km'
      else
        'en'

    query = window.location.search
    url = window.location.pathname
    if _.isEmpty(query)
      url += "?locale=#{locale}"
    else
      url += "#{query}&locale=#{locale}"

    langUrl: url
    user: window.user
    token: window.csrfToken
    lang: I18n.t("#{locale}_lang")
