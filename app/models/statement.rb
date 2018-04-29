class Statement < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  enum statement_type: %i[dispute suspense resolved]

  belongs_to :license
  belongs_to :reference,
    optional: true,
    class_name: 'Statement',
    foreign_key: 'reference_id'

  validate :number_uniqueness
  validates_uniqueness_of :reference_id, allow_nil: true
  validates_presence_of :issued_date, :number, :statement_type
  validates_presence_of :reference, unless: :dispute?

  after_save :change_license_status

  def self.statement_type_select
    statement_types.map do |key, _|
      [I18n.t("statement_types.#{key}"), key]
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

  def change_license_status
    license_status =
      case statement_type.to_sym
      when :dispute then :resolving
      when :suspense then :inactive
      when :resolved then :active
      end
    license.update_attributes(status: license_status) if license_status
  end
end
