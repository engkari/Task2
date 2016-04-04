#
# Cookbook Name:: jboss
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "utilities"

bash 'install java' do
	code <<-EOF
	add-apt-repository ppa:webupd8team/java -y  > /dev/null 2>&1
	apt-get -q update 
	echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
	echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
	apt-get -q install oracle-java6-installer -y > /dev/null 2>&1
	EOF
	not_if { File.exist?('/usr/bin/java')}
end


bash 'install_jboss' do
	cwd '/tmp/'
	code <<-EOF
	echo downloading jboss-as-distribution-6.0.0.Final.zip
	wget -q -nc http://tenet.dl.sourceforge.net/project/jboss/JBoss/JBoss-6.0.0.Final/jboss-as-distribution-6.0.0.Final.zip
	unzip -q jboss-as-distribution-6.0.0.Final.zip -d /usr/local/
	useradd -m -d /usr/local/jboss -s /bin/sh jboss 
	chown -R jboss:jboss /usr/local/jboss-6.0.0.Final/ 
	rm -rf /usr/local/jboss
	ln -s /usr/local/jboss-6.0.0.Final /usr/local/jboss
	EOF
	not_if { File.exist?('/usr/local/jboss/jar-versions.xml') }
end

bash 'deploy_guestbook_app' do
	cwd '/tmp/'
	code <<-EOF
	echo downloading guestbookapp.zip
	wget -qnc #{node['application repo']} && unzip -qn guestbookapp.zip
	sed -i "s/3306/#{node['port']}/" "/tmp/guestbookapp/guestbookapp.xml"
	sed -i "s/username\>demo/username\>jboss/" "/tmp/guestbookapp/guestbookapp.xml"
	sed -i "s/password\>demodemo/password\>jboss/" "/tmp/guestbookapp/guestbookapp.xml"
	sed -i "32,34d" "/tmp/guestbookapp/guestbookapp.xml"
	mv /tmp/guestbookapp/guestbookapp* /usr/local/jboss/server/default/deploy/
	chown jboss:jboss /usr/local/jboss/server/default/deploy/guestbookapp*
	EOF
	not_if { File.exist?('/usr/local/jboss/server/default/deploy/guestbookapp.xml')}
end

template '/usr/local/jboss/server/default/deploy/mysql-ds.xml' do
	source 'mysql-ds.conf.erb'
	owner 'jboss'
	group 'jboss'
	mode '0755'
	action :create
	not_if { File.exist?('/usr/local/jboss/server/default/deploy/mysql-ds.xml')}
end

bash 'setup_jboss_service' do
	code <<-EOF
	cp /usr/local/jboss/bin/jboss_init_redhat.sh /usr/local/jboss/bin/jboss_init_ubuntu.sh
	sed -i '29i JBOSS_HOST=${JBOSS_HOST:-"0.0.0.0"}' /usr/local/jboss/bin/jboss_init_ubuntu.sh
	ln -s /usr/local/jboss/bin/jboss_init_ubuntu.sh /etc/init.d/jboss
	update-rc.d jboss defaults	
	/etc/init.d/jboss start
	EOF
	not_if { File.exist?('/etc/init.d/jboss')}
end



	