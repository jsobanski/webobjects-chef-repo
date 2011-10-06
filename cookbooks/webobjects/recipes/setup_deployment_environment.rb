


user "#{node[:webobjects][:webobjects_user]}" do
  home "/home/#{node[:webobjects][:webobjects_user]}"
  shell "/bin/bash"
  supports :manage_home => true
end
group "#{node[:webobjects][:webobjects_group]}" do
  members [ node[:webobjects][:webobjects_user] ]
end

script "setup_user_environment" do
  interpreter "bash"
  user node[:webobjects][:webobjects_user]
  code <<-EOH
  touch /home/#{node[:webobjects][:webobjects_user]}/.bash_profile
  cat >> /home/#{node[:webobjects][:webobjects_user]}/.bash_profile << END
NEXT_ROOT=#{node[:webobjects][:webobjects_WOLocalRootDirectory_dir]}; export NEXT_ROOT
WOROOT=#{node[:webobjects][:webobjects_WOLocalRootDirectory_dir]}; export WOROOT
  EOH
end



directory "#{node[:webobjects][:webobjects_WOApplications_dir]}" do
  recursive true
  owner node[:webobjects][:webobjects_user]
  group node[:webobjects][:webobjects_group]
  action :create
end
directory "#{node[:webobjects][:webobjects_WOWebServerResources_dir]}" do
  recursive true
  owner node[:webobjects][:webobjects_user]
  group node[:webobjects][:webobjects_group]
  action :create
end
directory "#{node[:webobjects][:webobjects_WOWebServerResources_dir]}/WebObjects" do
  recursive true
  owner node[:webobjects][:webobjects_user]
  group node[:webobjects][:webobjects_group]
  action :create
end
directory "#{node[:webobjects][:webobjects_WODeployment_dir]}" do
  recursive true
  owner node[:webobjects][:webobjects_user]
  group node[:webobjects][:webobjects_group]
  action :create
end
directory "#{node[:webobjects][:webobjects_WODeployment_dir]}/Configuration" do
  recursive true
  owner node[:webobjects][:webobjects_user]
  group node[:webobjects][:webobjects_group]
  action :create
end

if !File.exists?("#{node[:webobjects][:webobjects_WODeployment_dir]}/#{node[:webobjects][:webobjects_JavaMonitor_app]}")

  remote_file "#{node[:webobjects][:webobjects_WODeployment_dir]}/#{node[:webobjects][:webobjects_JavaMonitor_local_package]}" do
    source "#{node[:webobjects][:webobjects_JavaMonitor_remote_url]}"
    owner node[:webobjects][:webobjects_user]
    group node[:webobjects][:webobjects_group]
    mode "0744"
  end
  script "webobjects_javamonitor_unpackage_source" do
    interpreter "bash"
    user node[:webobjects][:webobjects_user]
    group node[:webobjects][:webobjects_group]
    cwd "#{node[:webobjects][:webobjects_WODeployment_dir]}"
    code <<-EOH
    tar -zxf #{node[:webobjects][:webobjects_JavaMonitor_local_package]} -C #{node[:webobjects][:webobjects_WODeployment_dir]} --exclude="._*"
    EOH
  end
  file "#{node[:webobjects][:webobjects_WODeployment_dir]}/#{node[:webobjects][:webobjects_JavaMonitor_local_package]}" do
    action :delete
  end

end

if !File.exists?("#{node[:webobjects][:webobjects_WODeployment_dir]}/#{node[:webobjects][:webobjects_wotaskd_app]}")

  remote_file "#{node[:webobjects][:webobjects_WODeployment_dir]}/#{node[:webobjects][:webobjects_wotaskd_local_package]}" do
    source "#{node[:webobjects][:webobjects_wotaskd_remote_url]}"
    owner node[:webobjects][:webobjects_user]
    group node[:webobjects][:webobjects_group]
    mode "0744"
  end
  script "webobjects_javamonitor_unpackage_source" do
    interpreter "bash"
    user node[:webobjects][:webobjects_user]
    group node[:webobjects][:webobjects_group]
    cwd "#{node[:webobjects][:webobjects_WODeployment_dir]}"
    code <<-EOH
    tar -zxf #{node[:webobjects][:webobjects_wotaskd_local_package]} -C #{node[:webobjects][:webobjects_WODeployment_dir]} --exclude="._*"
    EOH
  end
  file "#{node[:webobjects][:webobjects_WODeployment_dir]}/#{node[:webobjects][:webobjects_wotaskd_local_package]}" do
    action :delete
  end

end

script "modify_webobjects_deployment_JavaMonitor" do
  interpreter "bash"
  user node[:webobjects][:webobjects_user]
  code <<-EOH
  cat >> /opt/WODeployment/JavaMonitor.woa/Contents/Resources/Properties << END

WODeploymentConfigurationDirectory=#{node[:webobjects][:webobjects_WODeployment_dir]}/Configuration
WOLocalRootDirectory=#{node[:webobjects][:webobjects_WOLocalRootDirectory_dir]}
  EOH
end

script "modify_webobjects_deployment_wotaskd" do
  interpreter "bash"
  user node[:webobjects][:webobjects_user]
  code <<-EOH
  cat >> #{node[:webobjects][:webobjects_WODeployment_dir]}/wotaskd.woa/Contents/Resources/Properties << END

WODeploymentConfigurationDirectory=#{node[:webobjects][:webobjects_WODeployment_dir]}/Configuration
WOLocalRootDirectory=#{node[:webobjects][:webobjects_WOLocalRootDirectory_dir]}
  EOH
end


file "#{node[:webobjects][:webobjects_WODeployment_dir]}/JavaMonitor.woa/JavaMonitor" do
  mode "0750"
end
file "#{node[:webobjects][:webobjects_WODeployment_dir]}/wotaskd.woa/Contents/Resources/SpawnOfWotaskd.sh" do
  mode "0750"
end
file "#{node[:webobjects][:webobjects_WODeployment_dir]}/wotaskd.woa/wotaskd" do
  mode "0750"
end

template "/etc/init.d/webobjects" do
  source "wo-webobjects.initd.erb"
  mode "0755"
end

service "webobjects" do
  action [ :enable, :start ]
end