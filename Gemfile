source 'http://rubygems.org'

gem 'rails'
gem 'jquery-rails'

gem "sidekiq"
gem "slim"
gem "sinatra"

gem 'gravatar_image_tag'

gem 'devise'
gem 'omniauth'
gem "omniauth-twitter"
gem 'omniauth-google-oauth2'
gem "omniauth-facebook"

gem 'color'
#gem "RedCloth"
gem "fusion_tables"
gem "nofxx-georuby"
gem "whenever"

group :development, :test do
  gem 'sqlite3'
end

group :production do
  gem 'pg'
  gem 'thin'
  # Use unicorn as the app server
  # gem 'unicorn'
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'backbone-on-rails'
  gem 'anjlab-bootstrap-rails', :require => 'bootstrap-rails',
      :git => 'git://github.com/anjlab/bootstrap-rails.git'
  gem 'uglifier'
  gem 'ace-rails',  :git => 'git://github.com/jbfeldis/ace-rails.git'
end

# To use ActiveModel has_secure_password
  # gem 'bcrypt-ruby', '~> 3.0.0'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'