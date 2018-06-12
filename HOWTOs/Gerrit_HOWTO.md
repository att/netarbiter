Gerrit HOWTO
============
refs:  

   - <https://docs.openstack.org/infra/manual/developers.html>
   - <https://gerrit-review.googlesource.com/Documentation/intro-gerrit-walkthrough.html>

## Install & Start Gerrit Code Review (only if you want to work with your own Gerrit service)
ref: <https://gerrit-review.googlesource.com/Documentation/linux-quickstart.html>  

1. Find a Gerrit Code Review Release at <https://gerrit-releases.storage.googleapis.com/index.html>
```
wget https://www.gerritcodereview.com/download/gerrit-2.14.2.war
java -jar gerrit*.war init --batch --dev -d ~/gerrit_testsite
```

2. (optional) Restart the Gerrit service
```
~/gerrit_testsite/bin/gerrit.sh restart
```

3. Viewing Gerrit  
opening a browser and entering the following URL:
```
http://voyager1:8080
```

## Working with your Gerrit server
ref: <https://www.mediawiki.org/wiki/Gerrit/Tutorial>  

1. Install git-review:
```
sudo apt install git-review
```

2. From the web site <http://voyager1:8080>, create a user and add your SSH key.

3. Check if a Gerrit service works:
```
$ ssh -p 29418 knowpd@voyager1.research.att.com

  ****    Welcome to Gerrit Code Review    ****

  Hi knowpd, you have successfully connected over SSH.

  Unfortunately, interactive shells are disabled.
  To clone a hosted Git repository, use:

  git clone ssh://knowpd@voyager1:29418/REPOSITORY_NAME.git

Connection to voyager1.research.att.com closed.
```

4. Get your project:
```
git clone git@github.com:knowpd/git-test.git
```

5. Install the commit message hook in order to add a Change-Id to his commits:
```
cd git-test
scp -p -P 29418 knowpd@voyager1:hooks/commit-msg ./.git/hooks/
```

6. From the web site <http://voyager1:8080>, go to Project/Create New Project 
and create a project named `git-test` .

7. Push your project to your Gerrit server.
```
git remote add gerrit ssh://knowpd@voyager1:29418/git-test.git
git push -u gerrit master
```

8. Set up git-review:
```
git review -s
```

9. Push your change set to Gerrit:
```
git checkout -b mytopic gerrit/master
## Edit test1.txt
git add test1.txt
git commit -m "A line added"		# Will create a new patch set
git review
```

10. Change again and push your change set to Gerrit:
```
## Edit text1.txt
git add test1.txt 
git commit --amend			# Will add a new commit to the current patch set
git review
```

## Working with <https://review.openstack.org>  
Assume that you want to use a patch set <https://review.openstack.org/#/c/566381>.

0. Summary
```
mkdir 566381
cd 566381
git clone https://github.com/openstack/openstack-helm
cd openstack-helm/ 
scp -p -P 29418 knowpd@review.openstack.org:hooks/commit-msg ./.git/hooks/
git remote add gerrit https://knowpd@review.openstack.org/openstack/openstack-helm.git
git remote -v
git review -s
git review -d 566381
```

1. Sign up your account (e.g., knowpd@gmail.com) at <https://review.openstack.org> 

2. Create a directory at your local host (Linux or Mac OS)
```
# For example, use a patch set name for a new directory
mkdir ~/566381
```

3. Get a repository
```
cd ~/566381
git clone https://github.com/openstack/openstack-helm
```

4. Install the commit message hook in order to add a Change-Id to his commits:
```
cd ~/566381/openstack-helm/
scp -p -P 29418 knowpd@review.openstack.org:hooks/commit-msg ./.git/hooks/
# if needed, `chmod u+x .git/hooks/commit-msg`
```

5. Set up git-review:
```
git remote add gerrit https://knowpd@review.openstack.org/openstack/openstack-helm.git
git review -s		# or git review --setup
```

6. Fetch and checkout the parent change:
```
$ git review -d 566381
```

7. (Case A) Add a new comit to the current patch set:
```
## Edit files
git add <file>
git commit --amend
git review
```

(Case B) If the gerrit upstream server is ahead of you:
```
git rebase -i gerrit/master
git add <file>
git commit --amend
git review
```

(Case C) To create a new patch set, run `git commit` instead of `git commit --amend`:
```
## Edit files
git add <file>
git commit -m "first commit"
git review
```

Note:
   - Bug reports for a project are generally tracked on Launchpad at <https://bugs.launchpad.net/openstack-helm>

## Troubleshooting
### Symptom
```
youraccount@yourhost:~/mycode/566381/openstack-helm/doc/source/testing/ceph-resiliency$ git review
Errors running git reset --hard a7dcc0ff44b6193ace1b6f61080736808bd4e90b
fatal: Unable to read current working directory: No such file or directory
```
### Solution
Run `git review` in a parent directory as follows: 
```
youraccount@yourhost:~/mycode/566381/openstack-helm/doc/source$ git review
```
