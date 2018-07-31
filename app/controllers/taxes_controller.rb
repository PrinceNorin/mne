class TaxesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_license, except: [:index]
  before_action :set_tax, only: [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: search_result }
      format.xlsx do
        if !Tax::ONE_TIME_FEE_TYPES.include?(params[:tax_type])
          path = Taxes::MonthlyXlsxService.new(search_result).to_xlsx
        else
          path = Taxes::OneTimeXlsxService.new(search_result, params[:tax_type]).to_xlsx
        end

        data = File.read(path)
        send_data data, filename: "#{t('tax_types.' + params[:tax_type])}.xlsx"
        FileUtils.rm path
      end
    end
  end

  def new
    Tax::ONE_TIME_FEE_TYPES.each do |tax_type|
      tax_type = tax_type.to_s
      if tax_type == 'env_recovery_fee'
        tax = @license.taxes.find_by(tax_type: 'env_recovery_fee')
        if tax.nil?
          tax = Tax::EnvRecovery.new(
            tax_type: tax_type,
            tax_rate: Tax.tax_rate(tax_type)
          )
        end
      else
        tax = @license.taxes.find_or_initialize_by(tax_type: tax_type)
        tax.currency = 'riel' if tax_type == 'license_fee'
      end
      instance_variable_set(:"@#{tax_type}", tax)
    end
    @duty_tax = @license.taxes.build(tax_type: 'loyalty')
  end

  def create
    if Tax::DUTY_TYPES.include?(tax_params[:tax_type].to_sym)
      @duty_tax = @license.taxes.build(tax_params)
      if @duty_tax.save
        redirect_to new_license_tax_path
      else
        set_other_tax_variables
        render :new
      end
    else
      if tax_params[:tax_type] == 'env_recovery_fee'
        tax = Tax::EnvRecovery.new(tax_params)
        if tax.valid?
          @license.taxes.create(
            unit: tax_params[:unit_1],
            total: tax_params[:total_1],
            tax_type: 'env_recovery_fee'
          )
          @license.taxes.create(
            unit: tax_params[:unit_2],
            total: tax_params[:total_2],
            tax_type: 'env_recovery_fee_1'
          )
          redirect_to new_license_tax_path and return
        else
          set_other_tax_variables
          @duty_tax = @license.taxes.build(tax_type: 'loyalty')
          render :new and return
        end
      end

      tax = @license.taxes.build(tax_params)
      if tax.save
        redirect_to new_license_tax_path
      else
        set_other_tax_variables
        @duty_tax = @license.taxes.build(tax_type: 'loyalty')
        render :new
      end
    end
  end

  # def edit
  # end

  # def update
  #   if @tax.update_attributes(tax_params)
  #     redirect_to licenses_path
  #   else
  #     render :edit
  #   end
  # end

  def destroy
    @tax.destroy
    redirect_to licenses_path
  end

  private

  def set_license
    @license = License.find(params[:license_id])
  end

  def set_tax
    @tax = @license.taxes.find(params[:id])
  end

  def tax_params
    if params[:tax].nil?
      env_recovery_params
    else
      params.require(:tax).permit(:unit, :total, :year, :month, :tax_type, :currency)
    end
  end

  def env_recovery_params
    params.require(:tax_env_recovery).permit(:unit_1, :unit_2, :total_1, :total_2, :tax_type)
  end

  def set_other_tax_variables
    Tax::ONE_TIME_FEE_TYPES.each do |tax_type|
      tax_type = tax_type.to_s
      if tax_type == 'env_recovery_fee'
        tax = @license.taxes.find_by(tax_type: 'env_recovery_fee')
        if tax.nil?
          tax = Tax::EnvRecovery.new(
            tax_type: tax_type,
            tax_rate: Tax.tax_rate(tax_type)
          )
        end
      else
        tax = @license.taxes.find_or_initialize_by(tax_type: tax_type)
        tax.currency = 'riel' if tax_type == 'license_fee'
      end

      if tax.try(:new_record?) && tax_type == tax_params[:tax_type]
        tax.assign_attributes(tax_params)
        tax.valid?
      end
      instance_variable_set(:"@#{tax_type}", tax)
    end
  end

  def search_result
    if params[:tax_type] == 'env_recovery_fee'
      query = { tax_type: %w(env_recovery_fee env_recovery_fee_1) }
    else
      query = { tax_type: params[:tax_type] }
    end

    if params[:year].present?
      start_at = Date.parse("#{params[:year]}-01-01")
      end_at = start_at.end_of_year
      query[:taxes] = { from: start_at..end_at }
    end

    if params[:company_id].present?
      query[:licenses] = { company_id: params[:company_id] }
    end

    taxes = Tax.joins(license: :company).includes(license: :company).distinct(:id).where(query)
    if request.format.json?
      Taxes::DataService.new(taxes, params[:tax_type]).to_data
    else
      taxes
    end
  end
end
