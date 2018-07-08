class Tax < ApplicationRecord
  include Selectable

  TAX_TYPES = %i[
    loyalty
    aditional_duty
    training_duty
    social_duty
    license_fee
    total_area_fee
    env_recovery_fee
    env_recovery_fee_1
  ].freeze

  DUTY_TYPES = %i[
    loyalty
    aditional_duty
    training_duty
    social_duty
  ].freeze

  RATES = {
    'loyalty' => 0.25,
    'aditional_duty' => 0.4,
    'training_duty' => 0.02,
    'social_duty' => 0.01,
    'env_recovery_fee' => 2500,
    'env_recovery_fee_1' => 2500
  }.freeze

  TOTAL_AREA_RATES = {
    'ថ្ម' => 50,
    'ថ្មអារ' => 50,
    'អាចម៍ដី' => 30,
    'ដីក្រហម' => 30,
    'ខ្សាច់​' => 30,
    'ខ្សាច់បក' => 30,
    'ខ្សាច់សំណង់' => 30
  }.freeze

  ONE_TIME_FEE_TYPES = %w(
    license_fee
    total_area_fee
    env_recovery_fee
  ).freeze

  CONVERTABLE_UNIT_TYPES = %W(
    total_area_fee
    env_recovery_fee
  ).freeze

  SQRT_M_PER_HA = 10_000
  LICENSE_FEE_RATE = 10_000_000

  attr_accessor :year, :month

  belongs_to :license

  enum tax_type: TAX_TYPES
  selectable_fields :tax_type

  validates :total,
    presence: true,
    numericality: true

  with_options if: -> { tax_type != 'license_fee' } do
    validates :rate,
      presence: true,
      numericality: true

    validates :unit,
      presence: true,
      numericality: true
  end

  before_validation do
    next unless unit.nil?
    self.unit = tax_unit
  end

  before_validation do
    next unless rate.nil?
    self.rate = tax_rate
  end

  before_validation do
    if ONE_TIME_FEE_TYPES.include?(tax_type) || tax_type == 'env_recovery_fee_1'
      self.from = license.valid_at
      self.to = license.expire_at
    else
      if from.nil? && year.present? && month.present?
        self.from = Date.parse("#{year}-#{month}-01")
      end

      if from.present? && to.nil?
        self.to = from.end_of_month
      end
    end
  end

  scope :duties, -> { where.not(tax_type: ONE_TIME_FEE_TYPES + ['env_recovery_fee_1']) }

  def self.tax_rate(tax_type)
    new(tax_type: tax_type).tax_rate
  end

  def self.selectable_duty_types
    DUTY_TYPES.map do |type|
      [I18n.t("tax_types.#{type}"), type.to_s]
    end
  end

  def year
    @year ||= from.try(:year)
  end

  def month
    @month ||= from.try(:month)
  end

  def tax_rate
    case tax_type
    when 'license_fee'
      LICENSE_FEE_RATE
    when 'total_area_fee'
      TOTAL_AREA_RATES[license.category.name]
    else
      RATES[tax_type]
    end
  end

  def tax_unit
    if tax_type == 'license_fee'
      1
    elsif tax_type == 'total_area_fee'
      unit = license.total_area
      if license.area_unit == 'm2'
        unit = unit / SQRT_M_PER_HA.to_f
      end
      unit
    end
  end
end
