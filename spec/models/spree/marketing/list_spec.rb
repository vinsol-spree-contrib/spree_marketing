require 'spec_helper'

describe Spree::Marketing::List, type: :model do

  let(:active_list) { create(:marketing_list, active: true) }
  let(:inactive_list) { create(:marketing_list, active: false) }

  describe 'Constants' do
    it { expect(Spree::Marketing::List::TIME_FRAME).to eq(1.week) }
    it { expect(Spree::Marketing::List::NAME_TEXT).to eq('List') }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:name) }
    #Spec would fail without subject assignment at db level
    context 'validates uniqueness of' do
      subject { active_list }
      it { is_expected.to validate_uniqueness_of(:uid).case_insensitive }
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:contacts_lists).class_name('Spree::Marketing::ContactsList').dependent(:destroy) }
    it { is_expected.to have_many(:contacts).through(:contacts_lists) }
    it { is_expected.to have_many(:campaigns).class_name("Spree::Marketing::Campaign").dependent(:restrict_with_error) }
    it { is_expected.to belong_to(:entity) }
  end

  describe 'Scopes' do
    context '.active' do
      it { expect(Spree::Marketing::List.active).to include active_list }
      it { expect(Spree::Marketing::List.active).to_not include inactive_list }
    end
  end

  describe '#user_ids' do
    it { expect {active_list.user_ids}.to raise_error(::NotImplementedError, 'You must implement user_ids method for this smart list.') }
  end

  describe '#generate' do
    let!(:list_name) { 'test' }

    before do
      allow(ListGenerationJob).to receive(:perform_later).and_return(true)
      allow(active_list).to receive(:user_ids).and_return([])
    end

    it { expect(ListGenerationJob).to receive(:perform_later).with(active_list.display_name, active_list.send(:emails), active_list.class.name, active_list.send(:entity_data)) }

    after { active_list.generate }
  end

  describe '#update_list' do
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
    let(:name) { Spree::Marketing::List::NAME_TEXT }

    context 'when list is persisted' do
      before do
        active_list.update_column(:name, name)
        allow(ListModificationJob).to receive(:perform_later).and_return(true)
        allow(active_list).to receive(:user_ids).and_return([])
        allow(Spree::Marketing::List).to receive(:find_by).and_return(active_list)
      end

      it { expect(Spree::Marketing::List).to receive(:find_by).with(name: name).and_return(active_list) }
      it { expect(active_list).to receive(:update_list).and_return(true) }

      after { Spree::Marketing::List.generator }
    end

    context 'when list is not persisted' do
      let(:new_list) { Spree::Marketing::List.new(name: name) }

      before do
        allow(ListGenerationJob).to receive(:perform_later).and_return(true)
        allow(Spree::Marketing::List).to receive(:find_by).and_return(nil)
        allow(Spree::Marketing::List).to receive(:new).and_return(new_list)
        allow(new_list).to receive(:user_ids).and_return([])
      end

      it { expect(Spree::Marketing::List).to receive(:find_by).with(name: name).and_return(nil) }
      it { expect(new_list).to receive(:generate).and_return(true) }

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

  describe '#display_name' do
    it { expect(Spree::Marketing::List.new.send(:display_name)).to eq(Spree::Marketing::List::NAME_TEXT) }
  end

  describe '#populate' do
    let(:contacts_data) { [{ email_address: 'test@a.com',
                             id: '12344567',
                             unique_email_id: '12345678900000987654322222221' }.with_indifferent_access] }

    before { active_list.populate(contacts_data) }

    it { expect(active_list.contacts.count).to eq(1) }
    it { expect(active_list.contacts.first.email).to eq(contacts_data.first[:email_address]) }
  end

  describe '#computed_time' do
    it { expect(active_list.send(:computed_time).day).to eq((Time.current - active_list.send(:time_frame)).day) }
  end

  describe '#time_frame' do
    it { expect(active_list.send(:time_frame)).to eq(Spree::Marketing::List::TIME_FRAME) }
  end

  describe '#emails' do
    let(:user) { create(:user) }

    before do
      allow(active_list).to receive(:user_ids).and_return([user.id])
    end

    it { expect(active_list.send(:emails)).to include(user.email) }
  end

  describe '#old_emails' do
    let(:contact) { create(:marketing_contact) }
    let(:contacts_list) { create(:contacts_list, list: active_list, contact: contact) }

    before { active_list.contacts << contact }

    it { expect(active_list.send(:old_emails)).to include(contact.email) }
  end

  describe '#removable_contact_uids' do
    let(:contact) { create(:marketing_contact) }
    let(:contacts_list) { create(:contacts_list, list: active_list, contact: contact) }

    it { expect(active_list.send(:removable_contact_uids, [contact.email])).to include(contact.uid) }
  end

  describe '#presenter' do
    let!(:list_presenter) { Spree::Marketing::ListPresenter.new active_list }

    it 'should return an instance of ListPresenter Class' do
      expect(active_list.presenter.class).to eq list_presenter.class
    end
  end

  describe '#entity_data' do
    let(:product) { create(:product, name: "Ruby On Rails Tote") }

    before do
      active_list.update(entity: product)
    end

    it { expect(active_list.send(:entity_data)).to eq({ entity_id: product.id, entity_type: product.class.to_s, searched_keyword: nil }) }
  end
end
