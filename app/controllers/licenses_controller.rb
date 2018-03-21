class LicensesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_license, only: [:show, :edit, :update, :destroy]

  def index
    scope = License.order(created_at: :desc)
    if (query = query_params).present?
      scope = scope.where(query)
    end

    per_page = params[:per_page] || Settings.pagination.per_page
    @licenses = scope.page(params[:page])
      .per(per_page)
    render json: {
      data: @licenses,
      per_page: per_page,
      total_pages: @licenses.total_pages,
      total_entries: @licenses.total_count,
      current_page: @licenses.current_page
    }
  end

  def show
    render json: @license
  end

  def create
    @license = License.new(license_params)
    if @license.save
      render json: @license
    else
      render json: @license.errors, status: :unprocessable_entity
    end
  end

  def update
    if @license.update_attributes(license_params)
      render json: @license
    else
      render json: @license.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @license.destroy
    render json: { message: 'success' }
  end

  private

  def set_license
    @license = License.find(params[:id])
  end

  def license_params
    params.require(:license).permit(
      :number, :status, :area, :area_unit, :province, :issued_date, :note,
      :expires_date, :address, :company_name, :owner_name, :license_type
    )
  end

  def query_params
    if params[:q] && params[:t]
      type = params[:t].to_sym
      value =
        case type
        when :issued_date, :expires_date
          f, t = params[:q].split(':')
          Date.parse(f)..Date.parse(t)
        else
          params[:q]
        end
      { type => value }
    end
  end
end
