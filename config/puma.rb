min_threads_count = Integer(ENV.fetch('RAILS_MIN_THREADS') { 5 })
max_threads_count = Integer(ENV.fetch('RAILS_MAX_THREADS') { 5 })
threads min_threads_count, max_threads_count

port ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RACK_ENV') { 'development' }
#workers Integer(ENV.fetch('WEB_CONCURRENCY') { 5 })
if ENV['RACK_ENV'] == 'production'
  bind "unix:///var/run/puma/my_app.sock"
  # activate_control_app "unix:///var/run/puma/my_app_control.sock", {no_token: true}
else
  bind "tcp://127.0.0.1"
end

preload_app!
plugin :tmp_restart
