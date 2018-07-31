class Category < ApplicationRecord
  has_many :licenses

  validates :name,
    presence: true,
    uniqueness: true

  validates :tax_rate,
    presence: true,
    numericality: true
end
