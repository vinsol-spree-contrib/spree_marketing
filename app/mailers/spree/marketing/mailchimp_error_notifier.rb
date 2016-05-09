module Spree
  module Marketing
    class MailchimpErrorNotifier < ActionMailer::Base
      default from: 'marketing@vinsol.com'

      def notify_failure(job_type, exception_title, exception_detail)
        @job_type = job_type.underscore.humanize
        @exception_title = exception_title
        @exception_detail = exception_detail

        mail to: SpreeMarketing::CONFIG[Rails.env][:campaign_defaults][:from_email],
             subject: t('.subject')
      end
    end
  end
end
