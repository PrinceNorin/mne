class Tax < ApplicationRecord
  belongs_to :license

  enum tax_type: %i[cat_1 cat_2 cat_3 cat_4 cat_5]
  enum month: %i[jan feb mar apr may jun jul aug sep oct nov dec]

  validates_presence_of :unit, :total, :year, :month, :tax_type
  validates_numericality_of :unit, :total
  validates_numericality_of :year, only_integer: true

  class << self
    def month_select
      months.map { |key, _| [I18n.t("months.#{key}"), key] }
    end

    def tax_type_select
      tax_types.map do |key, value|
        [I18n.t("tax_types.#{key}"), key]
      end
    end
  end
end
