########################################################
#	  Copyright IBM Corp. 2016, 2016
########################################################

name 'odm'
maintainer 'IBM Corp'
maintainer_email ''
license 'Copyright IBM Corp. 2012, 2018'
issues_url   'https://github.com/IBM-CAMHub-Open/cookbook_ibm_odm_multios/issues'
source_url   'https://github.com/IBM-CAMHub-Open/cookbook_ibm_odm_multios'
chef_version '>= 12.5' if respond_to?(:chef_version)
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0'
depends 'ibm_cloud_utils'
depends 'im'
depends 'wasliberty'
supports 'redhat'
supports 'debian'
description <<-EOF
## DESCRIPTION
Installs/Configures ODM on a single WebSphere Liberty Server

### Platform
* RHEL 6.6
* RHEL 7.2

## Versions
IBM ODM Version 8.9.1

## Use Cases
* Basic - Install Liberty in a single application server

## Platform Pre-Requisites
* Linux YUM Repository
* Installation Manager Repository
EOF

