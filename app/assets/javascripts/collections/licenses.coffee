class App.Collections.Licenses extends Backbone.PageableCollection
  url: '/licenses'
  model: App.Models.License

  state:
    pageSize: null
    currentPage: 1

  parseRecords: (res) ->
    res.data

  parseState: (res) ->
    pageSize: parseInt(res.per_page)
    totalPages: parseInt(res.total_pages)
    currentPage: parseInt(res.current_page)
    totalRecords: parseInt(res.total_entries)
