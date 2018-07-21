require 'csv'

module Licenses
  class CSVService
    attr_reader :licenses

    def initialize(licenses)
      @licenses = licenses
    end

    def to_csv
      columns = %w(
        company_name owner_name number issue_at
        category total_area business_address
        valid_at expire_at status note
      ).map { |col| I18n.t("activerecord.attributes.license.#{col}") }

      path = Rails.root.join('tmp', "licenses_#{Time.now.to_i}.csv").to_s
      File.open(path, 'w+:UTF-16LE:UTF-8') do |file|
        data = CSV.generate(col_sep: "\t") do |csv|
          csv << columns
          licenses.each { |license| csv << csv_data(license) }
        end

        file.write("\xEF\xBB\xBF")
        file.write(data)
      end

      path
    end

    private

    def csv_data(license)
      [
        license.company_name, license.owner_name, license.number,
        I18n.l(license.issue_at, format: '%d, %b %Y'),
        license.category_name,
        "#{license.total_area} #{I18n.t('area_units.' + license.area_unit)}",
        "#{license.business_address} #{I18n.t("provinces.#{license.province}")}",
        I18n.l(license.valid_at, format: '%d, %b %Y'),
        I18n.l(license.expire_at, format: '%d, %b %Y'),
        I18n.t("statuses.#{license.status}"),
        license.note
      ]
    end
  end
end
