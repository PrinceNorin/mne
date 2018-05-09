class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = License.ransack(params[:q])
    @licenses = @q.result(distinct: true)
      .includes(:business_plan)
      .order(:license_type, created_at: :desc)
      .page(params[:page]).per(params[:per_page])
  end

  def download
    respond_to do |format|
      format.xls do
        @licenses = License.ransack(params[:q])
          .result(distinct: true)
          .includes(:business_plan)
          .order(:license_type, created_at: :desc)

        path = @licenses.to_csv
        data = File.read(path)
        send_data data, filename: 'តារាងបញ្ជីអាជ្ញាបណ្ណក្នុងក្រសួង.xls'
        FileUtils.rm path
      end
    end
  end

  def plan_download
    respond_to do |format|
      format.xls do
        @licenses = License.ransack(params[:q])
          .result(distinct: true)
          .includes(:business_plan)
          .order(:license_type, created_at: :desc)

        path = @licenses.to_plan_csv
        data = File.read(path)
        send_data data, filename: 'ស្ថិតិផែនការផលិតកម្ម.xls'
        FileUtils.rm path
      end
    end
  end
end
