module SpreeMarketing
  module Generators
    class InstallGenerator < Rails::Generators::Base

      class_option :auto_run_migrations, :type => :boolean, :default => false

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/spree_marketing\n"
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require spree/backend/spree_marketing\n"
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', " *= require spree/frontend/spree_marketing\n", :before => /\*\//, :verbose => true
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/spree_marketing\n", :before => /\*\//, :verbose => true
      end

      def config_spree_marketing_yml
        create_file "config/spree_marketing.yml" do
          settings = {
                        development: {
                          gibbon_api_key: 'your_api_key',
                          gibbon_timeout: '15',
                          permission_reminder: 'your_permission_reminder',
                          email_type_option: true,
                          campaign_defaults: {
                            from_name: 'test name',
                            from_email: 'test@marketing.com',
                            subject: 'test subject',
                            language: 'english'
                          },
                          contact: {
                            company: 'marketing',
                            address1: '123',
                            city: 'city',
                            state: 'state',
                            zip: '123456',
                            country: 'country'
                          }
                        }
                     }

          settings.to_yaml
        end
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_marketing'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
