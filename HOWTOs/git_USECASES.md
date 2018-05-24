git USECASES
============
Ref: <https://www.atlassian.com/git/tutorials/setting-up-a-repository>

ADD/RM
------
### git add
```
$ git branch new-feature
$ git checkout new-feature
# Or you can integrate the above two lines into one: `git checkout -b new-feature`
# Edit some files
$ git add <file>
$ git commit -m "Started work on a new feature"
```

### git rm 
ref: <http://stackoverflow.com/questions/2047465/how-can-i-delete-a-file-from-git-repo>
```
git rm file1.txt
git commit -m "remove file1.txt"
```

BRANCH
------
### Create a branch
```
$ git branch
* master

$ git branch -a                          [list both remote-tracking and local branches]
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master

$ git branch -r                          [act on remote-tracking branches]
  origin/HEAD -> origin/master
  origin/master

$ git checkout -b new-feature master
$ git checkout -b new-feature2 new-feature
$ git checkout -b hotfix master

$ git checkout new-feature
$ git branch
  hotfix
  master
* new-feature
  new-feature2

$ git show-branch
! [hotfix] First commit
 ! [master] First commit
  * [new-feature] First commit
   ! [new-feature2] First commit
----
++*+ [hotfix] First commit
```
From `man git-show-branch`, note: the branch head that is pointed at by `$GIT_DIR/HEAD` is prefixed with an asterisk * character while other heads are prefixed with a ! character.
```
$ git log --oneline
36440c1 First commit
40d46ce First commit
867e6a1 put abstract & outline
40adc03 put abstract & outline
d95dd7a initial repo
```

### Push a branch to upstream
```
$ git checkout new-feature
$ git push
fatal: The current branch new-feature has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin new-feature

$ git push --set-upstream origin new-feature
```

### How to clone a specific Git branch
Usage:
```
git clone -b <branch> <remote_repo>
``` 
Example:
```
git clone -b pets git@github.com:knowpd/git-test.git
``` 

### How to get a branch
```
git branch -r 			# Find branch names
git checkout <branch-name>
```

### How to fetch all git branches?
ref: <https://stackoverflow.com/questions/10312521/how-to-fetch-all-git-branches?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa>
```
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
git fetch --all
git pull --all
```

### Check out a remote branch
ref: <https://www.atlassian.com/git/tutorials/syncing/git-fetch>  

You can check out a remote branch just like a local one, but this puts you in a detached HEAD state
(just like checking out an old commit). You can think of them as read-only branches. 
```
$ git branch -a
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
  remotes/origin/new-feature
$ git checkout origin/new-feature
Note: checking out 'origin/new-feature'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

HEAD is now at 535e83c... Kimchi

$ git branch
* (HEAD detached at origin/new-feature)
  master

## Edit a file
$ git commit -a -m "a line added"
$ git checkout master
Warning: you are leaving 1 commit behind, not connected to
any of your branches:

  15e6aba title not issued yet

If you want to keep it by creating a new branch, this may be a good time
to do so with:

 git branch <new-branch-name> 15e6aba

Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
```


PULL/PUSH
---------
ref: <https://forge.research.att.com/plugins/mediawiki/wiki/sds/index.php/Git_Instructions>

Git clone
```
git clone git+ssh://chen@forge.research.att.com//var/lib/gforge/chroot/scmrepos/git/sds/sds.git
```
Once you make a change (say "manage.tex") with your own contributions, do the following:
```
git add manage.tex                      [ move the status of a modified file to "staged",  waiting to be committed ]
git commit -m "modified manage.tex"     [ commit all changes and give the reason in a string after "-m"]
```
Alternatively, simply type this to add all files changed since last commit:
```
git commit -a -m "made some changes .."
```
When you are ready to update the master branch, run
```
git push        [ this is equivalent to "git push origin master" ]
```
If you want to make sure you incorporate changes from other people while you were working on your own section, then do the following (instead of the last command):
```
git pull       [ retrieve recent changes in the master branch ]
git push       [ update the master branch ]
```
When in doubt, always run "git status" to find out what the status of your local working copy is.


