
class BaseJob
  # Define the instance variables defining this job instance.
  # Only these variables will be serizalized when a job is enqueued.
  # Used as airbrake information when the job fails.
  class_attribute :parameters


  def perform
    # override in subclass
  end

  def enqueue!(options = {})
    Delayed::Job.enqueue(self, options)
  end

  def error(_job, exception, payload = parameters)
    logger.error(exception.message)
    logger.error(exception.backtrace.join("\n"))
    Airbrake.notify(exception, cgi_data: ENV.to_hash, parameters: payload)
  end

  def delayed_jobs
    Delayed::Job.where(handler: to_yaml)
  end

  def logger
    Delayed::Worker.logger || Rails.logger
  end

  def parameters
    Array(self.class.parameters).each_with_object({}) do |p, hash|
      hash[p] = instance_variable_get(:"@#{p}")
    end
  end

  # Only create yaml with the defined parameters.
  def encode_with(coder)
    parameters.each do |key, value|
      coder[key.to_s] = value
    end
  end
end
