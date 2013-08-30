if (node[:bamboo][:external_data])
  directory "/mnt/data" do
    owner  "root"
    group  "root"
    mode "0775"
    action :create
  end
  mount "/mnt/data" do
    device "/dev/vdb1"
    fstype "ext4"
  end
end

include_recipe "java"

remote_file "/opt/atlassian-bamboo-agent-installer.jar" do
  source "#{node['bamboo']['url']}/agentServer/agentInstaller/atlassian-bamboo-agent-installer-#{node['bamboo']['version']}.jar"
  mode "0644"
  owner  node[:bamboo][:user]
  group  node[:bamboo][:group]
  not_if { ::File.exists?("/opt/atlassian-bamboo-agent-installer.jar") }
end

execute "java -Dbamboo.home=/mnt/data/bamboo -jar /opt/atlassian-bamboo-agent-installer.jar #{node['bamboo']['url']}/agentServer/ install" do
  user  node[:bamboo][:user]
  group  node[:bamboo][:group]
  not_if { ::File.exists?("/mnt/data/bamboo/installer.properties") }
end

#file "/opt/bamboo/.installed" do
#  owner  node[:bamboo][:user]
#  group  node[:bamboo][:group]
#  mode "0755"
#  action :create_if_missing
#end

link "/etc/init.d/bamboo-agent" do
  to "/mnt/data/bamboo/bin/bamboo-agent.sh"
end

service "bamboo-agent" do
  supports :restart => true, :status => true, :start => true, :stop => true
  action [:enable, :start]
end