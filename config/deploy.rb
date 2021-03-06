# user should have rigths username ALL=(ALL:ALL) NOPASSWD: ALL

require 'bundler/capistrano'
require 'sushi/ssh'
require 'capistrano_colors'

# multistage
set :stages, %w(production staging)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

# whenever
#set :whenever_command, "bundle exec whenever"
#set :whenever_environment, defer { stage }
#set :whenever_identifier, defer { "#{application}_#{stage}" }
#require "whenever/capistrano"

set :domain_name, 'domain.com'
set :recipes_dir, File.expand_path('/../cap-recipes', __FILE__)


load recipes_dir+'/config/recipes/base'
load recipes_dir+'/config/recipes/system_user'
load recipes_dir+'/config/recipes/nginx'
load recipes_dir+'/config/recipes/redis'
load recipes_dir+'/config/recipes/mysql'
load recipes_dir+'/config/recipes/mongodb'
load recipes_dir+'/config/recipes/postgresql'
load recipes_dir+'/config/recipes/rbenv'
#load recipes_dir+"config/recipes/check"

#load recipes_dir+'config/recipes/wordpress'

set :ruby_version, '2.0.0-p195'

server '0.0.0.0', :web, :app, :db, primary: true

# custom
set :domain, 'yourapp.domain'
set :rails_server, 'unicorn'

#standard
set :user, 'deployer'
set :application, 'yourapp'

set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, 'git'
set :repository, 'git@github.com:your/repository.git'

set :unicorn_user,    -> { user }
set :unicorn_pid,     -> { "#{shared_path}/pids/unicorn.pid"  }
set :unicorn_config,  -> { "#{shared_path}/config/unicorn.rb" }
set :unicorn_log,     -> { "#{shared_path}/log/unicorn.log"   }
set :unicorn_workers, 1

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

if rails_server.eql?('unicorn')
  load recipes_dir+'/config/recipes/unicorn'
else
  load recipes_dir+'/config/recipes/thin'
end

after 'deploy:update_code', 'deploy:migrate'
after 'deploy', 'deploy:cleanup' # keep only the last 5 releases

namespace :deploy do
  task :restart do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn_rails -c #{unicorn_config} -E #{rails_env} -D; fi"
  end
  task :start do
    run "cd #{deploy_to}/current && bundle exec unicorn_rails -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end

# Allow run cap deploy without recipes
namespace :postgres do
  desc 'Symlink the database.yml file into latest release'
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  after 'deploy:finalize_update', 'postgres:symlink'
end
