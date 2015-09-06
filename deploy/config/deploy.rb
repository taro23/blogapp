# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'blogapp'
# set :repo_url, 'git@github.com:taro23/blogapp.git'
set :repo_url, 'https://github.com/taro23/blogapp.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/application'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_dirs, %w{tmp/cache tmp/cache/models tmp/cache/persistent tmp/cache/views tmp/logs tmp/sessions tmp/tests}
set :linked_files, %w{production.php}

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# namespace :deploy do

#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end

# end

framework_tasks = ["symlink:linked_dirs", "symlink:linked_files"]
framework_tasks.each do |t|
  Rake::Task["deploy:#{t}"].clear
end
set :password, ask('Server password:', nil)

namespace :deploy do
  before :check, :create_app_dir do
    on release_roles :app do |role|
      execute :sudo, :mkdir, '-p', '/var/www/application'
      execute :sudo, :chown, "#{host.user}:#{role.properties.group}", '/var/www/application'
    end
  end

  namespace :check do
    after :linked_dirs, :chown_linked_dirs do
      on release_roles :app do |role|
         execute :sudo, :find, shared_path, "-type d -print", "|", :xargs, :chmod, "777"
      end
    end

    before :linked_files, :upload_app_config do
      on release_roles :app do |role|
        if (role.properties.app_config.instance_of?(String)) then
          upload! "./config/deploy/#{role.properties.app_config}", shared_path
        end
      end
    end
  end

  after :updated, :composer_install do 
    on roles(:app) do
      execute :composer, "--working-dir=#{release_path}/app", "--no-dev", :install
    end
  end

  after :updated, :migrate do
    on release_roles :db do |role|
      cake_env = role.properties.cake_env

      execute "env CAKE_ENV=#{cake_env} #{release_path}/app/Console/cake Migrations.migration run all -p"
    end
  end

  namespace :symlink do
    task :linked_files do
      on release_roles :app do |role|
        if (role.properties.app_config.instance_of?(String)) then
          target = release_path.join("app/Config/bootstrap/environments/#{role.properties.app_config}")
          source = shared_path.join(role.properties.app_config)
          execute :ln, '-s', source, target
        end
      end
    end

    task :linked_dirs do
      on release_roles :app do
        target = release_path.join('app/tmp')
        source = shared_path.join('tmp')
        execute :sudo, :rm, '-rf', target
        execute :ln, '-s', source, target
      end
    end
  end

  after :published, :restart_php_fpm do
    on release_roles :app do |role|
      execute :sudo, :service, 'php5-fpm', :restart
    end
  end
end

