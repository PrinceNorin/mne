class SearchController < ApplicationController
  def index
    @q = License.ransack(params[:q])
    @licenses = @q.result(distinct: true).page(params[:page]).per(params[:per_page])
  end
end
