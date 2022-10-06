Role Name
=========

Database-servers configuration

Requirements
------------

DB instances accessible

Role Variables
--------------

db-name  
db-user  
db-pass  

Dependencies
------------

mysql_db  
mysql_user

Example Playbook
----------------

Example of how to use role (for instance, with variables passed in as parameters):

    - hosts: dbservers
      roles:
         - { role: dbservers-conf, x: 42 }

License
-------

BSD

Author Information
------------------

Yurii Pelykh (yurii_pelykh@epam.com)
