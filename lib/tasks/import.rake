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
      issued_date = Date.parse(row[6])
      expires_date = Date.parse(row[7])

      category = Category.find_or_create_by(name: row[5])
      company = Company.find_by(name: row[1])
      if company.nil?
        company = Company.create(
          name: row[1],
          business_address: address
        )
      end

      License.create!(
        number: no,
        area: area,
        address: address,
        company: company,
        category: category,
        province: province,
        area_unit: area_unit,
        valid_date: issued_date,
        issued_date: issued_date,
        expires_date: expires_date,
        company_name: company.name,
        category_name: category.name
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
