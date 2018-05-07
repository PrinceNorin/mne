module ApplicationHelper
  def translate_options(name)
    License.send(name).map do |unit, value|
      [t("#{name}.#{unit}"), value]
    end
  end

  def year_options
    year = Date.current.year
    ((year - 15)..(year + 30)).map { |y| [y, y] }
  end
end
