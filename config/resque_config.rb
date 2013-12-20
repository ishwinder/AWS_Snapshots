require 'resque' # include resque so we can configure it
# This will make the tabs show up.
require 'resque_scheduler'
require 'resque_scheduler/server'

uri = URI.parse("http://localhost:6379")
Resque.redis = Redis.new(:host => uri.host, :port => uri.port)