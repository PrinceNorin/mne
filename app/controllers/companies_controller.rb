class CompaniesController < ApplicationController
  def index
    @companies = Company.order(:name)
    respond_to do |format|
      format.html
      format.json { render json: @companies }
    end
  end

  def show
    respond_to do |format|
      format.js do
        @licenses = License.where(company_id: params[:id])
      end
    end
  end
end
