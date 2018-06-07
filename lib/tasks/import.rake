require 'csv'

namespace :import do
  desc 'import data from csv'
  task csv: :environment do
    path = Rails.root.join('db/licenses.csv').to_s
    CSV.foreach(path) do |row|
      row = row.map(&:strip)
      no = row[0]
      company = row[1]
      area = row[2]
      area_unit = 'ha'
      address = row[3]
      province = I18n.t("provinces").key(row[4])
      type = type_from_string(row[5])
      issued_date = Date.parse(row[6])
      expires_date = Date.parse(row[7])

      License.create!(
        number: no,
        company_name: company,
        area: area,
        area_unit: area_unit,
        address: address,
        province: province,
        license_type: type,
        issued_date: issued_date,
        expires_date: expires_date,
        owner_name: ''
      )
    end
  end

  def type_from_string(str)
    h = {
      'អាចម៍ដី' => 'shallow',
      'ខ្សាច់បក' => 'const_sand',
      'ថ្មអារ' => 'stale_stone',
      'ថ្ម' => 'stone'
    }
    h[str]
  end
end
