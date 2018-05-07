class StatementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_license
  before_action :set_statement, only: [:edit, :update, :destroy]
  before_action :load_references

  def new
    @statement = @license.statements.build
  end

  def create
    @statement = @license.statements.build(statement_params)
    if @statement.save
      redirect_to licenses_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @statement.update_attributes(statement_params)
      redirect_to license_path(@license)
    else
      render :new
    end
  end

  def destroy
    @statement.destroy
    redirect_to license_path(@license)
  end

  private

  def set_license
    @license = License.find(params[:license_id])
  end

  def set_statement
    @statement = @license.statements.find(params[:id])
  end

  def load_references
    scope = @license.statements

    if @statement.present?
      ids = scope.where.not(id: @statement.id).pluck(:id)
      ref_ids = scope.pluck(:reference_id) - [@statement.reference.try(:id)].compact
    else
      ids = scope.pluck(:id)
      ref_ids = scope.pluck(:reference_id)
    end

    @references = scope.where(id: ids - ref_ids)
  end

  def statement_params
    params.require(:statement).permit(
      :number, :reference_id,
      :issued_date, :statement_type
    )
  end
end
