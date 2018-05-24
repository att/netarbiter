Ansible HOWTO
=============

## Install
For Ubuntu:
```
sudo apt-get install ansible
```
For Mac OS X:
```
brew install ansible
```

## Configure
Edit default inventory file `/etc/ansible/hosts`.  
For exampe:
```
[group1]
hostname1
hostname2
hostname3

[group2]
hostname1
hostname2
```

## Usage
Modules
```
ansible hostname -m ping
ansible hostname -m ping -i hosts
ansible groupname -m ping
ansible all -m ping -i hosts -K -u username
ansible groupname -m service -a "name=httpd state=started"
ansible groupname -m command -a "ping google.com -c 6"
ansible groupname -m command -a "/sbin/reboot -t now"
```

Discover system info
```
ansible hostname -m setup
```

Playbook
```
ansible-playbook playbook.yml
ansible-playbook -i hosts playbook.yml --limit=hostname
```

## Playbook
### Modules
- Create directory
```
- name: Create a directory
  file: path=/tmp/mydir state=directory
```

- Remove directory
```
- name: remove directory
  file: path=/tmp/mydir state=absent
```

- Copy a file 
```
- name: Copy a file
  copy: src=myfile dest=/tmp/mydir/myfile
```

- Rsync 
```
- name: Rsync
  synchronize: src=mydir dest=/tmp delete=yes
```

- Run as a background process
```
- name: Test pagecache
  shell: nohup bash myshell.sh &
  args:
    chdir: /tmp/mydir/
```

### Execute detached process
ref: <https://ansibledaily.com/execute-detached-process-with-ansible>  
ref: <http://docs.ansible.com/ansible/latest/playbooks_async.html>  

- Async task
```
- name: long running task
  shell: /usr/bin/myscript.sh
  async: 2592000               # 60*60*24*30 – 1 month
  poll: 0
```

- Background shell job
```
- name: start simple http server in background
  shell: cd /tmp/www; nohup python -mSimpleHTTPServer </dev/null >/dev/null 2>&1 &
```

