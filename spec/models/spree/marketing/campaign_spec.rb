require 'spec_helper'

describe Spree::Marketing::Campaign, type: :model do
  include ActiveJob::TestHelper

  let(:json_stats_data) { '{ "log_ins": { "emails": ["vinay@vinsol.com"], "count": 1 }, "emails_sent": 3, "emails_delivered": 3, "emails_opened": 3, "emails_bounced": 3 }' }
  let(:campaign) { create(:marketing_campaign, stats: json_stats_data) }
  let(:list) { create(:marketing_list) }
  let(:campaigns_data) do
    [{ id: '12456', type: 'regular', settings: { title: 'test' },
       recipients: { list_id: list.uid }, send_time: Time.current.to_s }.with_indifferent_access]
  end

  after { clear_enqueued_jobs }

  describe 'Constants' do
    it 'DEFAULT_SEND_TIME_GAP equals to time gap since which sent campaigns are synced' do
      expect(Spree::Marketing::Campaign::DEFAULT_SEND_TIME_GAP).to eq 1.day
    end
    it 'STATS_COUNT_KEYS equals to the keys stored in stats for email counts' do
      expect(Spree::Marketing::Campaign::STATS_COUNT_KEYS).to eq %i[emails_sent emails_bounced emails_opened emails_delivered]
    end
  end

  it_behaves_like 'calculate_reports'

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:list) }
    it { is_expected.to validate_presence_of(:stats) }
    it { is_expected.to validate_presence_of(:mailchimp_type) }
    it { is_expected.to validate_presence_of(:scheduled_at) }
    context 'validates uniqueness of' do
      subject { campaign }

      it { is_expected.to validate_uniqueness_of(:uid).case_insensitive }
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:list).class_name('Spree::Marketing::List') }
    it { is_expected.to have_many(:recipients).class_name('Spree::Marketing::Recipient').dependent(:restrict_with_error) }
    it { is_expected.to have_many(:contacts).through(:recipients) }
  end

  describe 'Callbacks' do
    it { is_expected.to callback(:enqueue_update).after(:create) }
  end

  describe '.generate' do
    context 'when list is not destroyed' do
      it 'generated campaign uids equal fetched campaigns_data ids' do
        expect(Spree::Marketing::Campaign.generate(campaigns_data).first.uid).to eq campaigns_data.first[:id]
      end
      it 'generated campaign is associated to list' do
        expect(Spree::Marketing::Campaign.generate(campaigns_data).first.list).to eq list
      end
    end

    context 'when list is destroyed' do
      before { list.destroy }

      it 'generated campaign uids equal fetched campaigns_data ids' do
        expect(Spree::Marketing::Campaign.generate(campaigns_data).first.uid).to eq campaigns_data.first[:id]
      end
      it 'generated campaign is associated to list' do
        expect(Spree::Marketing::Campaign.generate(campaigns_data).first.list).to eq list
      end
    end
  end

  describe '.sync' do
    SpreeMarketing::CONFIG ||= { Rails.env => {} }.freeze

    before do
      allow(CampaignSyncJob).to receive(:perform_later).and_return(true)
    end

    after { Spree::Marketing::Campaign.sync(Time.current.to_s) }

    it 'schedules CampaignSyncJob with since_send_time' do
      expect(CampaignSyncJob).to receive(:perform_later).with(Time.current.to_s)
    end
  end

  describe '#populate' do
    let(:contact) { create(:marketing_contact) }
    let(:recipients_data) { [{ email_id: contact.uid, email_address: contact.email, status: 'sent' }.with_indifferent_access] }
    let (:stats) { '{"emails_sent":200,"emails_bounced":2,"emails_opened":100,"emails_delivered":198}' }
    let(:report_data) do
      { id: '42694e9e57',
        emails_sent: 200,
        bounces: {
          hard_bounces: 0,
          soft_bounces: 2,
          syntax_errors: 0
        },
        forwards: {
          forwards_count: 0,
          forwards_opens: 0
        },
        opens: {
          opens_total: 186,
          unique_opens: 100,
          open_rate: 42,
          last_open: '2015-09-15T19:15:47+00:00'
        } }.with_indifferent_access
    end

    context 'when mailchimp campaign data is valid' do
      let(:synced_campaign) { Spree::Marketing::Campaign.generate(campaigns_data).first }

      before do
        synced_campaign.update_stats(report_data)
        synced_campaign.populate(recipients_data)
      end

      it 'synced campaign is saved' do
        expect(synced_campaign).to be_persisted
      end
      it 'synced campaign stats is equal to recipients set and emails sent count' do
        expect(synced_campaign.stats).to eq stats.to_s
      end
      it 'synced campaign recipients count equals mailchimp fetched recipients data' do
        expect(synced_campaign.recipients.count).to eq recipients_data.count
      end
      it 'synced recipients are associated to contacts' do
        expect(synced_campaign.recipients.first.contact).to eq contact
      end
    end

    context 'when mailcimp campaign is not valid' do
      let(:invalid_campaigns_data) do
        [{ id: '12456', type: 'regular', settings: { title: 'test' },
           recipients: { list_id: 'test' }, send_time: Time.current.to_s }.with_indifferent_access]
      end
      let(:synced_campaign) { Spree::Marketing::Campaign.generate(invalid_campaigns_data).first }

      before { synced_campaign.populate(recipients_data) }

      it 'synced campaign is not saved' do
        expect(synced_campaign).not_to be_persisted
      end
      it 'synced campaign recipients do not exist' do
        expect(synced_campaign.recipients.count).to eq 0
      end
    end
  end

  describe '#enqueue_update' do
    context 'when scheduled_at is of previous night' do
      let(:not_saved_campaign) { build(:marketing_campaign, scheduled_at: Time.current - 4.hours) }

      context '#enqueue_reports_generation_job' do
        it 'enqueues report generation job to run 6 hours after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(ReportsGenerationJob).at(not_saved_campaign.scheduled_at + 6.hours)
        end
        it 'enqueues report generation job to run 12 hours after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(ReportsGenerationJob).at(not_saved_campaign.scheduled_at + 12.hours)
        end
        it 'enqueues report generation job to run 18 hours after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(ReportsGenerationJob).at(not_saved_campaign.scheduled_at + 18.hours)
        end
        it 'enqueues report generation job to run a day after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(ReportsGenerationJob).at(not_saved_campaign.scheduled_at.tomorrow)
        end
      end

      context '#enqueue_stats_update_job' do
        it 'enqueues report generation job to run 6 hours after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(CampaignModificationJob).at(not_saved_campaign.scheduled_at + 6.hours)
        end
        it 'enqueues report generation job to run 12 hours after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(CampaignModificationJob).at(not_saved_campaign.scheduled_at + 12.hours)
        end
        it 'enqueues report generation job to run 18 hours after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(CampaignModificationJob).at(not_saved_campaign.scheduled_at + 18.hours)
        end
        it 'enqueues report generation job to run a day after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(CampaignModificationJob).at(not_saved_campaign.scheduled_at.tomorrow)
        end
      end
    end

    context 'when scheduled_at is of previous morning' do
      let(:not_saved_campaign) { build(:marketing_campaign, scheduled_at: Time.current - 20.hours) }

      context '#enqueue_reports_generation_job' do
        it 'enqueues report generation job to run a day after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(ReportsGenerationJob).at(not_saved_campaign.scheduled_at.tomorrow)
        end
      end

      context '#enqueue_stats_update_job' do
        it 'enqueues report generation job to run a day after campaign\'s scheduled_at' do
          expect { not_saved_campaign.save }.to have_enqueued_job(CampaignModificationJob).at(not_saved_campaign.scheduled_at.tomorrow)
        end
      end
    end
  end

  describe '#stat_counts' do
    it 'returns a hash with stats corresponding to STATS_COUNT_KEYS only' do
      expect(campaign.stat_counts).to eq(JSON.parse(json_stats_data).symbolize_keys.slice(*Spree::Marketing::Campaign::STATS_COUNT_KEYS))
    end
  end
end
