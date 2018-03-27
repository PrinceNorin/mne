class App.Views.LicenseRow extends Backbone.Marionette.View
  tagName: 'tr'
  className: 'pointer'
  template: JST['licenses/table/row']

  modelEvents:
    'change': 'render'
    'reset': 'render'

  triggers:
    'click td': 'license:show'
    'click #btnEdit': 'license:edit'
    'click #btnDelete': 'license:delete'

  templateContext: =>
    statusClasses =
      active: 'success'
      inactive: 'danger'
      resolving: 'warning'

    statusClass: statusClasses[@model.get('status')]

class App.Views.LicenseTableBody extends Backbone.Marionette.CollectionView
  tagName: 'tbody'
  childView: App.Views.LicenseRow
  emptyView: App.Views.EmptyLicense

  childViewTriggers:
    'license:show': 'license:show'
    'license:edit': 'license:edit'
    'license:delete': 'license:delete'


class App.Views.LicenseTable extends Backbone.Marionette.View
  tagName: 'table'
  template: JST['licenses/table/index']
  className: 'table table-bordered table-hover'

  childViewTriggers:
    'license:show': 'license:show'
    'license:edit': 'license:edit'
    'license:delete': 'license:delete'

  regions:
    body:
      el: 'tbody'
      replaceElement: true

  onRender: ->
    @showChildView('body', new App.Views.LicenseTableBody(
      collection: @collection
    ))



