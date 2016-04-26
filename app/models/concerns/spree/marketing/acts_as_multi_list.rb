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
              new("#{ entity_key }" => entity_id).generate(name_text(entity_id))
              list = load_list(entity_id)
            end
            lists << list
          end
          ListCleanupJob.perform_later self.where.not(uid: lists.map(&:uid)).pluck(:uid)
        end

        private

          def load_list(entity_id)
            find_by(name: name_text(entity_id))
          end

          def name_text entity_id
            humanized_name + "_" + entity_name(entity_id)
          end
      end
    end
  end
end
