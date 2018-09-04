module Spree
  module Marketing
    module ActsAsMultiList
      extend ActiveSupport::Concern

      def display_name
        self.class::NAME_TEXT + ' (' + entity_name + ')'
      end

      def entity_name
        entity.name
      end

      class_methods do
        def generator
          lists = []
          # data returns polymorphic entity ids or searched keywords
          data.each do |entity|
            if list = load_list_by_entity(entity)
              list.update_list
            else
              # ENTITY_KEY constant defines the attribute we are updating(searched_keyword/entity_id)
              new(self::ENTITY_KEY.to_s => entity, entity_type: self::ENTITY_TYPE).generate
              list = load_list_by_entity(entity)
            end
            lists << list
          end
          delete_lists(lists) if lists.any?
        end

        def delete_lists(lists)
          ListCleanupJob.perform_later where.not(uid: lists.map(&:uid)).pluck(:uid)
        end

        private

        def load_list_by_entity(entity)
          find_by(self::ENTITY_KEY.to_s => entity)
        end
      end
    end
  end
end
