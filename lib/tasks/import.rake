namespace :import do
  desc 'import data from xlsx'
  task xlsx: :environment do
    path = Rails.root.join('db/licenses.xlsx').to_s
    xlsx = Roo::Excelx.new(path)
    sheet = xlsx.sheet(0)

    License.transaction do
      (sheet.first_row..sheet.last_row).each do |i|
        row = sheet.row(i)
        start_at = random_date(2015)
        create_license!(row, start_at)
      end

      (sheet.first_row..sheet.last_row).each do |i|
        row = sheet.row(i)
        license = License.find_by(number: row[0])
        copy_license(license)
      end
    end
  end

  def create_license!(row, start_at)
    category = Category.find_by(name: row[2])
    company = Company.find_or_create_by(name: row[1])
    total_area, area_unit = random_area(row[3])
    province = get_province(row[4])
    start_at = random_date(2015)

    License.create!(
      number: row[0],
      total_area: total_area,
      area_unit: area_unit,
      business_address: row[5],
      company: company,
      category: category,
      province: province,
      issue_at: start_at,
      valid_at: start_at,
      expire_at: start_at + 2.years,
      company_name: company.name,
      category_name: category.name
    )
  end

  def copy_license(license)
    old_number, letter = license.number.split(' ')
    new_number = (old_number.to_i + 30).to_s.rjust(4, '0')
    issue_at = license.expire_at + 1.day

    License.create!(
      number: "#{new_number} #{letter}",
      total_area: license.total_area,
      area_unit: license.area_unit,
      business_address: license.business_address,
      company_id: license.company_id,
      category_id: license.category_id,
      province: license.province,
      issue_at: issue_at,
      valid_at: issue_at,
      expire_at: issue_at + 2.years,
      company_name: license.company_name,
      category_name: license.category_name
    )
  end

  def random_date(year)
    month = (1..12).to_a.sample
    day = (1..28).to_a.sample
    Date.parse("#{year}-#{month}-#{day}")
  end

  def random_area(total)
    unit = ['ha', 'm2'].sample
    total *= 10000 if unit == 'm2'
    [total, unit]
  end

  def get_province(value)
    I18n.t('provinces').key(value)
  end
end
