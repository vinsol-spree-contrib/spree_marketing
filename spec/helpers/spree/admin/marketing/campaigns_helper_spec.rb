require 'spec_helper'

describe Spree::Admin::Marketing::CampaignsHelper, type: :helper do
  let(:user) { create(:user) }
  let(:campaign) { build(:marketing_campaign) }
  let(:contact) { create(:marketing_contact, user: user) }
  let(:recipient) { create(:marketing_recipient, campaign: campaign, contact: contact) }

  before { allow(campaign).to receive_messages(enqueue_update: nil) }

  describe '#recipient_email_or_link' do
    before { @report_name = 'log_ins' }

    context 'when contact user exists' do
      context 'when report_name is purchases' do
        before { @report_name = 'purchases' }

        it 'returns link tag for user\'s orders path' do
          expect(helper.recipient_email_or_link(recipient)).to include('<a target="_blank" href="/admin/users/1/orders">')
        end
      end

      context 'when report_name is ' do
        it 'returns link tag for user\'s edit path' do
          expect(helper.recipient_email_or_link(recipient)).to include('<a target="_blank" href="/admin/users/1/edit">')
        end
      end
    end

    context 'when contact user does not exists' do
      before { contact.user = nil }

      it 'returns recipient\'s contact\'s email address' do
        expect(helper.recipient_email_or_link(recipient)).to eq(contact.email)
      end
    end
  end
end
