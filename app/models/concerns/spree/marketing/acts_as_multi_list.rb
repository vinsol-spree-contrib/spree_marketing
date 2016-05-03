module Spree
  module Marketing
    module ActsAsMultiList

      extend ActiveSupport::Concern

      class_methods do
        def generator
          lists = []
          #data returns polymorphic entities or searched keywords
          data.each do |entity|
            if list = load_list_by_entity(entity)
              list.update_list
            else
              #ENTITY_KEY constant defines the attribute we are updating(searched_keyword/entity_id)
              new("#{ self::ENTITY_KEY }" => entity,
                  entity_type: self::ENTITY_TYPE,
                  name: name_text(entity)).generate
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

          def name_text(entity)
            humanized_name + "_" + entity_name(entity.name)
          end

          def entity_name(name)
            name.downcase.gsub(" ", "_")
          end

          def load_list_by_entity(entity)
            find_by("#{ self::ENTITY_KEY }" => entity)
          end
      end
    end
  end
end
