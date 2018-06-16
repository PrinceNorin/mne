class CompaniesController < ApplicationController
  def index
    @companies = Company.order(:name)
  end

  def show
    respond_to do |format|
      format.js do
        @licenses = License.where(company_id: params[:id])
      end
    end
  end
end
