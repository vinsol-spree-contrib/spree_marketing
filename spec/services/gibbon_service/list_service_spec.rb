require 'spec_helper'

RSpec.describe GibbonService::ListService, type: :service do

  let(:list) { create(:marketing_list) }
  let(:contact) { create(:marketing_contact) }
  let(:gibbon_service) { GibbonService::ListService.new(list.uid) }
  let(:list_data) { { id: '12345678', name: list_name }.with_indifferent_access }
  let(:lists_data) { { lists: [list_data] }.with_indifferent_access }
  let(:list_name) { 'test' }
  let(:emails) { ['test@example.com'] }
  let(:list_class_name) { Spree::Marketing::List.subclasses.first.name }
  let(:contacts_data) { { members: [{ id: '12345678', email_address: emails.first, unique_email_id: 'test' }] }.with_indifferent_access }

  describe '#generate_list' do
    let(:params) { { body: { name: list_name } }.merge(GibbonService::ListService::DEFAULT_LIST_GENERATION_PARAMS) }

    before do
      allow(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
      allow(gibbon_service).to receive(:lists).and_return(gibbon_service)
      allow(gibbon_service).to receive(:create).and_return(list_data)
    end

    it 'accesses gibbon instance' do
      expect(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
    end
    it 'assigns lists part path for gibbon' do
      expect(gibbon_service).to receive(:lists).and_return(gibbon_service)
    end
    it 'calls create for list to gibbon' do
      expect(gibbon_service).to receive(:create).with(params).and_return(list_data)
    end

    after { gibbon_service.generate_list(list_name) }
  end

  describe '#update_list' do
    before do
      allow(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
      allow(gibbon_service).to receive(:lists).and_return(gibbon_service)
      allow(gibbon_service).to receive(:members).and_return(gibbon_service)
      allow(gibbon_service).to receive(:update).and_return(contacts_data['members'].first)
      allow(gibbon_service).to receive(:upsert).and_return(contacts_data['members'].first)
      allow(gibbon_service).to receive(:create).and_return(contacts_data['members'].first)
    end

    it 'accesses gibbon instance' do
      expect(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
    end
    it 'assigns lists part path for gibbon' do
      expect(gibbon_service).to receive(:lists).and_return(gibbon_service)
    end
    it 'assigns members part path for gibbon' do
      expect(gibbon_service).to receive(:members).and_return(gibbon_service)
    end
    context 'when unsubscribable contact uid is defined' do
      it 'calls update for contact to gibbon' do
        expect(gibbon_service).to receive(:update).and_return(contacts_data['members'].first)
      end
    end
    context 'when subscribing new contacts' do
      context 'when contact already exists as unsubscribed' do
        before do
          allow(Spree::Marketing::Contact).to receive(:find_by).and_return(contact)
        end
        it 'calls upsert for member to gibbon' do
          expect(gibbon_service).to receive(:upsert).and_return(contacts_data['members'].first)
        end
      end
      context 'when contact does not exist' do
        before do
          allow(Spree::Marketing::Contact).to receive(:find_by).and_return(nil)
        end
        it 'calls create for member to gibbon' do
          expect(gibbon_service).to receive(:create).and_return(contacts_data['members'].first)
        end
      end
    end

    after { gibbon_service.update_list(emails, [contact.uid]) }
  end

  describe '#retrieve_members' do
    before do
      allow(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
      allow(gibbon_service).to receive(:lists).and_return(gibbon_service)
      allow(gibbon_service).to receive(:members).and_return(gibbon_service)
      allow(gibbon_service).to receive(:retrieve).and_return(contacts_data)
    end

    it 'accesses gibbon instance' do
      expect(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
    end
    it 'assigns lists part path for gibbon' do
      expect(gibbon_service).to receive(:lists).and_return(gibbon_service)
    end
    it 'assigns members part path for gibbon' do
      expect(gibbon_service).to receive(:members).and_return(gibbon_service)
    end
    it 'retrieves members from gibbon' do
      expect(gibbon_service).to receive(:retrieve).and_return(contacts_data)
    end

    after { gibbon_service.send(:retrieve_members) }
  end

  describe '#delete_lists' do
    before do
      allow(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
      allow(gibbon_service).to receive(:lists).and_return(gibbon_service)
      allow(gibbon_service).to receive(:delete).and_return(nil)
    end

    it 'accesses gibbon instance' do
      expect(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
    end
    it 'assigns lists part path for gibbon' do
      expect(gibbon_service).to receive(:lists).with(list.uid).and_return(gibbon_service)
    end
    it 'applies delete for list to gibbon' do
      expect(gibbon_service).to receive(:delete).and_return(nil)
    end

    after { gibbon_service.delete_lists([list.uid]) }
  end

  describe '#unsubscribe_members' do
    before do
      allow(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
      allow(gibbon_service).to receive(:lists).and_return(gibbon_service)
      allow(gibbon_service).to receive(:members).and_return(gibbon_service)
      allow(gibbon_service).to receive(:update).and_return(contacts_data['members'].first)
    end

    it 'accesses gibbon instance' do
      expect(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
    end
    it 'assigns lists part path for gibbon' do
      expect(gibbon_service).to receive(:lists).and_return(gibbon_service)
    end
    it 'assigns members part path for gibbon' do
      expect(gibbon_service).to receive(:members).and_return(gibbon_service)
    end
    context 'when unsubscribable contact uid is defined' do
      it 'calls update for contact to gibbon' do
        expect(gibbon_service).to receive(:update).and_return(contacts_data['members'].first)
      end
    end

    after { gibbon_service.unsubscribe_members([contact.uid]) }
  end

  describe '#subscribe_members' do
    before do
      allow(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
      allow(gibbon_service).to receive(:lists).and_return(gibbon_service)
      allow(gibbon_service).to receive(:members).and_return(gibbon_service)
      allow(gibbon_service).to receive(:upsert).and_return(contacts_data['members'].first)
      allow(gibbon_service).to receive(:create).and_return(contacts_data['members'].first)
    end

    it 'accesses gibbon instance' do
      expect(gibbon_service).to receive(:gibbon).and_return(gibbon_service)
    end
    it 'assigns lists part path for gibbon' do
      expect(gibbon_service).to receive(:lists).and_return(gibbon_service)
    end
    it 'assigns members part path for gibbon' do
      expect(gibbon_service).to receive(:members).and_return(gibbon_service)
    end
    context 'when subscribing new contacts' do
      context 'when contact already exists as unsubscribed' do
        before do
          allow(Spree::Marketing::Contact).to receive(:find_by).and_return(contact)
        end
        it 'calls upsert for member to gibbon' do
          expect(gibbon_service).to receive(:upsert).and_return(contacts_data['members'].first)
        end
      end
      context 'when contact does not exist' do
        before do
          allow(Spree::Marketing::Contact).to receive(:find_by).and_return(nil)
        end
        it 'calls create for member to gibbon' do
          expect(gibbon_service).to receive(:create).and_return(contacts_data['members'].first)
        end
      end
    end

    after { gibbon_service.subscribe_members([emails]) }
  end
end
