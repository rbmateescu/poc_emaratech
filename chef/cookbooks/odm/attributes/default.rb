########################################################
#     Copyright IBM Corp. 2016, 2018
########################################################
####################
# PRODUCT
####################

default['odm']['install_dir'] = '/opt/IBM/ODM91'
default['odm']['vault']['name'] = node['ibm_internal']['vault']['name']
default['odm']['vault']['encrypted_id'] = node['ibm_internal']['vault']['item']
