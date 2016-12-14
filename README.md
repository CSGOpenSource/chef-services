# chef-services
```
kitchen list
kitchen converge
```

# Bootstrap Test
To test bootstrapping of Chef Server, Chef Manage, and Chef Automate without Test Kitchen:

```shell
cd bootstrap_test
vagrant up --provision # --provision flag is necessary due to hacky fix of private NIC being DOWN
``

## SSH into bootstrap_test instances
Once provisioned, you can ssh into the instances using `vagrant ssh <name>`.

On Windows, you will probably want to use a better client like Putty or Poderosa. You can use the hostnames and ports below:
```
Chef Server: chef.vagrant.local:22
Chef Automate Server: automate.vagrant.local:22
```

### Sets up:

1. chef-server
4. automate
5. build-node
3. supermarket
6. compliance

### Add this to your local workstation /etc/hosts

```
33.33.33.10 chef.services.com
33.33.33.11 automate.services.com
33.33.33.12 build.services.com
33.33.33.13 supermarket.services.com
33.33.33.14 compliance.services.com
```

#### Login to chef-server  
##### user/password: delivery/delivery
[http://chef.services.com](http://chef.services.com)

### Automate credentials for admin login

`kitchen exec delivery -c 'cat /tmp/test.creds'`

[http://automate.services.com/e/test](http://automate.services.com/e/test)

#### Supermarket
[http://supermarket.services.com](http://supermarket.services.com)

### Login to compliance
##### user/password: admin/password

[http://compliance.services.com](http://compliance.services.com)

### Chef simple install

`kitchen create chef-server-centos-72`

`scp -p files/default/installer.sh vagrant@33.33.33.10:/tmp/installer.sh`

`ssh vagrant@33.33.33.10 "sudo /tmp/installer.sh -c 33.33.33.10"`

or

`curl -O https://raw.githubusercontent.com/CSGOpenSource/chef-services/master/files/default/installer.sh && sudo bash ./installer.sh -c $CHEF_SERVER_FQDN-a $AUTOMATE_FQDN -b $BUILD_FQDN -u vagrant -p vagrant`








### Bootstrap Instructions

`knife bootstrap $NODE_FQDN --node-name $NODE_FQDN --ssh-user $CHEF_USER --sudo --run-list "role[csg_base]" --yes --node-ssl-verify-mode none`