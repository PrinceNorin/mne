class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = License.ransack(params[:q])
    @licenses = @q.result(distinct: true)
      .includes(:business_plan)
      .order(:category_id, :created_at)
      .page(params[:page]).per(params[:per_page])
  end

  def download
    respond_to do |format|
      format.xls do
        @licenses = License.ransack(params[:q])
          .result(distinct: true)
          .includes(:business_plan)
          .unique_by_latest_expires_date
          .order(:category_id, :created_at)

        path = Licenses::CSVService.new(@licenses).to_csv
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
          .unique_by_latest_expires_date
          .order(:category_id, :created_at)

        path = Plans::CSVService.new(@licenses).to_csv
        data = File.read(path)
        send_data data, filename: 'ស្ថិតិផែនការផលិតកម្ម.xls'
        FileUtils.rm path
      end
    end
  end

  def tax_download
    respond_to do |format|
      format.html { @q = Tax.ransack(params[:q]) }
      format.xlsx do
        @taxes = Tax.ransack(params[:q]).result.order(:year, :month)

        path = Taxes::CSVService.new(@taxes).to_csv
        data = File.read(path)
        send_data data, filename: 'តារាងតាមដានបរិមាណនិងការបង់សួយសារ.xls'
        FileUtils.rm path
      end
    end
  end
end
