module SpreeMarketing
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_marketing'

    config.generators do |g|
      g.test_framework :rspec
    end

    config.before_initialize do
      config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]
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

    initializer 'spree_marketing.assets.precompile' do |app|
      app.config.assets.precompile += %w[
        spree/backend/campaign_sync_flash_handler.js
        spree/backend/campaign_data_report.js
        spree/backend/campaign_report.css
      ]
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), '../../app/models/**/*.rb')) do |c|
        require(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
