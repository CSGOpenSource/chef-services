default['delivery']['version'] = 'latest'
default['delivery']['chef_server'] = 'https://chef.services.com/organizations/delivery'
default['chef_server']['fqdn'] = nil
default['compliance']['version'] = 'latest'
default['compliance']['package_source'] = nil
default['compliance']['channel'] = :stable
default['compliance']['accept_license'] = false
default['chef_automate']['fqdn'] = 'automate.services.com'
default['chefdk']['bashrc'] = '/etc/bashrc'
default['chef-services']['chefdk']['version'] = 'latest'
default['chef-services']['chef-server']['version'] = 'latest'
default['chef-services']['manage']['version'] = 'latest'
default['chef-services']['push-jobs-server']['version'] = 'latest'
default['chef-services']['delivery']['version'] = 'latest'
default['chef-services']['supermarket']['version'] = 'latest'
default['chef-services']['compliance']['version'] = 'latest'
default['chef-services']['compliance']['accept_license'] = true
default['chef-supermarket']['supermarket']['verify_ssl'] = false
default['chef-services']['supermarket']['config'] = {}
default['chef-server']['system_adjective'] = nil
default['chef-server']['base_dn'] = nil
default['chef-server']['bind_dn'] = nil
default['chef-server']['bind_password'] = nil
default['chef-server']['group_dn'] = nil
default['chef-server']['host'] = nil
default['chef-server']['port'] = nil
default['chef-server']['login_attribute'] = nil
default['chef-server']['ldap_hosts'] = nil
default['chef-server']['ldap_port'] = nil
default['chef-server']['ldap_timeout'] = 5000
default['chef-server']['ldap_base_dn'] = nil
default['chef-server']['ldap_bind_dn'] = nil
default['chef-server']['ldap_bind_dn_password'] = nil
default['chef-server']['ldap_encryption'] = nil
default['chef-server']['ldap_attr_login'] = nil
default['chef-server']['ldap_attr_mail'] = nil
default['chef-server']['ldap_attr_full_name'] = nil