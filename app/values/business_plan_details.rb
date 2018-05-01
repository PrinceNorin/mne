class BusinessPlanDetails
  include ActiveModel::Model

  attr_accessor :year, :plan

  validates_presence_of :year, :plan
  validates_numericality_of :year, only_integer: true

  def initialize(hash)
    assign_attributes!(hash)
  end

  def persisted?
    false
  end

  private

  def assign_attributes!(hash)
    hash.each do |attr, value|
      unless allow_attributes.include?(attr.to_sym)
        fail "Attribute '#{attr}' is not allowed"
      end
      public_send("#{attr}=", value)
    end
  end

  def allow_attributes
    %i[year plan]
  end
end
