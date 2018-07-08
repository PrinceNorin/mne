class License < ApplicationRecord
  include Selectable
  include Searchable

  has_paper_trail
  acts_as_paranoid

  paginates_per 500

  enum area_unit: %i[ha m2]
  enum status: %i[active dispute suspense archived]
  enum province: I18n.t('provinces').keys

  selectable_fields :status, :province, :area_unit

  before_save :clean_data

  belongs_to :company
  belongs_to :category
  has_many :taxes, dependent: :destroy
  has_many :statements, dependent: :destroy
  has_one :business_plan, dependent: :destroy

  validate :number_uniqueness
  validates :number, presence: true

  validates :total_area,
    presence: true,
    numericality: true

  validates :business_address,
    presence: true

  validates :company_name,
    presence: true

  validates :category_name,
    presence: true

  validates :issue_at,
    presence: true

  validates :expire_at,
    presence: true

  validates :valid_at,
    presence: true

  validate :valid_at, if: -> { valid_at && expire_at } do
    if valid_at >= expire_at
      errors.add(:valid_at, :must_be_less_than)
      errors.add(:expires_at, :must_be_greater_than)
    end
  end

  scope :nearly_expires, -> do
    from = 1.month.ago
    to = 3.months.from_now
    where(expire_at: from..to)
  end

  scope :unique_by_latest_expires_date, -> do
    join_sql = <<-SQL
      LEFT JOIN `licenses` l2 ON (
        `licenses`.`company_id` = `l2`.`company_id` AND
        `licenses`.`expire_at` < `l2`.`expire_at` AND
        `licenses`.`category_id` = `l2`.`category_id` AND
        `licenses`.`province` = `l2`.`province`
      )
    SQL

    joins(join_sql).where('`l2`.`id` IS NULL')
  end

  scope :expires, -> do
    where('expire_at < ? AND status != ?',
      Date.current, statuses[:archived])
  end

  searchable_scope :year_eq, ->(year) do
    start_date = Date.parse("#{year}-01-01")
    end_date = start_date.end_of_year
    where(issue_at: start_date..end_date)
  end

  searchable_scope :valid_year_from, ->(year) do
    where('valid_at >= ?', Date.parse("#{year}-01-01"))
  end

  searchable_scope :valid_year_to, ->(year) do
    date = Date.parse("#{year}-01-01")
    where('valid_at <= ?', date.end_of_year)
  end

  def d_business_address
    t_province = I18n.t("provinces.#{province}")
    if province == 'phnom_penh'
      t_province = "ក្រុង#{t_province}"
    else
      t_province = "ខេត្ត#{t_province}"
    end

    if business_address.include?(t_province)
      business_address
    else
      "#{business_address} #{t_province}"
    end
  end

  def better_area
    "%g" % ("%f" % total_area)
  end

  private

  def number_uniqueness
    now = self.issue_at || Date.current
    from = now.beginning_of_year
    to = now.end_of_year
    if (number_changed? || issue_at_changed?) && self.class.exists?(number: self.number, issue_at: from..to)
      errors.add(:number, :taken)
    end
  end

  def clean_data
    self.number = number.strip
  end
end
