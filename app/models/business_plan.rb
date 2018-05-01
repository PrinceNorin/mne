class BusinessPlan < ApplicationRecord
  serialize :content, Array
  enum currency: %i[riel dollar]

  belongs_to :license

  validates_presence_of :budget, :currency
  validates_numericality_of :budget, greater_than: 0
  validates_numericality_of :employees,
    greater_than: 0,
    only_integer: true,
    if: -> { employees.present? }

  def contents
    @contents ||= content.map { |attrs| BusinessPlanDetails.new(attrs) }
  end

  def contents_attributes=(contents)
    self.content = contents.map { |_, attrs| attrs }
  end

  def self.currency_select
    currencies.map do |key, _|
      [I18n.t("currencies.#{key}"), key]
    end
  end

  def initialize_content!(from, to)
    self.content = (from..to).map { |year| { year: year } }
  end

  def valid?(context = nil)
    super && contents_valid?
  end

  private

  def contents_valid?
    contents.any? { |c| c.valid? }
  end
end
