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
    :company_name, :issued_date, :expires_date, :valid_date

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
  has_many :taxes, dependent: :destroy

  before_save :clean_data

  scope :year_eq, ->(year) do
    start_date = Date.parse("#{year}-01-01")
    end_date = start_date.end_of_year
    where(issued_date: start_date..end_date)
  end

  scope :nearly_expires, -> do
    from = 1.week.ago
    to = 3.months.from_now
    where(expires_date: from..to)
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
        company_name owner_name number issued_date
        license_type area address
        valid_date expires_date status note
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

    def to_plan_csv
      columns = %w(
        company_name owner_name number issued_date
        license_type area address
        valid_date expires_date
      ).map { |col| I18n.t("activerecord.attributes.license.#{col}") }

      licenses = all.includes(:business_plan)
      years = licenses.map do |license|
        plan = license.business_plan
        plan.contents.map(&:year) if plan.present?
      end.compact.flatten

      if years.empty?
        path = Rails.root.join('tmp', "licenses_#{Time.now.to_i}.csv").to_s
        File.new(path, 'w+:UTF-16LE:UTF-8').close
        return path
      end

      year_cols = (years.min..years.max).to_a
      columns += year_cols
      columns += [
        I18n.t('activerecord.attributes.business_plan.budget'),
        I18n.t('activerecord.attributes.business_plan.employees')
      ]

      path = Rails.root.join('tmp', "licenses_#{Time.now.to_i}.csv").to_s
      File.open(path, 'w+:UTF-16LE:UTF-8') do |file|
        data = CSV.generate(col_sep: "\t") do |csv|
          csv << columns
          licenses.each do |license|
            csv << plan_csv_data(license, year_cols)
          end
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
        license.company_name, license.owner_name, license.number,
        I18n.l(license.issued_date, format: '%d, %b %Y'),
        I18n.t("license_types.#{license.license_type}"),
        "#{license.area} #{I18n.t('area_units.' + license.area_unit)}",
        "#{license.address} ខេត្ត#{I18n.t("provinces.#{license.province}")}",
        I18n.l(license.valid_date, format: '%d, %b %Y'),
        I18n.l(license.expires_date, format: '%d, %b %Y'),
        I18n.t("statuses.#{license.status}"),
        license.note
      ]
    end

    def plan_csv_data(license, years)
      row = csv_data(license)[0..-3]
      plan = license.business_plan

      if plan.present?
        row += years.map do |year|
          content = content_from_year(plan, year)
          content.try(:plan)
        end

        row += [
          [plan.budget, I18n.t("currencies.#{plan.currency}")].join(' '),
          plan.employees
        ]
      else
        row += years.map { |_| '' }
        row += ['', '']
      end
    end

    def content_from_year(plan, year)
      plan.contents.find { |content| content.year == year }
    end
  end

  private

  def number_uniqueness
    now = self.issued_date || Date.current
    from = now.beginning_of_year
    to = now.end_of_year
    if (number_changed? || issued_date_changed?) && self.class.exists?(number: self.number, issued_date: from..to)
      errors.add(:number, :taken)
    end
  end

  def clean_data
    self.number = number.strip
    self.company_name = company_name.strip
    self.owner_name = owner_name.strip
  end
end
