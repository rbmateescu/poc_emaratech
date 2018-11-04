# vi:ft=ruby:

# This is a Berksfile that supports multiple nested cookbooks, allowing
# Berkshelf to load the dependencies of all the nested cookbooks
# See: https://coderwall.com/p/j72egw/organise-your-site-cookbooks-with-berkshelf-and-this-trick

source "https://supermarket.chef.io"

def dependencies(path)
  berks = "#{path}/Berksfile.in"
  instance_eval(File.read(berks)) if File.exist?(berks)
end

Dir.glob('./chef/cookbooks/*').each do |path|
  dependencies path
  cookbook File.basename(path), :path => path
end
cookbook "linux", git: "git@github.ibm.com:OpenContent/cookbook_ibm_utils_linux.git", rel: "chef/cookbooks/linux", branch: "development"
