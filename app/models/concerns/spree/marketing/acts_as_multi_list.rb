module Spree
  module Marketing
    module ActsAsMultiList

      extend ActiveSupport::Concern

      class_methods do
        def generator
          lists = []
          data.each do |entity_id|
            if list = load_list(entity_id)
              list.update_list
            else
              new("#{ self::ENTITY_KEY }" => entity_id).generate(name_text(entity_id))
              list = load_list(entity_id)
            end
            lists << list
          end
          delete_lists(lists)
        end

        def delete_lists(lists)
          ListCleanupJob.perform_later where.not(uid: lists.map(&:uid)).pluck(:uid) if lists.any?
        end

        private

          def load_list(entity_id)
            find_by(name: name_text(entity_id))
          end
      end
    end
  end
end
