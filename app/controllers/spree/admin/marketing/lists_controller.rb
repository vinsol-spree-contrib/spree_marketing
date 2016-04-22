module Spree
  module Admin
    module Marketing
      class ListsController < Spree::Admin::ResourceController

        before_action :load_contacts, only: :show

        private

          def collection
            Spree::Marketing::List.active
          end

          def load_contacts
            @contacts = @marketing_list.contacts.active
          end

      end
    end
  end
end
