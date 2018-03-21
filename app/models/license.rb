class License < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  enum area_unit: %i[m2 ha]
  enum status: %i[active resolving inactive]
  enum province: I18n.t('provinces').keys
  enum license_type: %i[const_sand stone stale_stone shallow]

  validates_presence_of :number, :area,
    :owner_name, :company_name,
    :issued_date, :expires_date

  validates_uniqueness_of :number
  validates_numericality_of :area
end
