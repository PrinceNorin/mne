module Taxes
  class DataService
    attr_accessor :taxes, :tax_type

    def initialize(taxes, tax_type)
      @taxes, @tax_type = taxes, tax_type
    end

    def to_data
      company_taxes = taxes.group_by { |tax| tax.license.company.name }
      company_taxes.inject({}) do |h, (name, taxes)|
        taxes = taxes.sort_by { |tax| tax.send(sort_key) }
        if tax_type == 'env_recovery_fee'
          taxes = taxes.group_by(&:year)
          taxes_json = combine_env_fee(taxes)
        elsif Tax::ONE_TIME_FEE_TYPES.include?(tax_type)
          taxes_json = tax_json(taxes)
        else
          taxes = taxes.group_by(&:year)
          taxes_json = combine_duties_fee(taxes)
        end
        h.merge(name => taxes_json)
      end
    end

    private

    def combine_env_fee(year_taxes)
      year_taxes.map do |_, taxes|
        tax = taxes[0]
        json = tax_json(tax)
        json['unit_1'] = tax.unit
        json['unit_2'] = taxes[1].unit
        json['total'] = taxes.sum(&:total)
        json
      end
    end

    def combine_duties_fee(year_taxes)
      year_taxes.keys.sort.inject({}) do |h, year|
        taxes = year_taxes[year]
        h.merge!(year => tax_json(taxes))
      end
    end

    def tax_json(tax_or_taxes)
      tax_or_taxes.as_json(include: :license, methods: [:year, :month])
    end

    def sort_key
      @_sort_key ||= ((
        Tax::ONE_TIME_FEE_TYPES + ['env_recovery_fee_1']
        ).include?(tax_type) ? :year : :month
      )
    end
  end
end
