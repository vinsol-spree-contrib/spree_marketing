module MailchimpErrorHandler
  extend ActiveSupport::Concern

  RETRY_LIMIT = 5

  included { rescue_from Gibbon::MailChimpError, with: :rescue_with_handler }

  def serialize
    super.merge('retry_attempt' => retry_attempt)
  end

  def deserialize(job_data)
    super(job_data)
    @retry_attempt = job_data['retry_attempt']
  end

  def retry_attempt
    @retry_attempt ||= 1
  end

  def rescue_with_handler(exception)
    if should_retry?(retry_attempt)
      p "retrying job : #{retry_attempt}"
      @retry_attempt += 1
      retry_job
    else
      notify_admin(exception)
    end
  end

  def notify_admin(exception)
    Spree::Marketing::MailchimpErrorNotifier.notify_failure(self.class.to_s, exception.title, exception.detail).deliver_later
  end

  def should_retry?(retry_attempt)
    retry_attempt <= RETRY_LIMIT
  end
end
