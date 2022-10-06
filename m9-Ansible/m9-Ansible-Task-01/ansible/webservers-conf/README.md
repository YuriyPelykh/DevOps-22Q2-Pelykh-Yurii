Role Name
=========

Web-servers configuration

Requirements
------------

Web-servers instances accessible

Role Variables
--------------

db_address
db_user
db_password
db_name

Dependencies
------------

--

Example Playbook
----------------

Example of how to use role (for instance, with variables passed in as parameters):

    - hosts: webservers
      roles:
         - { role: webservers-conf, x: 42 }

License
-------

BSD

Author Information
------------------

Yurii Pelykh (yurii_pelykh@epam.com)
