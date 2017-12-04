require 'concurrent/actor'
require 'concurrent/future'
require 'hanami/view'
require_relative 'kontena/logging'
require_relative 'kontena/models/service'
require_relative 'kontena/models/tcp_service'
require_relative 'kontena/models/upstream'

require_relative 'kontena/cert_splitter'

require_relative 'kontena/views/haproxy'

require_relative 'kontena/actors/lb_supervisor'
require_relative 'kontena/actors/etcd_watcher'
require_relative 'kontena/actors/haproxy_config_generator'
require_relative 'kontena/actors/haproxy_config_writer'
require_relative 'kontena/actors/haproxy_spawner'
require_relative 'kontena/actors/syslog_server'

Hanami::View.configure do
  root 'lib/kontena/templates'
end
Hanami::View.load!
