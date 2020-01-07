FROM debian:buster

RUN apt-get update;

#Utility packagess

RUN apt-get install --no-install-recommends --no-install-suggests -y nano unzip

#NGINX Setup

RUN apt-get install --no-install-recommends --no-install-suggests -y nginx
COPY /srcs/default etc/nginx/sites-enabled/ 
COPY /srcs/nginx.conf etc/nginx

#MYSQL Setup

RUN apt-get install --no-install-recommends --no-install-suggests -y default-mysql-server
RUN mysql_install_db
RUN service mysql start; \
	echo "CREATE DATABASE wordpress;" | mysql -u root; \
	echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';" | mysql -u root; \
	echo "FLUSH PRIVILEGES;" | mysql -u root; \
	echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root

#PHP Setup

RUN apt-get install --no-install-recommends --no-install-suggests -y php-fpm php-mysql php-mbstring php-zip php-gd php-pear php-gettext php-cgi
COPY srcs/info.php /var/www/html 

#WordPress

COPY srcs/wordpress.zip /var/www/html 
COPY srcs/test.html /var/www/html 
RUN unzip /var/www/html/wordpress.zip -d /var/www/html
RUN rm /var/www/html/wordpress.zip

#phpMyAdmin

COPY srcs/phpMyAdmin.zip /var/www/html
RUN unzip -q /var/www/html/phpMyAdmin.zip -d /var/www/html
COPY srcs/phpmyadmin.conf /etc/nginx/conf.d/
RUN mv /var/www/html/phpMyAdmin-4.9.2-all-languages /var/www/html/phpMyAdmin
RUN rm /var/www/html/phpMyAdmin.zip
COPY srcs/config.inc.php /var/www/html/phpMyAdmin

#SSL

#Starting instructions

ADD srcs/start.sh /
RUN chmod +x /start.sh

#CMD bash start.sh