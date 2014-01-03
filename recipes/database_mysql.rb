include_recipe "mysql::server"

# Setup bamboo user

grants_path = "/tmp/create_database.sql"

template grants_path do
  source "create_mysql_database.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  action :create
  #notifies :restart, "service[bamboo]", :delayed
end

execute "mysql-install-application-privileges" do
  command "/usr/bin/mysql -u root #{node[:mysql][:server_root_password].empty? ? '' : '-p' }#{node[:mysql][:server_root_password]} < #{grants_path}"
end
