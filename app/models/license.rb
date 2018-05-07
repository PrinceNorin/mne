require 'csv'

class License < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  paginates_per 500

  enum area_unit: %i[ha m2]
  enum status: %i[active dispute suspense archived]
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
  has_one :business_plan, dependent: :destroy

  scope :year_eq, ->(year) do
    start_date = Date.parse("#{year}-01-01")
    end_date = start_date.end_of_year
    where(issued_date: start_date..end_date)
  end

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

    def to_csv
      columns = %w(
        number company_name owner_name area
        address province license_type issued_date
        expires_date status note
      ).map { |col| I18n.t("activerecord.attributes.license.#{col}") }

      path = Rails.root.join('tmp', "licenses_#{Time.now.to_i}.csv").to_s
      File.open(path, 'w+:UTF-16LE:UTF-8') do |file|
        data = CSV.generate(col_sep: "\t") do |csv|
          csv << columns
          all.each { |license| csv << csv_data(license) }
        end

        file.write("\xEF\xBB\xBF")
        file.write(data)
      end

      path
    end

    def ransackable_scopes(auth = nil)
      [:year_eq]
    end

    private

    def csv_data(license)
      data = [
        license.number, license.company_name, license.owner_name,
        "#{license.area} #{I18n.t('area_units.' + license.area_unit)}",
        license.address, I18n.t("provinces.#{license.province}"),
        I18n.t("license_types.#{license.license_type}"),
        license.issued_date.strftime('%Y/%m/%d'),
        license.expires_date.strftime('%Y/%m/%d'),
        I18n.t("statuses.#{license.status}"),
        license.note
      ]
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
