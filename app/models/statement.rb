class Statement < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  enum statement_type: %i[dispute suspense resolved]

  belongs_to :license
  belongs_to :reference,
    optional: true,
    class_name: 'Statement',
    foreign_key: 'reference_id'

  validates_uniqueness_of :number
  validates_uniqueness_of :reference_id, allow_nil: true
  validates_presence_of :issued_date, :number, :statement_type
  validates_presence_of :reference, unless: :dispute?

  after_save :change_license_status

  private

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
