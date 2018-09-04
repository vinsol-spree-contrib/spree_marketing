module Spree
  module Admin
    module Marketing
      module CampaignsHelper
        def recipient_user_link(text, report_key, user)
          path = if report_key == :purchases
                   spree.orders_admin_user_path(id: user.id)
                 else
                   spree.edit_admin_user_path(id: user.id)
                 end
          link_to(text, path, target: '_blank')
        end

        def recipient_email_or_link(recipient)
          if recipient.contact_user
            recipient_user_link(recipient.contact_email, @report_name.to_sym, recipient.contact_user)
          else
            recipient.contact_email
          end
        end
      end
    end
  end
end
