module Taxes
  class OneTimeXlsxService
    attr_reader :taxes, :tax_type

    def initialize(taxes, tax_type)
      @taxes, @tax_type = taxes, tax_type
    end

    def to_xlsx
      path = Rails.root.join('tmp', "taxes_#{Time.now.to_i}.xlsx").to_s
      wb = WriteXLSX.new(path)

      type_taxes = taxes.includes(:license).all.group_by do |tax|
        if tax.tax_type == 'env_recovery_fee' || tax.tax_type == 'env_recovery_fee_1'
          'env_recovery_fee'
        else
          tax.tax_type
        end
      end

      type_taxes.each do |type, t_taxes|
        year_taxes = t_taxes.group_by(&:year)
        year_taxes.keys.sort.each do |year|
          row = 0
          year_tax = year_taxes[year].first

          ws = wb.add_worksheet("#{year_tax.from.year} - #{year_tax.to.year}")
          fs = wb.add_format(valign: 'vcenter', align: 'center', bold: 1)
          fs1 = wb.add_format(valign: 'vcenter', align: 'left', bold: 1)
          fs2 = wb.add_format(valign: 'vcenter', align: 'right')

          write_tax_header(ws, fs)

          type_taxes = year_taxes[year].group_by { |tax| tax.license.category_name }
          type_taxes.each_with_index do |values, i|
            row += 1
            ws.merge_range(row, 0, row, 5, values[0], fs1)

            license_taxes = values[1].group_by { |tax| tax.license.id }

            license_taxes.each_with_index do |vals, ii|
              row += 1
              write_tax_data(wb, ws, row, vals[1], ii + 1)
            end

            row += 1
            ws.merge_range(row, 0, row, 1, I18n.t('total_amount'), fs)

            total_fee = values[1].sum(&:total)
            if tax_type == 'license_fee'
              ws.write(row, 2, total_fee, fs2)
            elsif tax_type == 'total_area_fee'
              total_unit = values[1].sum(&:unit)
              ws.write(row, 2, total_unit, fs2)
              ws.write(row, 3, total_fee, fs2)
            else
              taxes_unit_1 = values[1].select { |tax| tax.tax_type == 'env_recovery_fee' }
              taxes_unit_2 = values[1].select { |tax| tax.tax_type == 'env_recovery_fee_1' }

              total_unit_1 = taxes_unit_1.sum(&:unit)
              total_unit_2 = taxes_unit_2.sum(&:unit)
              ws.write(row, 2, total_unit_1, fs2)
              ws.write(row, 3, total_unit_2, fs2)
              ws.write(row, 4, total_fee, fs2)
            end
          end
        end
      end

      wb.close
      path
    end

    private

    def write_tax_header(ws, fs)
      ws.write(0, 0, I18n.t('activerecord.attributes.license.no1'), fs)
      ws.write(0, 1, I18n.t('activerecord.attributes.license.company_name'), fs)

      if tax_type == 'license_fee'
        ws.write(0, 2, I18n.t('activerecord.attributes.tax.total'), fs)
      elsif tax_type == 'total_area_fee'
        ws.write(0, 2, I18n.t('activerecord.attributes.tax.unit'), fs)
        ws.write(0, 3, I18n.t('activerecord.attributes.tax.total'), fs)
      else
        ws.write(0, 2, I18n.t('activerecord.attributes.tax.unit_1'), fs)
        ws.write(0, 3, I18n.t('activerecord.attributes.tax.unit_2'), fs)
        ws.write(0, 4, I18n.t('activerecord.attributes.tax.total'), fs)
      end
    end

    def write_tax_data(wb, ws, start_row, taxes, no)
      colfs = wb.add_format(valign: 'vcenter', align: 'left')
      colfs1 = wb.add_format(valign: 'vcenter', align: 'right')
      colfs2 = wb.add_format(valign: 'vcenter', align: 'center')

      row = start_row
      ws.write(row, 0, no, colfs2)
      ws.write(row, 1, taxes.first.license.company_name, colfs)

      if tax_type == 'env_recovery_fee'
        tax_unit_1 = taxes.find { |tax| tax.tax_type == 'env_recovery_fee' }
        tax_unit_2 = taxes.find { |tax| tax.tax_type == 'env_recovery_fee_1' }
        ws.write(row, 2, tax_unit_1.unit, colfs1)
        ws.write(row, 3, tax_unit_2.unit, colfs1)
        ws.write(row, 4, taxes.sum(&:total), colfs1)
      else
        taxes.each_with_index do |tax, i|
          col = (i + 1) * 2
          if tax_type == 'license_fee'
            ws.write(row, col, tax.total, colfs1)
          else
            ws.write(row, col, tax.unit, colfs1)
            ws.write(row, col + 1, tax.total, colfs1)
          end
        end
      end
    end
  end
end
