FROM mysql

RUN touch /docker-entrypoint-initdb.d/dump.sql
RUN chmod +x /docker-entrypoint-initdb.d/dump.sql

RUN echo -e "CREATE DATABASE php_mysql_crud;\n\
\
use php_mysql_crud;\n\
\
CREATE TABLE task( \
  id INT(11) PRIMARY KEY AUTO_INCREMENT, \
  title VARCHAR(255) NOT NULL, \
  description TEXT, \
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \
);\n\
\
DESCRIBE task;\n\
" > /docker-entrypoint-initdb.d/dump.sql
