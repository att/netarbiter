User Add Ubuntu HOWTO
=====================

1. Create a new user 
```
sudo useradd -d /home/testuser -m testuser -s /bin/bash
# or sudo useradd -d /home/testuser -g testuser -m testuser
```
* note  
  -g: group name must exist.  
  -m, --create-home: Create the user's home directory if it doesn't exist.  
  -s, --shell: The name of the user's login shell  

2. Set up password
```
sudo passwd testuser
```
3. Add testuser to sudo group in /etc/group
```
sudo adduser testuser sudo
```
4. Delete a user
```
sudo userdel -r username
```
* note: -r --> the user's home directory is removed  
