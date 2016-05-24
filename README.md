# spree_marketing

Installation

$ rails g spree_marketing:install

This gem uses spree_events_tracker, please make sure that gem is added in your application.
While the installer for that gem is not needed as above installer will automatically run spree_events_tracker
installer.

This gem gives admin ability to post list of users to mailchimp to send campaigns to those lists.
All the lists are made on the data provided by app dynamically. Also, campaigns sent can be synced and then
their effects can be seen by reports generated per campaign specific to a list type.
