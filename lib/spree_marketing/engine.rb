module SpreeMarketing
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_marketing'

    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'load spree_marketing config', group: :all do |app|
      app_config = Rails.root.join('config', 'spree_marketing.yml').to_s
      if File.exists?( app_config )
        SpreeMarketing::CONFIG = YAML.load_file(app_config).with_indifferent_access
      else
        #Unless file found with correct format, there would be definite exceptional cases
        Rails.logger.info "Please create the yml file spree_marketing.yml"
      end
    end

    def self.activate
      [
        Dir[config.root.join('app/models/spree/marketing/*.rb')],
        Dir[config.root.join('app/models/spree/marketing/list/*.rb')],
        Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb'))
      ].flatten.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
