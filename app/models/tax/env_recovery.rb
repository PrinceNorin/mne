class Tax
  class EnvRecovery
    include ActiveModel::Model

    attr_accessor(
      :unit_1, :unit_2,
      :total_1, :total_2,
      :tax_rate, :tax_type
    )

    validates_presence_of(
      :unit_1, :unit_2,
      :total_1, :total_2
    )

    validates_numericality_of(
      :unit_1, :unit_2,
      :total_1, :total_2
    )

    def persisted?
      false
    end
  end
end
