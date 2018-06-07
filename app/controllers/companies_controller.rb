class CompaniesController < ApplicationController
  def index
    @companies = License.all.group_by(&:company_name).map do |k, v|
      { name: k, ids: v.map(&:id) }
    end
  end

  def show
    respond_to do |format|
      format.js { @licenses = License.where(id: params[:ids].split(',').map(&:strip)) }
    end
  end
end
