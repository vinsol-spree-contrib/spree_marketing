# Spree Marketing

Introduction
-------------

Marketing is one of the most important aspect of any Ecommerce business.

This extension gives you a lot of lists synced with Mailchimp to help you in creating different subscribers list on Mailchimp.

This extension provides user lists for "Most Selling Products", "Abandoned Carts", "Most searched keywords", etc. to give better insights.

Installation
-------------

  1. Add this extension to your Gemfile by this line.

  ```ruby
   gem 'spree_marketing', github: 'vinsol-spree-contrib/spree_marketing', branch: '3-0-stable'
  ```

  ```ruby
   gem 'spree_events_tracker', github: 'vinsol-spree-contrib/spree_events_tracker', branch: '3-0-stable'
  ```

  2. Install the gem using bundler.

  ```ruby
   bundle install
  ```

  3. Copy & run migrations using installer.

  ```ruby
   bundle exec rails g spree_marketing:install
  ```
  This installer will also run installer for spree_events_tracker.

  4. After installer runs, it will create a `config/spree_marketing.yml.example` which is to be converted into `config/spree_marketing.yml` with correct user credentials. Also run command
  ```ruby
    wheneverize
  ```
  so that cron tasks can be scheduled.

  5. Restart your server if your server was running so that it can now find assets properly.


Testing
--------

First bundle your dependencies, then run `rake test_app`. `rake test_app` will generate to dummy app if it does not exist.
And then run specs using `rspec spec/`

```ruby
 bundle
 bundle exec rake test_app
 bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories. Simply add this require statement to your spec_helper:

```ruby
  require 'spree_marketing/factories'
```

Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2016 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
