require_relative '../lib/bound/config'
threads_count = Bound.config.web_server&.max_threads&.to_i || 5
threads         threads_count, threads_count

bind_address  = Bound.config.web_server&.bind_address || '127.0.0.1'
bind_port     = Bound.config.web_server&.port&.to_i || 3000
bind            "tcp://#{bind_address}:#{bind_port}"

environment     Bound.config.rails&.environment || 'development'
