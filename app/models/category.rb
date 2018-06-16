class Category < ApplicationRecord
  has_many :licenses

  validates :name,
    presence: true,
    uniqueness: true
end
