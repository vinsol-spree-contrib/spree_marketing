require 'spec_helper'

describe Spree::Marketing::ContactsList, type: :model do
  let(:active_contact) { create(:marketing_contact, active: true) }
  let(:another_contact) { create(:marketing_contact, active: true, email: 'test@a.com') }
  let(:active_list) { create(:marketing_list, active: true) }
  let(:contacts_list) { create(:marketing_contacts, list: active_list, contact: active_contact) }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:contact) }
    it { is_expected.to validate_presence_of(:list) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:contact).class_name('Spree::Marketing::Contact') }
    it { is_expected.to belong_to(:list).class_name('Spree::Marketing::List') }
  end

  describe 'Scopes' do
    context '.with_contact_ids' do
      it { expect(Spree::Marketing::ContactsList.with_contact_ids([active_contact.id])).to include contacts_list }
      it { expect(Spree::Marketing::ContactsList.with_contact_ids([another_contact.id])).to_not include contacts_list }
    end
  end
end
