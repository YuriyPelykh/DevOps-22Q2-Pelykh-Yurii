FROM php:8.0-apache

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN apt-get update && apt-get install wget unzip -y

ARG APACHE_PORT
ARG DB_SERVER
ARG DB_USER
ARG MYSQL_ROOT_PASSWORD
ARG DB_NAME

RUN echo "Listen ${APACHE_PORT}" > /etc/apache2/ports.conf

RUN echo "<VirtualHost *:${APACHE_PORT}>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html\n\
    ErrorLog \${APACHE_LOG_DIR}/error.log\n\
    CustomLog \${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>\n" > /etc/apache2/sites-enabled/000-default.conf

RUN wget -P /var/www/html/ https://github.com/FaztWeb/php-mysql-crud/archive/master.zip
RUN unzip /var/www/html/master.zip -d /var/www/html/tmp && \
     mv /var/www/html/tmp/*/* /var/www/html/ && \
     rm -Rf /var/www/html/master.zip /var/www/html/tmp

RUN echo "<?php \
session_start(); \
\
\$conn = mysqli_connect( \
    '${DB_SERVER}', \
    '${DB_USER}', \
    '${MYSQL_ROOT_PASSWORD}', \
    '${DB_NAME}' \
) or die(mysqli_error(\$mysqli)); \
\
?>" > /var/www/html/db.php

RUN /etc/init.d/apache2 restart
