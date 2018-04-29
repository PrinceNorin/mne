class StatementsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_license
  before_action :set_statement, only: [:update, :destroy]

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
      render json: @statement.reload.as_json(include: {license: {include: :statements}})
    else
      render json: @statement.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @statement.destroy
    redirect_to license_path(@license)
  end

  private

  def set_license
    @license = License.find(params[:license_id])
    ids = Statement.pluck(:id)
    ref_ids = Statement.pluck(:reference_id)
    @references = Statement.where(id: ids - ref_ids)
  end

  def set_statement
    @statement = @license.statements.find(params[:id])
  end

  def statement_params
    params.require(:statement).permit(
      :number, :reference_id,
      :issued_date, :statement_type
    )
  end
end
