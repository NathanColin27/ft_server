FROM debian:buster

RUN apt-get update;

#Utility packagess

RUN apt-get install --no-install-recommends --no-install-suggests -y unzip nano

#NGINX Setup

RUN apt-get install --no-install-recommends --no-install-suggests -y nginx
COPY /srcs/default etc/nginx/sites-available

#MYSQL Setup

RUN apt-get install --no-install-recommends --no-install-suggests -y default-mysql-server
RUN mysql_install_db
RUN service mysql start; \ 
	echo "CREATE USER 'ncolin'@'localhost' IDENTIFIED BY 'ncolin123';" | mysql; \
	echo "GRANT ALL PRIVILEGES ON *.* TO 'ncolin'@'localhost' WITH GRANT OPTION;" | mysql; \
	echo "CREATE DATABASE wordpress" | mysql

#PHP Setup

RUN apt-get install --no-install-recommends --no-install-suggests -y php-fpm php-mysql 

#WordPress

COPY srcs/wordpress.zip /var/www/html 
COPY srcs/index.html /var/www/html 
RUN unzip /var/www/html/wordpress.zip -d /var/www/html
RUN rm /var/www/html/wordpress.zip
RUN chown -R www-data:www-data /var/www/html/wordpress
#phpMyAdmin

COPY srcs/phpMyAdmin.zip /var/www/html
RUN unzip -q /var/www/html/phpMyAdmin.zip -d /var/www/html
RUN mv /var/www/html/phpMyAdmin-4.9.2-all-languages /var/www/html/phpMyAdmin
RUN rm /var/www/html/phpMyAdmin.zip
COPY srcs/config.inc.php /var/www/html/phpMyAdmin


#SSL

RUN apt-get install openssl

RUN openssl req \
	-x509 \
	-nodes \
	-days 365 \
	-newkey rsa:2048 \
	-subj "/C=BE/ST=BXL/L=BXL/O=19/CN=localhost" \ 
	-keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt 

#Start-up instructions

ADD srcs/start.sh /
RUN chmod +x /start.sh

#CMD bash start.sh