### Synchronization when there are local (untracked) files
ref: <http://stackoverflow.com/questions/61212/how-do-i-remove-local-untracked-files-from-my-current-git-branch>

```
git log                         # Check log
git status
git pull
git clean -fd           [Remove local (untracked) files from my current Git branch]
```

### Force Git to overwrite local files on pull
ref: <http://stackoverflow.com/questions/1125968/force-git-to-overwrite-local-files-on-pull>
```
git fetch --all
git reset --hard origin/master
```

### Push Eclipse Project
To revert
```
git revert HEAD
```

To pull an empty repository and push working directory
```
git remote add origin git+ssh://knowpd@forge.research.att.com//var/lib/gforge/chroot/scmrepos/git/sdsplanner/sdsplanner.git
git pull origin master
git push
```


MISCELLANEOUS
-------------
### Remove a file from a Git repository without deleting it from the local filesystem  
ref: <http://stackoverflow.com/questions/1143796/remove-a-file-from-a-git-repository-without-deleting-it-from-the-local-filesyste>  
```
git rm --cached mylogfile.log
# For a directory:
git rm --cached -r mydirectory
```
For example: 
```
git rm --cached *.DS_Store
```

### Push to github without password using ssh-key  
ref: <http://stackoverflow.com/questions/14762034/push-to-github-without-password-using-ssh-key>  
ref: <https://stackoverflow.com/questions/6565357/git-push-requires-username-and-password>  
```
git remote set-url origin git@github.com:<Username>/<Project>.git
```

For example, for netarbiter:
```
git remote set-url origin git@github.com:att/netarbiter.git
git config --global user.email "knowpd@gmail.com"
git config --global user.name "Hee Won Lee"
```

You can find the current config status:
```
git config -l
```

### How do I force `git pull` to overwrite local files?  
ref: <https://stackoverflow.com/questions/1125968/how-do-i-force-git-pull-to-overwrite-local-files>
```
git fetch --all
git reset --hard origin/master
```
Or, if you are on some other branch:
```
git reset --hard origin/<branch_name>
```


HEAD
----
ref: <https://www.youtube.com/watch?v=ZaI1co-rt9I>  

### HEAD is a reference to the most recent commit in current branch (in most of the cases)
```
$ git show head
commit 327380e614ea21337454a396d11b6a0204e255ae
...

$ git show 327380e614ea21337454a396d11b6a0204e255ae
commit 327380e614ea21337454a396d11b6a0204e255ae
...
```

### git diff
```
$ git log
commit cd15871378bea2e00687c50707fb557488aa58ed
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Tue May 15 12:17:38 2018 -0400

    Mold Inspection

commit cca6d77d3720dd8fc2e345874574a54bc4b8e343
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Tue May 15 12:16:14 2018 -0400

    New Inspection

$ git diff cca6d77d3720dd8fc2e345874574a54bc4b8e343 cd15871378bea2e00687c50707fb557488aa58ed
# OR
$ git diff HEAD~1 HEAD
```

### About .git/HEAD
```
$ cat .git/HEAD
ref: refs/heads/master

$ git checkout new-feature
Switched to branch 'new-feature'

$ cat .git/HEAD
ref: refs/heads/new-feature
kfclan@kpd100:~/mycode/git-test$ git log --oneline
cd15871 Mold Inspection
cca6d77 New Inspection
5176c82 Inspection
cd740e2 Mortgage added
85dcece First Commit

$ git checkout cca6d77
Note: checking out 'cca6d77'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

HEAD is now at cca6d77... New Inspection

$ cat .git/HEAD
cca6d77d3720dd8fc2e345874574a54bc4b8e343

$ git log --oneline
cca6d77 New Inspection
5176c82 Inspection
cd740e2 Mortgage added
85dcece First Commit
```

Undoing/Reverting/Resetting code changes
----------------------------------------
ref: <https://www.youtube.com/watch?v=3dk3s4LK-Wg>  

