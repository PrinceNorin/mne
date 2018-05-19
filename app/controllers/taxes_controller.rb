class TaxesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_license
  before_action :set_tax, only: [:edit, :update, :destroy]

  def new
    @tax = @license.taxes.build
  end

  def create
    @tax = @license.taxes.build(tax_params)
    if @tax.save
      redirect_to licenses_path
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
    params.require(:tax).permit(:unit, :total, :year, :month)
  end
end
