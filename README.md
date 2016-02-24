== Welcome to NACC Web Service
* Config:
  - Create config.yml base on config.yml.example
  - Update errbit config in config/initializers/errbit.rb
  - Update site's domain in config/deploy/production.rb and config/deploy/nginx

* Deploy:
  bundle exec cap production deploy
