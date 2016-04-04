#
# Cookbook Name:: mysqldeploy
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "utilities"

mysql_service 'jboss' do
	action [:create, :start]
	not_if { File.exist?('/opt/sql_installed') }
end

bash 'prepare_mysql_user' do
	code <<-EOF
	mysqladmin -S /var/run/mysql-jboss/mysqld.sock --password=ilikerandompasswords create guestbook
    mysql -S /var/run/mysql-jboss/mysqld.sock --password=ilikerandompasswords -e \"CREATE USER 'jboss'@'#{node['jboss hostname']}' IDENTIFIED BY 'jboss'\"
	mysql -S /var/run/mysql-jboss/mysqld.sock --password=ilikerandompasswords -e \"GRANT ALL ON guestbook.* TO 'jboss'@'#{node['jboss hostname']}' IDENTIFIED BY 'jboss'\" && touch /opt/user_added
    EOF
	not_if { File.exist?('/opt/user_added') }
end
	

execute 'download_sql_dump' do
	cwd '/tmp/'
	command "wget -qnc #{node['application repo']}  && unzip -qn guestbookapp.zip" 
	not_if { File.exist?('/opt/sql_installed') }
end

execute 'install_sql_dump' do
	command "mysql -S /var/run/mysql-jboss/mysqld.sock --password=ilikerandompasswords -D guestbook < /tmp/guestbookapp/guestbookmysqldump.sql && touch /opt/sql_installed "
	not_if { File.exist?('/opt/sql_installed') }
end