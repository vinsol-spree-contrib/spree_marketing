require 'spec_helper'

RSpec.describe Spree::Marketing::MailchimpErrorNotifier do
  SpreeMarketing::CONFIG = { Rails.env => { campaign_defaults: { from_email: 'a@test.com' } } }.freeze

  describe 'notify_failure' do
    let(:mail) { described_class.notify_failure('TestJob', 'title', 'detail') }

    it 'renders the subject' do
      expect(mail.subject).to eq I18n.t(:subject, scope: %i[spree marketing mailchimp_error_notifier notify_failure])
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq [SpreeMarketing::CONFIG[Rails.env][:campaign_defaults][:from_email]]
    end

    it 'renders the sender email' do
      expect(mail.from).to eq ['marketing@vinsol.com']
    end
  end
end
