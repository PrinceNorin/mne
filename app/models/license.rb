require 'csv'

class License < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  paginates_per 500

  enum area_unit: %i[ha m2]
  enum status: %i[active dispute suspense archived]
  enum province: I18n.t('provinces').keys
  enum license_type: %i[const_sand stone stale_stone shallow]

  belongs_to :company
  belongs_to :category

  validates_presence_of :number, :area,
    :address, :category_name, :company_name,
    :issued_date, :expires_date, :valid_date

  validate :number_uniqueness

  validates_numericality_of :area

  validate :valid_date, if: -> { valid_date && expires_date } do
    if valid_date >= expires_date
      errors.add(:valid_date, :must_be_less_than)
      errors.add(:expires_date, :must_be_greater_than)
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

  scope :unique_by_latest_expires_date, -> do
    join_sql = <<-SQL
      LEFT JOIN `licenses` l2 ON (
        `licenses`.`company_id` = `l2`.`company_id` AND
        `licenses`.`expires_date` < `l2`.`expires_date`
      )
    SQL

    joins(join_sql).where('`l2`.id IS NULL')
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

    def ransackable_scopes(auth = nil)
      [:year_eq]
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
    self.owner_name = owner_name.strip if owner_name
  end
end
