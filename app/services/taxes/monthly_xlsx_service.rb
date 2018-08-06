module Taxes
  class MonthlyXlsxService
    attr_reader :taxes

    def initialize(taxes)
      @taxes = taxes
    end

    def to_xlsx
      path = Rails.root.join('tmp', "taxes_#{Time.now.to_i}.xlsx").to_s
      wb = WriteXLSX.new(path)

      type_taxes = taxes.includes(:license).all.group_by(&:tax_type)

      type_taxes.each do |type, t_taxes|
        year_taxes = t_taxes.group_by(&:year)
        year_taxes.keys.sort.each do |year|
          row = 1
          ws = wb.add_worksheet("#{year}")
          fs = wb.add_format(valign: 'vcenter', align: 'center', bold: 1)
          fs1 = wb.add_format(valign: 'vcenter', align: 'left', bold: 1)
          fs2 = wb.add_format(valign: 'vcenter', align: 'right')

          write_tax_header(ws, fs)

          type_taxes = year_taxes[year].group_by { |tax| tax.license.category_name }
          type_taxes.each_with_index do |values, i|
            row += 1
            ws.merge_range(row, 0, row, 26, values[0], fs1)

            license_taxes = values[1].group_by { |tax| tax.license.id }

            license_taxes.each_with_index do |vals, ii|
              row += 1
              write_tax_data(wb, ws, row, vals[1], ii + 1)
            end

            row += 1
            ws.merge_range(row, 0, row, 1, I18n.t('total_amount'), fs)

            month_taxes = values[1].group_by { |tax| tax.month }
            keys = month_taxes.keys.sort
            keys.each do |k|
              sum_unit = month_taxes[k].sum(&:unit)

              currencies = month_taxes[k].group_by(&:currency)
              riel_total_fee = (currencies['riel'] || []).sum(&:total)
              dollar_total_fee = (currencies['dollar'] || []).sum(&:total)
              fees = []
              fees << "#{I18n.t('currency_symbols.riel')}#{riel_total_fee}" if riel_total_fee != 0
              fees << "#{I18n.t('currency_symbols.dollar')}#{dollar_total_fee}" if dollar_total_fee != 0
              sum_total = fees.join(' / ')

              col = k * 2
              ws.write(row, col, sum_unit, fs2)
              ws.write(row, col + 1, sum_total, fs2)
            end

            total_unit = values[1].sum(&:unit)
            currencies = values[1].group_by(&:currency)
            riel_total_fee = (currencies['riel'] || []).sum(&:total)
            dollar_total_fee = (currencies['dollar'] || []).sum(&:total)
            fees = []
            fees << "#{I18n.t('currency_symbols.riel')}#{riel_total_fee}" if riel_total_fee != 0
            fees << "#{I18n.t('currency_symbols.dollar')}#{dollar_total_fee}" if dollar_total_fee != 0
            total_fee = fees.join(' / ')

            ws.write(row, 26, total_unit, fs2)
            ws.write(row, 27, total_fee, fs2)
          end
        end
      end

      wb.close
      path
    end

    private

    def write_tax_header(ws, fs)
      ws.merge_range('A1:A2', I18n.t('activerecord.attributes.license.no1'), fs)
      ws.merge_range('B1:B2', I18n.t('activerecord.attributes.license.company_name'), fs)

      I18n.t('months').each_with_index do |month, i|
        start_index = (i + 1) * 2
        end_index = start_index + 1
        ws.merge_range(0, start_index, 0, end_index, month, fs)
        ws.write(1, start_index, I18n.t('activerecord.attributes.tax.unit_3'), fs)
        ws.write(1, end_index, I18n.t('activerecord.attributes.tax.total_3'), fs)
      end

      ws.merge_range(0, 26, 1, 26, I18n.t('total_unit_3'), fs)
      ws.merge_range(0, 27, 1, 27, I18n.t('total_amount_3'), fs)
    end

    def write_tax_data(wb, ws, start_row, taxes, no)
      colfs = wb.add_format(valign: 'vcenter', align: 'left')
      colfs1 = wb.add_format(valign: 'vcenter', align: 'right')
      colfs2 = wb.add_format(valign: 'vcenter', align: 'center')

      row = start_row
      ws.write(row, 0, no, colfs2)
      ws.write(row, 1, taxes.first.license.company_name, colfs)

      taxes.each_with_index do |tax, i|
        col = tax.month * 2
        total = I18n.t("currency_symbols.#{tax.currency}") + tax.total.to_s
        ws.write(row, col, tax.unit, colfs1)
        ws.write(row, col + 1, total, colfs1)
      end

      currencies = taxes.group_by(&:currency)
      riel_total_fee = (currencies['riel'] || []).sum(&:total)
      dollar_total_fee = (currencies['dollar'] || []).sum(&:total)
      fees = []
      fees << "#{I18n.t('currency_symbols.riel')}#{riel_total_fee}" if riel_total_fee != 0
      fees << "#{I18n.t('currency_symbols.dollar')}#{dollar_total_fee}" if dollar_total_fee != 0
      total_fee = fees.join(' / ')

      ws.write(row, 26, taxes.sum(&:unit), colfs1)
      ws.write(row, 27, total_fee, colfs1)
    end
  end
end