### Undoing code changes
```
$ vi test1.txt		# change a file

$ git status
On branch new-feature
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   test1.txt

no changes added to commit (use "git add" and/or "git commit -a")

$ git checkout -- test1.txt	# undo it

$ cat test1.txt		# to check the result of undo
```

To undo all the files:
```
git checkout -- .
```

### Reverting code changes: `git revert <commit>`

Change test1.txt
```
$ git add test1.txt 

$ git commit -m "Kimchi"

$ git log
commit 535e83c86569a82599b265ef2da980e2ec335062
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Thu May 17 10:53:25 2018 -0400

    Kimchi
```

Revert it to the previous commit
```
$ git revert 535e83c86569a82599b265ef2da980e2ec335062
[new-feature 2616dae] Revert "Kimchi"
 1 file changed, 1 insertion(+), 2 deletions(-)

$ git log
commit 2616dae5cdd3dd0cfb2c479e682dd02d3d559706
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Thu May 17 10:53:44 2018 -0400

    Revert "Kimchi"
    
    This reverts commit 535e83c86569a82599b265ef2da980e2ec335062.

commit 535e83c86569a82599b265ef2da980e2ec335062
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Thu May 17 10:53:25 2018 -0400

    Kimchi
```

### Reverting code changes: `git revert -n <commit>`
Note: `    -n, --no-commit       don't automatically commit`
```
$ git revert -n cd15871378bea2e00687c50707fb557488aa58ed
$ git status
On branch new-feature
You are currently reverting commit cd15871.
  (all conflicts fixed: run "git revert --continue")
  (use "git revert --abort" to cancel the revert operation)

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   test1.txt

$ git commit -m "revert Mold Inspection"
[new-feature e2adb74] revert Mold Inspection
 1 file changed, 1 deletion(-)

$ git log
commit e2adb74f1878108a50195b081eecef15e3700ca5
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Thu May 17 13:22:02 2018 -0400

    revert Mold Inspection
```

### Resetting code changes: `git reset --hard <commit>`
```
$ git log
commit e2adb74f1878108a50195b081eecef15e3700ca5
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Thu May 17 13:22:02 2018 -0400

    revert Mold Inspection

commit 5310dcf4be0244683d170f33c0406157331e8002
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Thu May 17 10:54:32 2018 -0400

    Revert "Burger"
    
    This reverts commit 7f82494e723a7874de266f18e76ce10e9e355c99.

commit 2616dae5cdd3dd0cfb2c479e682dd02d3d559706
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Thu May 17 10:53:44 2018 -0400

    Revert "Kimchi"
    
    This reverts commit 535e83c86569a82599b265ef2da980e2ec335062.

commit 535e83c86569a82599b265ef2da980e2ec335062
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Thu May 17 10:53:25 2018 -0400

    Kimchi
...

$ git reset --hard 535e83c86569a82599b265ef2da980e2ec335062
HEAD is now at 535e83c Kimchi

$ git log
commit 535e83c86569a82599b265ef2da980e2ec335062
Author: Hee Won Lee <knowpd@gmail.com>
Date:   Thu May 17 10:53:25 2018 -0400

    Kimchi
```


### Troubleshooting
Problem
```
$ git revert 7f82494e723a7874de266f18e76ce10e9e355c99
error: There was a problem with the editor 'vi'.
Please supply the message using either -m or -F option.
```
Solution:  
ref: <https://github.com/VundleVim/Vundle.vim/issues/167>
```
git config --global core.editor $(which vim)
```

git merge
----------
###  Usage
```
git checkout feature
git merge master
```
Or, you can condense this to a one-liner:
```
git merge master feature
```

### My test
```
$ git checkout master
$ git branch
  hotfix
* master
  new-feature
$ git merge new-feature
$ git push
```


Merging vs. Rebasing
====================
The first thing to understand about `git rebase` is that it solves the same problem as `git merge`. 

