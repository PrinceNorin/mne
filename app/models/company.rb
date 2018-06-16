class Company < ApplicationRecord
  has_many :licenses

  validates :name,
    presence: true,
    uniqueness: true

  validates :business_address,
    presence: true
end
