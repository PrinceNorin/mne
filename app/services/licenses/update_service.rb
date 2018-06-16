module Licenses
  class UpdateService
    attr_reader :license, :params

    def initialize(license, params)
      @license, @params = license, params
    end

    def update
      License.transaction do
        license.assign_attributes(params)
        license.company = find_or_create_company
        category = Category.find_by(id: params[:category_id])
        license.category_name = category.name if category.present?
        raise ActiveRecord::Rollback unless license.save
      end
      license
    end

    private

    def find_or_create_company
      company = Company.find_by(name: params[:company_name])
      if company.nil?
        company = Company.create(
          name: params[:company_name],
          owner: params[:owner_name],
          business_address: params[:address]
        )
      end
      company
    end
  end
end
