# Task2

##Vagrant
Tested on Vagrant 1.8.1 on Ubuntu 14.04.4 LTS:

Deploy Vagrantfile in folder of choice, run
```
vagrant up
```
##Chef
Tested on chef 12.4.1 on Ubuntu 14.04.4 LTS where vagrantchef is chef server hostname:

Run on workstation
```
knife environment from file App_env.json
knife role from file jboss_role.json
knife role from file mysql_role.json
knife cookbook upload mysqldeploy --include-dependencies
knife cookbook upload jboss --include-dependencies
knife bootstrap ubuntu -p 2222 -x vagrant -P vagrant --sudo -E "Appenv" -r 'role[Mysql-server]' -N 'mysqlnode'
knife bootstrap ubuntu -p 2223 -x vagrant -P vagrant --sudo -E "Appenv" -r 'role[Jboss-server]' -N 'jbossnode'
```

If everything is correct after run you should be able to access Guestbook at http://vagrantchef:8080/guestbookapp