Merge
-----
### Abort a merge
```
$ git checkout -b new-feature
## Edit line 2 in test2.txt
$ git add test2.txt
$ git commit -m "Line 2"

$ git checkout master
## Edit line 2 & 3 in test1.txt
$ git add test2.txt
$ git commit -m "Line 2 & 3"

$ git checkout new-feature
$ git merge master
Auto-merging test2.txt
CONFLICT (content): Merge conflict in test2.txt
Automatic merge failed; fix conflicts and then commit the result.

$ git status
On branch myfood
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)

	both modified:   test2.txt

no changes added to commit (use "git add" and/or "git commit -a")

$ cat test2.txt
Burger
<<<<<<< HEAD
Pizza
=======

Udon
>>>>>>> master

$ git merge --abort

$ cat test2.txt
Burger
Pizza
```

### Resolving a merge conflict
ref: <https://help.github.com/articles/resolving-a-merge-conflict-using-the-command-line>
1. When you open the file in your text editor, you'll see the changes from the HEAD or base branch after the line `<<<<<<< HEAD`. Next, you'll see `=======`, which divides your changes from the changes in the other branch, followed by `>>>>>>> BRANCH-NAME`.

2. Delete the conflict markers `<<<<<<<`, `=======`, `>>>>>>>` and make the changes you want in the final merge. 

3. Add/commit your changes
```
git add .
git commit -m "Resolved merge conflict by incorporating both suggestions."
```

Rebase
------
ref: <https://help.github.com/articles/resolving-merge-conflicts-after-a-git-rebase>  
### Abort a rebase
```
## Edit test3.txt
$ git add test3.txt 
$ git commit -m "Language"

$ git checkout -b mysubject
## Edit test3.txt
$ git add test3.txt 
$ git commit -m "Math"
## Edit test3.txt 
$ git add test3.txt 
$ git commit -m "Science"

$ git checkout master
## Edit test3.txt 
$ git add test3.txt 
$ git commit -m "Music"

$ git checkout mysubject
$ git rebase master
First, rewinding head to replay your work on top of it...
Applying: Math
Using index info to reconstruct a base tree...
M	test3.txt
Falling back to patching base and 3-way merge...
Auto-merging test3.txt
CONFLICT (content): Merge conflict in test3.txt
error: Failed to merge in the changes.
Patch failed at 0001 Math
The copy of the patch that failed is found in: .git/rebase-apply/patch

When you have resolved this problem, run "git rebase --continue".
If you prefer to skip this patch, run "git rebase --skip" instead.
To check out the original branch and stop rebasing, run "git rebase --abort".

$ cat test3.txt 
Language
<<<<<<< HEAD
Music
=======
Math
>>>>>>> Math
```

### Abort a rebase
```
$ git rebase --abort

$ cat test3.txt
Language
Math
Science
```
### Resolve a rebase conflict
1. When you open the file in your text editor, you'll see the changes from the HEAD or base branch after the line `<<<<<<< HEAD`. Next, you'll see `=======`, which divides your changes from the changes in the other branch, followed by `>>>>>>> BRANCH-NAME`.

2. Delete the conflict markers `<<<<<<<`, `=======`, `>>>>>>>` and make the changes you want in the final merge.

3. Add your changes and run `git rebase --continue`
```
$ git add test3.txt 
$ git rebase --continue
Applying: Math
Applying: Science
Using index info to reconstruct a base tree...
M	test3.txt
Falling back to patching base and 3-way merge...
Auto-merging test3.txt
Applying: Art
Using index info to reconstruct a base tree...
M	test3.txt
Falling back to patching base and 3-way merge...
Auto-merging test3.txt
```

4. Check if the rebase is successful 
```
git log
```

5. (Optional) To merge this to master
```
$ git checkout master
$ git merge mysubject
$ git branch -d mysubject
```

### Safe way of rebase
If you're not entirely comfortable with git rebase, you can always perform the rebase in a temporary branch.
```
git checkout feature
git checkout -b temporary-branch
git rebase -i master
# [Clean up the history]
git checkout master
git merge temporary-branch
```

