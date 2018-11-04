#########################################################################
########################################################
#	  Copyright IBM Corp. 2016, 2018
########################################################
# <> Install  recipe (install.rb)
# <> Installation recipe, source the version, unpack the file and install product
#
#########################################################################

# Cookbook Name  - wasliberty
# Recipe         - install
#----------------------------------------------------------------------------------------------------------------------------------------------

# Set Vars

security_params = define_security_params
ruby_block "Create storage files for IM OBM Install" do
  block do
    generate_storage_file
  end
end

# Prepare installation template
template '/tmp/odmBasic.install.xml' do
  source 'odmBasic.install.xml.erb'
  variables(
    :REPO_LOCATION => node['ibm']['im_repo'],
    :INSTALL_LOCATION => node['odm']['install_dir'],
    :IMSHARED => '/opt/IBM/IMShared',
    :WLP_LOCATION => node['was_liberty']['install_dir']
  )
end

install_command = "./imcl input /tmp/odmBasic.install.xml #{security_params} -showProgress -accessRights admin -acceptLicense -log /tmp/odm.install.log"

execute "install ODM" do
  user user
  group group
  cwd '/opt/IBM/InstallationManager/eclipse/tools'
  command install_command
  not_if { File.exist?("#{node['odm']['install_dir']}/shared/bin/startserver.sh") }
end

install_dir = node['odm']['install_dir']
execute "Start ODM" do
  user 'root'
  group 'root'
  cwd node['odm']['install_dir'] +'/shared/bin'
  command 'nohup ./startserver.sh &'
end