module Spree
  module Marketing
    class MailchimpErrorNotifier < ActionMailer::Base
      default from: 'marketing@vinsol.com'

      def notify_failure(job_type, exception_message)
        @job = job_type
        @exception = exception_message

        mail to: SpreeMarketing::CONFIG[Rails.env][:campaign_defaults][:from_email],
             subject: t('.subject')
      end
    end
  end
end
