class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = License.ransack(params[:q])
    @licenses = @q.result(distinct: true).order(:license_type, created_at: :desc).page(params[:page]).per(params[:per_page])
  end
end
