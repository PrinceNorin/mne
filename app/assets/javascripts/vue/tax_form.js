$(document).ready(function() {
  if (!document.getElementById('taxForm')) {
    return;
  }

  const EXCLUDE_TAX_TYPES = [
    'license_fee',
    'total_area_fee',
    'env_recovery_fee'
  ];

  new Vue({
    engine: null,
    typeahead: null,
    companies: [],
    el: '#taxForm',

    data: {
      I18n: I18n,
      companyTaxes: {},
      showCompanyList: [],
      shouldShowYear: true,
      filter: {
        tax_type: 'loyalty',
        year: (new Date().getFullYear()),
        company_id: null
      }
    },

    beforeCreate: function() {
      var self = this;

      $.ajax({
        method: 'get',
        url: '/companies.json',
        success: function(res) {
          self.companies = res;
          self._initEngine(res);
        }
      });
    },

    mounted: function() {
      this._initEngine([]);
      this._initTypeahead();
    },

    methods: {
      fetchTax: function() {
        let self = this;
        let filter = _.pickBy(this.filter, function(value, key) {
          if (key === 'year') {
            return self.shouldShowYear && value !== 0;
          }
          return true;
        });

        $.ajax({
          method: 'get',
          data: filter,
          url: '/taxes.json',
          success: function(res) {
            self._splitTaxesIntoGroup(res);
          }
        });
      },

      downloadTax: function() {
        let self = this;
        let filter = _.pickBy(this.filter, function(value, key) {
          if (key === 'year') {
            return self.shouldShowYear && value !== 0;
          }
          return true;
        });

        window.location.href = '/taxes.xlsx?' + $.param(filter);
      },

      clearData: function() {
        this.companyTaxes = {};
        this.showCompanyList = [];
        this.shouldShowYear = EXCLUDE_TAX_TYPES.indexOf(this.filter.tax_type) === -1;
      },

      hasCompanyTaxes: function() {
        return !_.isEmpty(this.companyTaxes);
      },

      setCompany: function(event) {
        let val = event.target.value;
        if (_.isEmpty(val)) {
          this.filter.company_id = null;
          return
        }

        let company = _.find(this.companies, function(c) {
          return c.name === val;
        });
        this.filter.company_id = company ? company.id : 0;
      },

      calculateTotal: function(taxes, propName) {
        return _.sumBy(taxes, function(tax) {
          return parseFloat(tax[propName]);
        });
      },

      isMonthlyTaxType: function() {
        return !_.includes(EXCLUDE_TAX_TYPES, this.filter.tax_type);
      },

      yearRange: function(tax) {
        let fromDate = new Date(tax.from);
        let toDate = new Date(tax.to);
        return [fromDate.getFullYear(), toDate.getFullYear()].join(' - ');
      },

      toggleTable: function(event, company) {
        event.preventDefault();
        if (this.showTable(company)) {
          this.showCompanyList = _.filter(this.showCompanyList, function(name) {
            return name !== company;
          });
        } else {
          this.showCompanyList.push(company);
        }
      },

      showTable: function(company) {
        return _.includes(this.showCompanyList, company);
      },

      _initEngine(companies) {
        if (this.engine) {
          this.engine.clear();
          this.engine.local = companies;
          this.engine.initialize(true);
        } else {
          this.engine = new Bloodhound({
            local: companies,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            datumTokenizer: function(c) {
              return Bloodhound.tokenizers.whitespace(c.name);
            },
            identify: function(c) {
              return c.name;
            }
          });
        }
      },

      _initTypeahead: function() {
        var self = this;

        this.typeahead = $(this.$el).find('input').typeahead({
          hint: false,
          minLength: 2,
          highlight: true,
          classNames: {
            input: 'form-control'
          }
        }, {
          name: 'companies',
          source: this.engine,
          display: 'name'
        });

        this.typeahead.on('typeahead:select', function(event, company) {
          self.filter.company_id = company.id;
        });
      },

      _splitTaxesIntoGroup: function(taxes) {
        this.companyTaxes = taxes;
        console.log(taxes)
        // let self = this;
        // let companyTaxes = _.groupBy(taxes, function(tax) {
        //   return tax.company_name;
        // });

        // let propName = this.isMonthlyTaxType() ? 'month' : 'year';
        // _.forEach(companyTaxes, function(taxes, company) {
        //   let newTaxes = _.sortBy(taxes, propName);
        //   if (self.filter.tax_type === 'env_recovery_fee') {
        //     newTaxes = _.groupBy(newTaxes, 'year');
        //     newTaxes = _.map(newTaxes, function(taxes) {
        //       let tax = taxes[0];
        //       tax.unit1 = tax.unit;
        //       tax.unit2 = taxes[1].unit;
        //       tax.total = _.sumBy(taxes, function(t) { return parseFloat(t.total) });
        //       return tax;
        //     });
        //   }
        //   companyTaxes[company] = newTaxes;
        // });
        // console.log(companyTaxes)

        // this.companyTaxes = companyTaxes;
      }
    }
  })
});
