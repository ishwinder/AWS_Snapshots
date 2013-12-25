require 'resque_scheduler'

uri = URI.parse("http://localhost:6379")
Resque.redis = Redis.new(:host => uri.host, :port => uri.port)

# schedule changes and applies them on the fly.
# Note: This feature is only available in >=2.0.0.
# If you want to be able to dynamically change the schedule,
# uncomment this line.  A dynamic schedule can be updated via the
# Resque::Scheduler.set_schedule (and remove_schedule) methods.
# When dynamic is set to true, the scheduler process looks for
Resque::Scheduler.dynamic = true

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

# The schedule doesn't need to be stored in a YAML, it just needs to
# be a hash.  YAML is usually the easiest.
Resque.schedule = YAML.load_file(Rails.root.join('config', 'resque_schedule.yml'))

# This helps heroku find the correct database after a deployment.
Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }

unless Rails.application.config.cache_classes
 Resque.after_fork do |job|
   ActionDispatch::Reloader.cleanup!
   ActionDispatch::Reloader.prepare!
 end
end

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      # If the actual cache respond to reconnect go on.
      Rails.cache.reconnect if Rails.cache.respond_to? :reconnect
      # Reconnect Resque Redis instance.
      Resque.redis.client.reconnect
    end
  end
end