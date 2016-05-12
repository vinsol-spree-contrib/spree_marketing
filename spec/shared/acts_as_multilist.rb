RSpec.shared_examples 'acts_as_multilist' do |list_type|

  SpreeMarketing::CONFIG ||= { Rails.env => {} }

  describe 'methods' do
    let!(:list) { create(list_type.to_s.demodulize.underscore.to_sym, name: list_type::NAME_TEXT + ' (' + entity_name + ')', "#{ list_type::ENTITY_KEY }" => entity_id, entity_type: list_type::ENTITY_TYPE) }

    context '.load_list_by_entity' do
      it { expect(list_type.send :load_list_by_entity, entity_id).to eq list }
    end

    context '#display_name' do
      it { expect(list.display_name).to eq list_type::NAME_TEXT + ' (' + entity_name + ')' }
    end

    context '#entity_name' do
      it { expect(list.entity_name).to eq entity_name }
    end
  end

  context '.generator' do

    class GibbonServiceTest
    end

    let(:gibbon_service) { GibbonServiceTest.new }
    let(:emails) { ['test@example.com'] }
    let(:contacts_data) { [{ id: '12345678', email_address: emails.first, unique_email_id: 'test' }.with_indifferent_access] }

    before do
      allow(GibbonService::ListService).to receive(:new).and_return(gibbon_service)
      allow(gibbon_service).to receive(:delete_lists).and_return(true)
    end

    context 'if list already exists' do

      let(:list) { create(list_type.to_s.demodulize.underscore.to_sym, name: list_type.to_s.demodulize.underscore + '_' + entity_name) }

      before do
        allow(list_type).to receive(:find_by).and_return(list)
        allow(gibbon_service).to receive(:update_list).and_return(contacts_data)
      end

      it { expect { list_type.send :generator }.to change { list_type.all.count }.by 0 }
      it { expect { list_type.send :generator }.to change { list_type.last.contacts.count }.by 1 }
    end

    context "if list doesn't exists" do

      let(:list_name) { 'test' }
      let(:list_data) { { id: '12345678', name: list_name }.with_indifferent_access }

      before do
        allow(list_type).to receive(:find_by).and_return(nil)
        allow(gibbon_service).to receive(:generate_list).and_return(list_data)
        allow(gibbon_service).to receive(:subscribe_members).and_return(contacts_data)
      end

      it { expect { list_type.send :generator }.to change { list_type.all.count }.by 1 }
    end
  end

end
