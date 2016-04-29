module Spree
  module Marketing
    class ListPresenter
      def initialize list
        @list = list
      end

      def name
        class_name = @list.class.to_s.demodulize.underscore.humanize
        list_name = @list.name.humanize.remove(class_name).titleize
        list_name.present? ? list_name : "Contacts"
      end

      def show_page_name
        if name == "Contacts"
          ""
        else
          " -> " + name
        end
      end
    end
  end
end
