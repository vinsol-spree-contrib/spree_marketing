require "spec_helper"

describe Spree::Admin::Marketing::ListsController, type: :controller do

  stub_authorization!

  let(:list) { create(:marketing_list) }
  let(:contact) { create(:marketing_contact) }
  let(:contacts) { double(ActiveRecord::Relation) }
  let(:lists) { double(ActiveRecord::Relation) }

  describe "Method Overrides" do
    context "#collection" do
      def do_index
        spree_get :index
      end

      let(:lists) { double(ActiveRecord::Relation) }
      let(:list_classes) { Spree::Marketing::List.subclasses }
      let(:grouped_lists) { [lists, lists] }

      before do
        Spree::Marketing::List.subclasses.each do |subclass|
          allow(subclass).to receive(:includes).and_return(lists)
          allow(lists).to receive(:order).and_return(lists)
          allow(lists).to receive(:all).and_return(lists)
        end
      end

      context "expects to receive" do
        after { do_index }
        it { expect(Spree::Marketing::List).to receive(:subclasses).and_return(Spree::Marketing::List.subclasses) }
        Spree::Marketing::List.subclasses.each do |subclass|
          it { expect(subclass).to receive(:includes).with(:contacts).and_return(lists) }
          it { expect(lists).to receive(:order).with(updated_at: :desc).and_return(lists) }
          it { expect(lists).to receive(:all).and_return(lists) }
        end
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
