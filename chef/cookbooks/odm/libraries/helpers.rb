########################################################
#	  Copyright IBM Corp. 2016, 2018
########################################################
# <> Module (helpers.rb)
#
#########################################################################

module Helpers

def define_im_repo
  if node['was_liberty']['install_mode'] == "group"
    require 'net/http'
    uri = URI.parse(node['ibm']['im_repo'])
    download_self_signed_certificate
    new_host = self_signed_certificate_name
    im_repo = node['ibm']['im_repo'].gsub(uri.host, new_host.chomp)
  else
    im_repo = node['ibm']['im_repo']
  end
  im_repo
end

def define_security_params
  security_params = if node['ibm']['im_repo_user'].nil?
                      ''
                    else
                      "-secureStorageFile /tmp/credential.store -masterPasswordFile /tmp/master_password_file.txt -preferences com.ibm.cic.common.core.preferences.ssl.nonsecureMode=true"
                    end
  security_params
end


def define_im_repo_password
  im_repo_password = ''
  encrypted_id = node['im']['vault']['encrypted_id']
  chef_vault = node['im']['vault']['name']
  unless chef_vault.empty?
    require 'chef-vault'
    im_repo_password = chef_vault_item(chef_vault, encrypted_id)['ibm']['im_repo_password']
    raise "No password found for IM repo user in chef vault \'#{chef_vault}\'" if im_repo_password.empty?
    Chef::Log.info "Found a password for IM repo user in chef vault \'#{chef_vault}\'"
  end
  im_repo_password
end

def generate_storage_file(user, group, im_install_dir)
  im_repo = define_im_repo
  require 'securerandom'
  user = user
  group = group
  im_repo_password = define_im_repo_password
  if ::File.exist?('/tmp/master_password_file.txt')
    Chef::Log.info("/tmp/master_password_file.txt exists. It will not be modified")
  else
    master_password_file = open('/tmp/master_password_file.txt', 'w')
    FileUtils.chown user, group, '/tmp/master_password_file.txt'
    master_password_file.write(SecureRandom.hex)
    master_password_file.close
  end
  if ::File.exist?('/tmp/credential.store')
    Chef::Log.info("/tmp/credential.store exists. It will not be modified")
  else
    cmd = "#{im_install_dir}/eclipse/tools/imutilsc saveCredential -url #{im_repo}/repository.config -userName #{node['ibm']['im_repo_user']} -userPassword \'#{im_repo_password}\' -secureStorageFile /tmp/credential.store -masterPasswordFile /tmp/master_password_file.txt -preferences com.ibm.cic.common.core.preferences.ssl.nonsecureMode=true || true"
    Chef::Log.info("Running #{cmd}")
    cmd_out = run_shell_cmd(cmd, user)
    cmd_out.stderr.empty? && (cmd_out.stdout =~ /^Successfully saved the credential to the secure storage file./)
  end
end

def download_self_signed_certificate
  require 'net/http'
  require 'socket'
  require 'openssl'
  if ::File.exist?('/tmp/secure-repo.pem')
    Chef::Log.info("/tmp/secure-repo.pem exists. It will not be downloaded again")
  else
    uri = URI.parse(node['ibm']['im_repo'])
    tcp_client = TCPSocket.new(uri.host, uri.port)
    ssl_client = OpenSSL::SSL::SSLSocket.new(tcp_client)
    ssl_client.connect
    cert = OpenSSL::X509::Certificate.new(ssl_client.peer_cert)
    cert_file = open('/tmp/secure-repo.pem', 'w+')
    if cert_file.include? cert.to_pem
      Chef::Log.info "Self signed cert found in #{cert_file}"
    else
      cert_file.write(cert)
    end
    cert_file.close
  end
end

def self_signed_certificate_name
  require 'net/http'
  require 'socket'
  require 'openssl'
  uri = URI.parse(node['ibm']['im_repo'])
  tcp_client = TCPSocket.new(uri.host, uri.port)
  ssl_client = OpenSSL::SSL::SSLSocket.new(tcp_client)
  ssl_client.connect
  cert = OpenSSL::X509::Certificate.new(ssl_client.peer_cert)
  cert_name = cert.subject.to_a.find { |name, _, _| name == 'CN' }[1]
  etc_hosts = open('/etc/hosts', 'a+')
  if etc_hosts.include? "#{uri.host} #{cert_name}"
    Chef::Log.info "line #{uri.host} #{cert_name} found in /etc/hosts"
  else
    etc_hosts.write("#{uri.host} #{cert_name}")
  end
  etc_hosts.close
  cert_name
end
end
Chef::Recipe.send(:include, Helpers)
