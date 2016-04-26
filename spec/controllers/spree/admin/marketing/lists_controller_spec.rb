require "spec_helper"

describe Spree::Admin::Marketing::ListsController, type: :controller do

  stub_authorization!

  let(:list) { create(:list) }
  let(:contact) { create(:contact) }
  let(:contacts) { [contact] }

  describe "Method Overrides" do
    context "#collection" do
      def do_index
        spree_get :index
      end

      let(:lists) { double(ActiveRecord::Relation) }
      let(:list_classes) { Spree::Marketing::List.subclasses }
      let(:grouped_lists) { [lists, lists] }

      before do
        allow(Spree::Marketing::List).to receive(:subclasses).and_return(list_classes)
        allow(list_classes).to receive(:map).and_return(grouped_lists)
      end

      context "expects to receive" do
        after { do_index }
        it { expect(Spree::Marketing::List).to receive(:subclasses).and_return(list_classes) }
        it { expect(list_classes).to receive(:map).and_return(grouped_lists) }
      end
    end
  end

  describe "callbacks" do
    def do_show
      spree_get :show, id: list.id
    end

    let(:contacts) { double(ActiveRecord::Relation) }

    before do
      allow(Spree::Marketing::List).to receive(:find).and_return(list)
      allow(list).to receive(:contacts).and_return(contacts)
      allow(contacts).to receive(:order).and_return(contacts)
    end

    context "expects to receive" do
      it { expect(Spree::Marketing::List).to receive(:find).with(list.id.to_s).and_return(list) }
      it { expect(list).to receive(:contacts).and_return(contacts) }
      it { expect(contacts).to receive(:order).with(updated_at: :desc).and_return(contacts) }
      after { do_show }
    end

    context "assigns" do
      before { do_show }
      it { expect(assigns(:contacts)).to eq contacts }
    end
  end

end
