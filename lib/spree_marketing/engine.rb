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
      if File.exist?( app_config )
        SpreeMarketing::DEFAULT_LIST_GENERATION_PARAMS = YAML.load_file(app_config)
      else
        SpreeMarketing.log "Please create the yml file spree_marketing.yml"
      end
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
