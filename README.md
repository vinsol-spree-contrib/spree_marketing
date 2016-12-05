# spree_marketing

Installation
-------------

  1. Add this extension to your Gemfile by this line.

  ```ruby
   gem 'spree_marketing', github: '[your-github-handle]/spree_marketing', branch: 'x-x-stable'
  ```
    Specify branch corresponding to the spree version you are using like `3-0-stable` for spree `3.0.x`
    Also this gem has dependency on spree_events_tracker. So make sure spree_events_tracker gem is added in your `Gemfile` like
  ```ruby
   gem 'spree_events_tracker', github: '[your-github-handle]/spree_events_tracker', branch: 'x-x-stable'
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
 rspec spec/
```

When testing your applications integration with this extension you may use it's factories. Simply add this require statement to your spec_helper:

```ruby
  require 'spree_marketing/factories'
```

Contributing
-------------

If you'd like to contribute, please take a look at the instructions for installing dependencies and crafting a good pull request.

Copyright (c) 2016 [name of extension creator], released under the New BSD License
