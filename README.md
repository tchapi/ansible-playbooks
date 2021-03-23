# Ansible playbooks

A simple collection of roles and standard playbooks for deploying a common deployment / front application stack. These are mostly for PHP / Node + Caddy infrastructures, with MariaDB and Mongo database engines.

> NB : the default inventory file location is `/etc/ansible/hosts` on Linux, and `/usr/local/etc/ansible/hosts` on macOS
> You should include the ansible user to use when loging in, as so:

```
[frontend_server]
my.frontend.server.com ansible_user=ubuntu
my.other.frontend.server.com ansible_user=ubuntu
```

> NB : We use the following groups `[frontend_node]`, `[frontend_php]` in the playbooks.

## Roles available

  - #### base

    - Ensures that the server has at least some basics tools like `sudo` and `python-apt` for Ansible to run correctly. 
    - Updates and upgrades `apt`
  
  - #### backup

    - Ensures a /var/backups/rolling folder is present
    - Creates a DB + files backup script
    - Creates a cron task for daily backups and uploads the backup somewhere safe (on a S3 compatible endpoint)

  > NB: You need to copy the `roles/backup/files/credentials.dist` file to `roles/backup/files/credentials` and put your provider credentials there. You might want to change the `region` too in `roles/backup/files/config` if needed.

  - #### caddy

    Ensures that `caddy`, is installed correctly and runs as a service. 

  - #### mongo

    Ensures that `mongo-org` is the lastest and that the service is runnning correctly. 

  - #### node

    Ensures that `node`, `npm` are installed correctly. 

  - #### maria_db

    Ensures that `maria_db` is the lastest and that the service is runnning correctly. Adds a consistent `/root/.my.cnf` file for logging in.

  - #### mlmmj 

    Installs postfix along with mlmmj using the configured MX domain. For more info on Mlmmj see [this blog post](http://www.foobarflies.io/a-simple-web-interface-for-mlmmj/)

  - #### nginx

    Ensures that `nginx` is the lastest and that the service is runnning correctly. Also uploads a secured configuration for `nginx`.

  - #### php

    Installs `php7.4` FPM and command line interface with a few standard modules, a sensible configuration file for cli and FPM, and the `composer` package manager.

  - #### yarn

    Ensures that `yarn` is installed correctly. 

## Playbooks

The playbooks are rather straightforward.

> Before deploying a new server, you must make sure that your user has sudo rights, and that your SSH key is authorized for a password-less login

This done, when deploying a new nodeJS server for instance (on macOS):

    ansible-playbook --inventory=/usr/local/etc/ansible/hosts playbooks/frontend_node.yml

#### mlmmj

This role is kind of "standalone". To use it, just play the mlmmj playbook alone, to install node and mlmmj in one go:

    ansible-playbook --inventory=/usr/local/etc/ansible/hosts  playbooks/mlmmj.yml

#### Reminder

If you want to execute a single shell command :

    # Gets the speed of each cpu 
    ansible all -m shell -a "cat /proc/cpuinfo | grep MHz"

## Licence

These roles and playbooks are released under the MIT licence. Enjoy !!
