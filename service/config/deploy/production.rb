server '192.168.1.221', :app, :web, :db, :primary => true
set :branch, "master"
set :rails_env, 'production'
set :deploy_to, "/var/www/#{application}"
set :vhost_tmpl_name, "production.vhost.conf.erb"
set :unicorn_rack_env, 'production'
