module Spree
  module Admin
    module Marketing
      class ListsController < Spree::Admin::ResourceController
        before_action :load_contacts, only: :show

        private
          def collection
            Spree::Marketing::List.subclasses
                                  .map { |sub_class| sub_class.order(updated_at: :desc).all }
          end

          def load_contacts
            @contacts = @marketing_list.contacts.order(updated_at: :desc)
          end
      end
    end
  end
end
