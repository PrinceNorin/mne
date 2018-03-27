class App.Views.IndexLicenses extends Backbone.Marionette.View
  template: JST['licenses/index']

  regions:
    table:
      el: 'table'
      replaceElement: true
    showBtnGroup:
      el: '#showBtnGroup'
      replaceElement: true
    filterBtnGroup:
      el: '#filterBtnGroup'
      replaceElement: true
    pagination:
      el: '#pagination'
      replaceElement: true

  events:
    'click #btnNew': 'showNew'
    'submit .search': 'search'

  childViewEvents:
    'license:show': 'showLicense'
    'license:edit': 'showEditForm'
    'license:delete': 'deleteLicense'
    'filter:click': 'updateFilter'
    'filter:change': 'filter'
    'show:change': 'changeShow'
    'page:change': 'changePage'

  initialize: ->
    @query = {}
    @listenTo @collection, 'pageable:state:change', @renderPagination

  onRender: ->
    @showChildView('table', new App.Views.LicenseTable(
      collection: @collection
    ))

    @renderShowButton()
    @renderPagination()
    @renderFilterButton('all', 'All')

  search: (event) ->
    event.preventDefault()

    value = @$el.find('input[name=q]').val()
    if _.isEmpty(value)
      @collection.getFirstPage()
    else
      @collection.getFirstPage(
        data:
          t: 'number'
          q: value
      )

  updateFilter: (type, text) ->
    @renderFilterButton(type, text)

  filter: (query) ->
    if _.isEmpty(query)
      @query = {}
      @collection.getFirstPage()
    else
      @query = _.extend({}, @query, {
        t: query.type,
        q: query.value
      })

      @collection.getFirstPage(data: _.clone(@query))

  changePage: (page) ->
    @collection.getPage(page, data: _.clone(@query))

  changeShow: (perPage) ->
    @collection.setPageSize(perPage, first: true, data: _.clone(@query)).done =>
      @renderShowButton()

  showNew: ->
    App.router.navigate('/licenses/new', trigger: true)

  showLicense: (childView) ->
    App.router.navigate("/licenses/#{childView.model.id}", trigger: true)

  showEditForm: (childView) ->
    App.router.navigate("/licenses/#{childView.model.id}/edit", trigger: true)

  deleteLicense: (childView) ->
    @askForConfirm =>
      $btn = childView.$el.find('#btnDelete')
      html = $btn.html()
      $btn.html('<i class="fa fa-spinner fa-spin"></i>')
      childView.model.destroy(
        wait: true
        success: =>
          new Noty(
            type: 'success'
            timeout: 3000
            text: I18n.t('flash.destroy_success')
          ).show()
        error: =>
          $btn.html(html)
          new Noty(
            type: 'error'
            timeout: 3000
            text: I18n.t('something_went_wrong')
          ).show()
      )

  askForConfirm: (success) ->
    swal(
      icon: 'warning'
      dangerMode: true
      buttons: [true, I18n.t('delete')]
      title: I18n.t('are_you_sure')
      text: I18n.t('do_you_want_to_delete')
    ).then (value) => success() if value

  renderShowButton: ->
    @showChildView('showBtnGroup', new App.Views.ShowLicenseButtonGroup(
      perPage: @collection.state.pageSize
    ))

  renderFilterButton: (type, text) ->
    @showChildView('filterBtnGroup', new App.Views.FilterLicenseButtonGroup(
      type: type, text: text
    ))

  renderPagination: ->
    @showChildView('pagination', new App.Views.Pagination(
      total: @collection.state.totalPages
      page: @collection.state.currentPage
    ))
