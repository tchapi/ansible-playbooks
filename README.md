# Ansible playbooks

A collection of roles and standard playbooks for deploying a common deployment / front application stack. These are mostly for PHP / Node + Caddy infrastructures.

_I use a common username for all management processes on my servers, you can configure it globally in each playbook or play — it's the `{{ user }}` var. I would recommend to use a global variable by defining `user` in `<INVENTORY_FILE_LOCATION>/group_vars/all` like that :_


> NB : the default inventory file location is `/etc/ansible/hosts`, and `/usr/local/etc/ansible/hosts` on Mac OS X

```yaml
---
# Your user
user: "myUser"
```

And if you plan to deploy for MX servers, you can add :

```yaml
---
# The MX domain
mx_domain: "mydomain.com"
```


> NB : Your inventory file should have the following groups `[frontend_node]`, `[frontend_php]` at least.


## Roles available

  - #### base

    - Ensures that the server has at least some basics tools like `sudo` and `python-apt` for Ansible to run correctly. 
    - Updates and upgrades `apt`, adds a backports repository for Debian.
    - Grants the `user` a no-password `sudo` and install base packages like `curl`, and the like.

  - #### backup

    - Ensures a /home/{{user}}/backup folder is present for backups
    - Creates a DB + files backup script
    - Creates a cron task for daily backups and ensures that there is a backup user with correct permissions on the DB if needed

  - #### mongo

    Ensures that `mongo-10gen` is the lastest and that the service is runnning correctly. 

  - #### node

    Ensures that `node`, `npm` and some other tools are installed correctly. 

  - #### maria_db

    Ensures that `maria_db` is the lastest and that the service is runnning correctly. Adds a consistent `/root/.my.cnf` file for logging in.

    Remember to set a root password afterwards with `sudo mysql` or `mysql_secure_installation`

  - #### nginx

    Ensures that `nginx` is the lastest and that the service is runnning correctly. Also uploads a secured configuration for `nginx`.

  - #### php

    Installs `php7.4` FPM and command line interface with a few standard modules.

  - #### mlmmj 

    Installs postfix along with mlmmj using the configured MX domain. For more info on Mlmmj see [this blog post](http://www.foobarflies.io/a-simple-web-interface-for-mlmmj/)

## Playbooks

The playbooks are rather straightforward.

> Before deploying a new server, you must make sure that your user has sudo rights, and that your SSH key is authorized for a password-less login

This done, when deploying a new node server for instance:

    ansible-playbook -v -l myNewServer playbooks/frontend_node.yml

#### mlmmj

Just plays the mlmmj playbook alone :

    ansible-playbook playbooks/mlmmj.yml

#### Reminder

If you want to execute a single shell command :

    # Gets the speed of each cpu 
    ansible all -m shell -a "cat /proc/cpuinfo | grep MHz"

## Licence

These roles and playbooks are released under the MIT licence. Enjoy !!
