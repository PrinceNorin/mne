class TaxesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_license
  before_action :set_tax, only: [:edit, :update, :destroy]

  def new
    @cat_1 = @license.taxes.build(tax_type: 'cat_1')
    @cat_2 = @license.taxes.build(tax_type: 'cat_2')
    @cat_3 = @license.taxes.build(tax_type: 'cat_3')
    @cat_4 = @license.taxes.build(tax_type: 'cat_4')
    @cat_5 = @license.taxes.build(tax_type: 'cat_5')
  end

  def create
    Tax.tax_types.each do |k, _|
      if k.to_s == tax_params[:tax_type]
        @current = @license.taxes.build(tax_params)
        instance_variable_set("@#{k}".to_sym, @current)
      else
        instance_variable_set("@#{k}".to_sym, @license.taxes.build(tax_type: k.to_s))
      end
    end

    if @current.save
      redirect_to new_license_tax_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @tax.update_attributes(tax_params)
      redirect_to licenses_path
    else
      render :edit
    end
  end

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
    params.require(:tax).permit(:unit, :total, :year, :month, :tax_type)
  end
end
