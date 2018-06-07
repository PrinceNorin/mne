class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = License.ransack(params[:q])
    @licenses = @q.result(distinct: true)
      .includes(:business_plan)
      .order(:license_type, :created_at)
      .page(params[:page]).per(params[:per_page])
  end

  def download
    respond_to do |format|
      format.xls do
        @licenses = License.ransack(params[:q])
          .result(distinct: true)
          .includes(:business_plan)

        @licenses = License.where(id: @licenses.select('MAX(id)').group(:company_name))
          .order(:license_type, :created_at)

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

        @licenses = License.where(id: @licenses.select('MAX(id)').group(:company_name))
          .order(:license_type, :created_at)

        path = @licenses.to_plan_csv
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

        path = @taxes.to_tax_csv
        data = File.read(path)
        send_data data, filename: 'តារាងតាមដានបរិមាណនិងការបង់សួយសារ.xls'
        FileUtils.rm path
      end
    end
  end
end
