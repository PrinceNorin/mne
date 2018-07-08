class Company < ApplicationRecord
  has_many :licenses
  has_many :taxes, through: :licenses

  validates :name,
    presence: true,
    uniqueness: true
end
