# https://github.com/rails/rails/pull/18260 is merged in master,
# but not released in current dependent rails version.
ActiveJob::Base.class_eval do
  def self.deserialize(job_data)
    job = job_data['job_class'].constantize.new
    job.deserialize(job_data)
    job
  end

  def deserialize(job_data)
    self.job_id               = job_data['job_id']
    self.queue_name           = job_data['queue_name']
    self.serialized_arguments = job_data['arguments']
  end
end
