class StatementsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_license
  before_action :set_statement, only: [:update, :destroy]

  def create
    statement = @license.statements.build(statement_params)
    if statement.save
      render json: statement.reload.as_json(include: {license: {include: :statements}})
    else
      render json: statement.errors, status: :unprocessable_entity
    end
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
    render json: { message: 'success' }
  end

  private

  def set_license
    @license = License.find(params[:license_id])
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
