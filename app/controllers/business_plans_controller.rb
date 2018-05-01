class BusinessPlansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_license
  before_action :set_business_plan, only: [:show, :create, :update]

  def show
  end

  def create
    do_save_business_plan
  end

  def update
    do_save_business_plan
  end

  private

  def do_save_business_plan
    @business_plan.assign_attributes(business_plan_params)
    if @business_plan.save
      redirect_to licenses_path
    else
      render :show
    end
  end

  def business_plan_params
    params.require(:business_plan).permit(
      :budget, :currency, :note, :employees,
      contents_attributes: [:year, :plan]
    )
  end

  def set_license
    @license = License.find(params[:license_id])
  end

  def set_business_plan
    @business_plan = @license.business_plan
    if @business_plan.nil?
      @business_plan=  @license.build_business_plan
      @business_plan.initialize_content!(@license.issued_date.year, @license.expires_date.year)
    end
  end
end
