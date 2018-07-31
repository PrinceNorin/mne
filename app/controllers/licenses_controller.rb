class LicensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_license, only: [:show, :edit, :update, :destroy]

  def index
    scope = License.includes(:business_plan)

    @nearly_expires_licenses = scope.nearly_expires
      .page(params[:page])
      .order(created_at: :desc)
    nearly_expire_ids = @nearly_expires_licenses.map(&:id)

    # @expired_licenses = scope.expired.where.not(id: nearly_expire_ids)
    #   .page(params[:page])
    #   .per(params[:per_page])
    #   .order(created_at: :desc)
    # expired_ids = @expired_licenses.map(&:id)

    # @licenses = scope.where.not(id: (nearly_expire_ids + expired_ids).uniq)
    @licenses = scope.where.not(id: nearly_expire_ids)
      .page(params[:page])
      .per(params[:per_page])
      .order(created_at: :desc)
  end

  def show
    # @taxes = @license.taxes.duties.order(:from)
    # type_taxes = @taxes.group_by(&:tax_type)

    # @type_taxes = {}
    # type_taxes.each do |t, taxes|
    #   @type_taxes[t] = taxes.group_by(&:year)
    # end

    # if @taxes.any?
    #   @current_type = @type_taxes.keys.first
    #   @current_year = Date.current.year

    #   unless @type_taxes[@current_type][@current_year]
    #     @current_year = @type_taxes[@current_type].keys.first
    #   end
    # end
  end

  def new
    @license = License.new
  end

  def create
    @license = Licenses::CreateService.new(license_params).create
    if @license.errors.any? || @license.company.errors.any?
      render :new
    else
      redirect_to licenses_path, success: t('flash.create_success')
    end
  end

  def edit
  end

  def update
    @license = Licenses::UpdateService.new(@license, license_params).update
    if @license.errors.any? || @license.company.errors.any?
      render :edit
    else
      redirect_to licenses_path, success: t('flash.update_success')
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
      :category_id, :number, :total_area, :area_unit,
      :province, :valid_at, :issue_at, :business_address,
      :note, :expire_at, :company_name, :owner_name
    )
  end
end
