#
# Cookbook:: databag
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# #
# # Cookbook:: encrypted-databag
# # Recipe:: default
# #
# # Copyright:: 2017, The Authors, All Rights Reserved.
# # Create encrypted databag and use it
#
# db = data_bag('dev')
# creds = data_bag_item('dev','user1')
#
# Chef::Log.info("Showing DataBagItem Full Name: #{creds['Full Name']}")
# Chef::Log.info("Showing DataBagItem Shell: #{creds['shell']}")
# Chef::Log.info("Showing DataBagItem Password: #{creds['password']}")
#
# # Write this to a template
# template "/tmp/user.conf" do
#      variables(:FullName => creds['Full Name'],
#                :Shell => creds['shell'],
#                :Password => creds['password'])
#      owner "root"
#      mode  "0644"
#      source "user.conf.erb"
# end
#
#
#
# secret = Chef::EncryptedDataBagItem.load_secret("/tmp/secrets/secret_key")
# samba_creds = Chef::EncryptedDataBagItem.load("users", "credentials", secret)
# db_creds = Chef::EncryptedDataBagItem.load("users", "db_credentials", secret)
# default['dcc-samba']['username']=samba_creds['user']
# default['dcc-samba']['password']=samba_creds['password']

# Create Encrypted Databag from Databag using secret
# ruby encrypt_databag.rb databag.json users.json secret.txt

log Chef::Config[:data_bag_path]


template '/tmp/chef_configuration' do
  # content "#{Chef::Config[:data_bag_path]}"
  variables({
    :data_bag_path => "#{Chef::Config[:data_bag_path]}",
    :log_level => "#{Chef::Config[:log_level]}",
    :log_location => "#{Chef::Config[:log_location]}"
  })
  mode '0755'
  owner 'root'
  group 'root'
  source 'chef_config.erb'
end

directory "#{Chef::Config[:data_bag_path]}/users" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# cookbook_file "/var/chef/data_bags/users.json" do
cookbook_file "#{Chef::Config[:data_bag_path]}/users/user1.json" do
  owner 'root'
  group 'root'
  mode '0644'
  source 'databag.json'
  action :create
end

secret = Chef::EncryptedDataBagItem.load_secret("/etc/chef/encrypted_data_bag_secret")
creds = Chef::EncryptedDataBagItem.load("users", "user1", secret)
log creds['name']
log password=creds['password']
