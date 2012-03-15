require 'bundler/capistrano'


set :user, 'newhouse'
set :domain, 'mechanicalmap.dev.fabelier.org'
set :application, "mechanicalmap"
set :applicationdir, "~/mechanicalmap"


set :repository, "git@github.com:vanpelt/rails-app.git"  # Your clone URL
set :scm, "git"
set :scm_verbose, true


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
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end