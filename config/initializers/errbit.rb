Airbrake.configure do |config|
  config.api_key     = 'api_key'
  config.host        = 'errbit_host'
  config.port        = 80
  config.secure      = config.port == 443
end