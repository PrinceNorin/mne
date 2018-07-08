module Selectable
  extend ActiveSupport::Concern

  class_methods do
    def selectable_fields(*fields)
      fields.each do |field|
        define_selectable_field(field)
      end
    end

    private

    def define_selectable_field(field)
      singleton_class.instance_eval do
        define_method "selectable_#{field}" do
          plural_name = field.to_s.pluralize.to_sym
          self.public_send(plural_name).map do |key, _|
            [I18n.t("#{plural_name}.#{key}"), key]
          end
        end

        define_method "selectable_search_#{field}" do
          plural_name = field.to_s.pluralize.to_sym
          self.public_send(plural_name).map do |key, value|
            [I18n.t("#{plural_name}.#{key}"), value]
          end
        end
      end
    end
  end
end
