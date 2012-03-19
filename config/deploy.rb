set :default_environment, {
  'PATH' => "/home/newhouse/.rvm/gems/ruby-1.9.3-p125/bin:/home/newhouse/.rvm/bin:$PATH",
  'RUBY_VERSION' => 'ruby 1.9.3',
  'GEM_HOME'     => '/home/newhouse/.rvm/gems/ruby-1.9.3-p125',
  'GEM_PATH'     => '/home/newhouse/.rvm/gems/ruby-1.9.3-p125/',
  'BUNDLE_PATH'  => '/home/newhouse/.rvm/gems/ruby-1.9.3-p125/'  # If you are using bundler.
}
require "rvm/capistrano"

set :rvm_ruby_string, '1.9.3'
set :rvm_type, :user

#load 'deploy/assets'


# bundler bootstrap
require 'bundler/capistrano'

set :bundle_flags, ""


set :user, 'newhouse'
set :domain, 'mechanicalmap.dev.fabelier.org'
set :application, "mechanicalmap"
set :applicationdir, "~/mechanicalmap"


set :repository, "git://github.com/nmaisonneuve/mechanicalmap.git"  # Your clone URL
set :scm, "git"
set :scm_verbose, true
set :git_enable_submodules, 1

# roles (servers)
role :web, domain
role :app, domain
role :db, domain, :primary=>true

# deploy config
set :deploy_to, applicationdir
set :deploy_via, :remote_cache
set :use_sudo, false


default_run_options[:pty] = true  # Must be set for the password prompt from git to work
ssh_options[:forward_agent] = true


# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts


# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do

# cap deploy deploy:db_schema_load
  desc "Load the initial schema - it will WIPE your database, use with care"
  task :db_schema_load, :roles => :db, :only => { :primary => true } do
    puts <<-EOF

************************** WARNING ***************************
If you type [yes], rake db:schema:load will WIPE your database
any other input will cancel the operation.
**************************************************************

EOF
    answer = Capistrano::CLI.ui.ask "Are you sure you want to WIPE your database?: "
    if answer == 'yes'
      run "cd #{current_path} && RAILS_ENV=production bundle exec rake db:create"
      run "cd #{current_path} && RAILS_ENV=production bundle exec rake db:schema:load"
    else
      puts "Cancelled."
    end
  end

   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end