require 'csv'

module Plans
  class CSVService
    attr_reader :licenses

    def initialize(licenses)
      @licenses = licenses
    end

    def to_csv
      columns = %w(
        company_name owner_name number issue_at
        category total_area business_address
        valid_at expire_at
      ).map { |col| I18n.t("activerecord.attributes.license.#{col}") }

      years = licenses.map do |license|
        plan = license.business_plan
        plan.contents.map(&:year) if plan.present?
      end.compact.flatten

      if years.empty?
        path = Rails.root.join('tmp', "licenses_#{Time.now.to_i}.csv").to_s
        File.new(path, 'w+:UTF-16LE:UTF-8').close
        return path
      end

      year_cols = (years.min..years.max).to_a
      columns += year_cols
      columns += [
        I18n.t('activerecord.attributes.business_plan.budget'),
        I18n.t('activerecord.attributes.business_plan.employees')
      ]

      path = Rails.root.join('tmp', "licenses_#{Time.now.to_i}.csv").to_s
      File.open(path, 'w+:UTF-16LE:UTF-8') do |file|
        data = CSV.generate(col_sep: "\t") do |csv|
          csv << columns
          licenses.each do |license|
            csv << plan_csv_data(license, year_cols)
          end
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

    def plan_csv_data(license, years)
      row = csv_data(license)[0..-3]
      plan = license.business_plan

      if plan.present?
        row += years.map do |year|
          content = content_from_year(plan, year)
          content.try(:plan)
        end

        row += [
          [plan.budget, I18n.t("currencies.#{plan.currency}")].join(' '),
          plan.employees
        ]
      else
        row += years.map { |_| '' }
        row += ['', '']
      end
    end

    def content_from_year(plan, year)
      plan.contents.find { |content| content.year == year }
    end
  end
end
