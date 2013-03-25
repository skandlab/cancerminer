
set :application, "cancerminer"
set :user, "ajacminer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:eifion/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases



# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#    task :start do ; end
#    task :stop do ; end
#    task :restart, :roles => :app, :except => { :no_release => true } do
#      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#    end
#  end


