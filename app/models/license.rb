class License < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  paginates_per 100

  enum area_unit: %i[m2 ha]
  enum status: %i[active resolving inactive]
  enum province: I18n.t('provinces').keys
  enum license_type: %i[const_sand stone stale_stone shallow]

  validates_presence_of :number, :area, :address,
    :company_name, :issued_date, :expires_date

  validate :number_uniqueness

  validates_numericality_of :area

  validate :issued_date, if: -> { issued_date && expires_date } do
    if issued_date >= expires_date
      errors.add(:issued_date, :must_be_less_than, other: License.human_attribute_name(:expires_date))
      errors.add(:expires_date, :must_be_greater_than, other: License.human_attribute_name(:issued_date))
    end
  end

  has_many :statements, dependent: :destroy

  def company_or_owner_name
    if owner_name.present?
      "#{company_name}/#{owner_name}"
    else
      company_name
    end
  end

  def better_area
    "%g" % ("%f" % area)
  end

  class << self
    %w(license_type status province area_unit).each do |name|
      define_method "#{name}_select" do
        plural_name = name.pluralize.to_sym
        self.public_send(plural_name).map do |key, _|
          [I18n.t("#{plural_name}.#{key}"), key]
        end
      end

      define_method "#{name}_search_select" do
        plural_name = name.pluralize.to_sym
        self.public_send(plural_name).map do |key, value|
          [I18n.t("#{plural_name}.#{key}"), value]
        end
      end
    end
  end

  private

  def number_uniqueness
    now = self.issued_date || Date.current
    from = now.beginning_of_year
    to = now.end_of_year
    if number_changed? && self.class.exists?(number: self.number, issued_date: from..to)
      errors.add(:number, :taken)
    end
  end
end
