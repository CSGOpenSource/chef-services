#
# Cookbook Name:: test
# Recipe:: delivery
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

directory '/var/opt/delivery/license/' do
  recursive true
end

directory '/etc/delivery'
directory '/etc/chef'

delivery_databag = data_bag_item('automate', 'automate')

include_recipe 'chef-services::delivery_license'

file '/etc/delivery/delivery.pem' do
  content delivery_databag['user_pem']
end

file '/etc/chef/validation.pem' do
  content delivery_databag['validator_pem']
end

file_info = get_product_info("delivery", node['chef-services']['delivery']['version'])

remote_file "#{node['chef_server']['install_dir']}/#{file_info['name']}" do
  source file_info['url']
  not_if { ::File.exist?("#{node['chef_server']['install_dir']}/#{file_info['name']}") }
end

chef_ingredient 'delivery' do
  config <<-EOS
delivery_fqdn "#{node['chef_automate']['fqdn']}"
delivery['chef_username']    = "delivery"
delivery['chef_private_key'] = "/etc/delivery/delivery.pem"
delivery['chef_server']      = "https://#{node['chef_server']['fqdn']}/organizations/delivery"
delivery['default_search']   = "tags:delivery-build-node"
insights['enable']           = true
delivery['ldap_hosts'] = #{node['chef-server']['ldap_hosts']}
delivery['ldap_port'] = "#{node['chef-server']['ldap_port']}"
delivery['ldap_timeout'] = "#{node['chef-server']['ldap_timeout']}"
delivery['ldap_base_dn'] = "#{node['chef-server']['ldap_base_dn']}"
delivery['ldap_bind_dn'] = "#{node['chef-server']['ldap_bind_dn']}"
delivery['ldap_bind_dn_password'] = "#{node['chef-server']['ldap_bind_dn_password']}"
delivery['ldap_encryption'] = "#{node['chef-server']['ldap_encryption']}"
delivery['ldap_attr_login'] = "#{node['chef-server']['ldap_attr_login']}"
delivery['ldap_attr_mail'] = "#{node['chef-server']['ldap_attr_mail']}"
delivery['ldap_attr_full_name'] = "#{node['chef-server']['ldap_attr_full_name']}"



  EOS
  package_source "#{node['chef_server']['install_dir']}/#{file_info['name']}"
  action :install
end

ingredient_config 'delivery' do
  notifies :reconfigure, 'chef_ingredient[delivery]', :immediately
end

include_recipe 'chef-services::create_enterprise'
