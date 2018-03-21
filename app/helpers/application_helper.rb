module ApplicationHelper
  def translate_options(name)
    License.send(name).map do |unit, value|
      [t("#{name}.#{unit}"), value]
    end
  end
end
