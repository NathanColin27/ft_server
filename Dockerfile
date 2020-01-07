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

#PHP Setup

RUN apt-get install --no-install-recommends --no-install-suggests -y php-fpm php-mysql php-mbstring php-zip php-gd php-pear php-gettext php-cgi
COPY srcs/info.php /var/www/html 

#WordPress

COPY srcs/wordpress.zip /var/www/html 
COPY srcs/test.html /var/www/html 
RUN unzip /var/www/html/wordpress.zip -d /var/www/html

#phpMyAdmin

COPY srcs/phpMyAdmin.zip /var/www/html
RUN unzip /var/www/html/phpMyAdmin.zip -d /var/www/html
COPY srcs/config.inc.php /var/www/html/phpmyadmin




#SSL

#Starting instructions

ADD srcs/start.sh /
RUN chmod +x /start.sh

CMD bash start.sh