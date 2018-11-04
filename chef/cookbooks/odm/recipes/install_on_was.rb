#########################################################################
########################################################
#	  Copyright IBM Corp. 2016, 2018
########################################################
# <> Install  recipe (install.rb)
# <> Installation recipe, source the version, unpack the file and install product
#
#########################################################################

# Cookbook Name  - odm
# Recipe         - install
#----------------------------------------------------------------------------------------------------------------------------------------------

# Set Vars

security_params = define_security_params
ruby_block "Create storage files IM ODM Install" do
  block do
    generate_storage_file(node['was']['os_users']['was']['name'], node['was']['os_users']['was']['gid'], "#{node['was']['os_users']['was']['home']}/IBM/InstallationManager")
  end
end

# Get WAS Admin User

adminuserpwd = node['was']['security']['admin_user_pwd']
chef_vault = node['odm']['vault']['name']

unless chef_vault.empty?
  encrypted_id = node['odm']['vault']['encrypted_id']
  require 'chef-vault'
  adminuserpwd = chef_vault_item(chef_vault, encrypted_id)['was']['security']['admin_user_pwd']
end

# Prepare installation template
template '/tmp/odm.install.xml' do
  source 'odmWAS.install.xml.erb'
  variables(
    :REPO_LOCATION => node['ibm']['im_repo'],
    :INSTALL_LOCATION => node['odm']['install_dir'],
    :IMSHARED => '/opt/IBM/IMShared',
    :WAS_LOCATION => node['was']['install_dir'],
    :WAS_USER => node['was']['admin_user'],
    :WAS_PASSWORD => adminuserpwd
  )
end

install_command = "./imcl input /tmp/odm.install.xml #{security_params} -showProgress -accessRights nonAdmin -acceptLicense -log /tmp/odm.install.log"
install_dir = "#{node['was']['os_users']['was']['home']}/IBM/InstallationManager/eclipse/tools"

execute "install ODM" do
  user node['was']['os_users']['was']['name']
  group node['was']['os_users']['was']['gid']
  cwd install_dir
  command install_command
  not_if { File.exist?("#{node['odm']['install_dir']}/shared/bin/startserver.sh") }
end

derbyDC = "#{node['was']['install_dir']}/profileTemplates/odm/decisioncenter/default/derbyDC.properties"
template derbyDC do
  source 'derbyDC.properties.erb'
  variables(
    :WAS_LOCATION => node['was']['install_dir']
  )
end

derbyDS = "#{node['was']['install_dir']}/profileTemplates/odm/decisionserver/default/derbyDS.properties"
template derbyDS  do
  source 'derbyDS.properties.erb'
  variables(
    :WAS_LOCATION => node['was']['install_dir']
  )
end


augment_ds = "./bin/manageprofiles.sh -augment -profileName #{node['was']['profiles']['standalone_profiles']['standalone1']['profile']} -templatePath ./profileTemplates/odm/decisionserver/default -odmHome #{node['odm']['install_dir']} -databaseConfigFile ./profileTemplates/odm/decisionserver/default/derbyDS.properties"

execute "Augment WAS DS" do
  user node['was']['os_users']['was']['name']
  group node['was']['os_users']['was']['gid']
  cwd node['was']['install_dir']
  command augment_ds
  not_if { File.exist?("#{node['was']['profile_dir']}/#{node['was']['profiles']['standalone_profiles']['standalone1']['profile']}/installedApps/#{node['was']['profiles']['standalone_profiles']['standalone1']['cell']}/jrules-res-management.ear") }
end

augment_dc = "./bin/manageprofiles.sh -augment -profileName #{node['was']['profiles']['standalone_profiles']['standalone1']['profile']} -templatePath ./profileTemplates/odm/decisioncenter/default -odmHome #{node['odm']['install_dir']} -databaseConfigFile ./profileTemplates/odm/decisioncenter/default/derbyDC.properties"

execute "Augment WAS DC" do
  user node['was']['os_users']['was']['name']
  group node['was']['os_users']['was']['gid']
  cwd node['was']['install_dir']
  command augment_dc
  not_if { File.exist?("#{node['was']['profile_dir']}/#{node['was']['profiles']['standalone_profiles']['standalone1']['profile']}/installedApps/#{node['was']['profiles']['standalone_profiles']['standalone1']['cell']}/teamserver.ear") }
end

stop_was = "./stopServer.sh #{node['was']['profiles']['standalone_profiles']['standalone1']['server']}"
execute "Stop WAS DC" do
  user node['was']['os_users']['was']['name']
  group node['was']['os_users']['was']['gid']
  cwd "#{node['was']['profile_dir']}/#{node['was']['profiles']['standalone_profiles']['standalone1']['profile']}/bin"
  command stop_was
  only_if "ps -ef | grep #{node['was']['profiles']['standalone_profiles']['standalone1']['server']} | grep -v grep"
end

start_was = "./startServer.sh #{node['was']['profiles']['standalone_profiles']['standalone1']['server']}"
execute "Start WAS DC" do
  user node['was']['os_users']['was']['name']
  group node['was']['os_users']['was']['gid']
  cwd "#{node['was']['profile_dir']}/#{node['was']['profiles']['standalone_profiles']['standalone1']['profile']}/bin"
  command start_was
  not_if "sleep 5; ps -ef | grep #{node['was']['profiles']['standalone_profiles']['standalone1']['server']} | grep -v grep"
end


