class LicensesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_license, only: [:show, :edit, :update, :destroy]

  def index
    @licenses = License.order(created_at: :desc).page(params[:page]).per(params[:per_page])
  end

  def show
  end

  def new
    @license = License.new
  end

  def create
    @license = License.new(license_params)
    if @license.save
      redirect_to licenses_path, success: t('flash.create_success')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @license.update_attributes(license_params)
      redirect_to licenses_path, success: t('flash.update_success')
    else
      render :edit
    end
  end

  def destroy
    @license.destroy
    redirect_to licenses_path, success: t('flash.delete_success')
  end

  private

  def set_license
    @license = License.find(params[:id])
  end

  def license_params
    params.require(:license).permit(
      :number, :area, :area_unit, :province, :issued_date, :address,
      :note, :expires_date, :company_name, :owner_name, :license_type
    )
  end
end
