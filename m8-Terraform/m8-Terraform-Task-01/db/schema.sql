CREATE DATABASE php_mysql_crud;

USE php_mysql_crud;

CREATE TABLE task(
  id INT(11) PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE USER 'dbuser'@'%' IDENTIFIED BY 'p1ssw0rd';

GRANT ALL ON php_mysql_crud.* TO 'dbuser'@'%';



