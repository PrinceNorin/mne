module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def searchable_scope(name, block)
      scope name, block

      @_ransackable_scopes ||= []
      @_ransackable_scopes << name
    end

    def ransackable_scopes(auth = nil)
      @_ransackable_scopes || []
    end
  end
end
