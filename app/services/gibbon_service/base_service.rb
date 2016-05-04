module GibbonService
  class BaseService

    def self.gibbon
      @gibbon ||= ::Gibbon::Request.new(api_key: SpreeMarketing::CONFIG[Rails.env][:gibbon_api_key])
    end

    def gibbon
      self.class.gibbon
    end
  end
end
