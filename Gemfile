source 'https://rubygems.org'
#gem 'yajl-ruby'
gem 'rails', '3.2.12'
gem 'yajl-ruby'
gem 'bcrypt-ruby'
gem "mongoid"#, git: 'https://github.com/mongoid/mongoid.git'
gem 'uuid'
gem 'airbrake', '3.0.9'
gem 'passenger', '~> 3.0.11'
gem "devise"
gem 'fastercsv', :platform => :ruby_18
gem 'jquery-rails'
gem 'haml'
gem "cancan"
gem "thin"
#gem 'font-awesome-sass-rails', "~> 3.0"
gem 'rails_admin', git: 'https://github.com/sferik/rails_admin.git'
gem 'mongoid_search'
gem 'whenever'
gem 'aws-sdk'
gem 'paperclip', git: 'https://github.com/thoughtbot/paperclip.git'
gem "mongoid-paperclip", :require => "mongoid_paperclip"
gem "rails_admin_map_field", :git => "https://github.com/trademobile/rails_admin_map_field.git"
gem "mini_exiftool", "~> 1.6.0"
gem 'rubyzip', require: 'zip/zip'
gem 'delayed_job_mongoid'
gem 'font-awesome-sass', '~> 3.0'
gem 'mongoid-slug'
#gem 'rack-perftools_profiler', :require => 'rack/perftools_profiler'
# Gems used only for assets and not required
# in production environments by default.

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :doc do
  gem 'sdoc', git: 'git://github.com/ivanyv/sdoc.git'
end

group :development, :test do
  # gem 'pry-rails'
  gem 'ruby-debug19'
  gem 'email_spec'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'capistrano_colors'
  gem 'capistrano-appiphany', git: 'git://github.com/adriandewitts/capistrano-appiphany.git'
  gem 'highline'
  gem 'rails-dev-boost', git: 'git://github.com/thedarkone/rails-dev-boost.git', require: 'rails_development_boost'
  gem 'spin'
  gem 'guard'
  gem 'guard-spin'
  gem 'guard-bundler'
  gem 'guard-rake'
  gem 'guard-passenger'
  gem 'rb-fsevent', '~> 0.9.1'
#  gem 'rb-inotify'
#  gem 'libnotify'
end

group :test do
  # Pretty printed test output
  gem 'turn' #, '< 0.8.3'
  gem 'database_cleaner'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails', '~> 3.0'
  gem 'timecop'
  gem 'guard-rspec', '0.5.2'
  #gem 'shoulda-matchers'
end

gem 's3_direct_upload'