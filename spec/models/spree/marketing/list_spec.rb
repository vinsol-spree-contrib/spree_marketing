require "spec_helper"

describe Spree::Marketing::List, type: :model do

  let(:active_list) { create(:valid_list, active: true) }
  let(:inactive_list) { create(:valid_list, active: false) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:name) }
    context "validates uniqueness of" do
      let!(:list1) { create(:valid_list) }
      let(:list2) { build(:valid_list, uid: list1.uid) }
      before { list2.save }
      it { expect(list2.errors[:uid]).to include I18n.t "errors.messages.taken" }
    end
  end

  describe "Associations" do
    it { is_expected.to have_many(:contacts_lists).class_name("Spree::Marketing::ContactsList").dependent(:destroy) }
    it { is_expected.to have_many(:contacts).through(:contacts_lists) }
  end

  describe "Scopes" do
    context ".active" do
      it { expect(Spree::Marketing::List.active).to include active_list }
      it { expect(Spree::Marketing::List.active).to_not include inactive_list }
    end
  end

  describe "#user_ids" do
    it { expect {active_list.user_ids}.to raise_error(::NotImplementedError) }
  end

  describe "#generate" do
    let!(:list_name) { 'test' }

    before do
      allow(ListGenerationJob).to receive(:perform_later).and_return(true)
      allow(active_list).to receive(:user_ids).and_return([])
    end

    it { expect(ListGenerationJob).to receive(:perform_later).with(list_name, active_list.send(:emails), active_list.class.name) }

    after { active_list.generate(list_name) }
  end

  describe "#update_list" do
    let(:emails) { active_list.send(:emails) }
    let(:old_emails) { active_list.send(:old_emails) }

    before do
      allow(ListModificationJob).to receive(:perform_later).and_return(true)
      allow(active_list).to receive(:user_ids).and_return([])
    end

    it { expect(ListModificationJob).to receive(:perform_later).with(active_list.id, emails - old_emails, old_emails - emails) }

    after { active_list.update_list }
  end

  describe '.generator' do
    context 'list.persisted?' do
      let(:humanized_name) { Spree::Marketing::List.send(:humanized_name) }

      before do
        active_list.update_column(:name, humanized_name)
        allow(ListModificationJob).to receive(:perform_later).and_return(true)
        allow(active_list).to receive(:user_ids).and_return([])
        allow(Spree::Marketing::List).to receive(:find_by).and_return(active_list)
      end

      it { expect(Spree::Marketing::List).to receive(:find_by).with(name: humanized_name).and_return(active_list) }
      it { expect(active_list).to receive(:update_list).and_return(true) }

      after { Spree::Marketing::List.generator }
    end

    context '!list.persisted?' do
      let(:humanized_name) { Spree::Marketing::List.send(:humanized_name) }
      let(:new_list) { Spree::Marketing::List.new }

      before do
        allow(ListGenerationJob).to receive(:perform_later).and_return(true)
        allow(Spree::Marketing::List).to receive(:find_by).and_return(nil)
        allow(Spree::Marketing::List).to receive(:new).and_return(new_list)
        allow(new_list).to receive(:user_ids).and_return([])
      end

      it { expect(Spree::Marketing::List).to receive(:find_by).with(name: humanized_name).and_return(nil) }
      it { expect(new_list).to receive(:generate).with(humanized_name).and_return(true) }

      after { Spree::Marketing::List.generator }
    end
  end

  describe '.generate_all' do
    Spree::Marketing::List.subclasses.each do |subclass|
      before do
        allow(ListGenerationJob).to receive(:perform_later).and_return(true)
        allow(ListCleanupJob).to receive(:perform_later).and_return(true)
        allow(active_list).to receive(:user_ids).and_return([])
      end

      it { expect(subclass).to receive(:generator) }
    end

    after { Spree::Marketing::List.generate_all }
  end

end
