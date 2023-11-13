threads 5, 5
port ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RACK_ENV') { 'development' }
workers 0

if ENV['RACK_ENV'] == 'production'
  bind "unix:///var/run/puma/my_app.sock"
else
  bind "tcp://127.0.0.1"
end

plugin :tmp_restart
