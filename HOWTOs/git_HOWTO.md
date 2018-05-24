git, github HOWTO
=================
Ref: <https://www.atlassian.com/git/tutorials/setting-up-a-repository>

git init/clone/config
---------------------
```
git init proj1
```
- Transform the current directory into a Git repository.
- Executing git init creates a .git subdirectory in the project root.
- Unlike SVN, Git doesn't require a .git folder in every subdirectory.

```
git init --bare proj1.git
```
- The --bare flag creates a repository that doesn't have a working directory, 
 making it impossible to edit files and commit changes in that repository. 
- Central repositories should always be created as bare repositories because 
 pushing branches to a non-bare repository has the potential to overwrite changes.
- The bare version of a repository called proj1 is stored in a directory called proj1.git.

```
git clone ssh://vhost@localhost/home/vhost/test/central_repo/proj1.git
```
- The .git extension is omitted from the cloned repository.
- It automatically creates a remote connection called "origin" pointing back to the cloned repository.

```
git config --global user.name "knowpd"
git config --global user.email knowpd@research.att.com
```
- Define the author name/email to be used for all commits by the current user/email.

To open configuration files:
```
vi ~/.gitconfig
# Or, vi .git/config
```
This is where options set with the `--global flag` are stored. (i.e. `$ git config --global --edit`)


git add/commit
--------------
* NOTE: 
   - `git add` needs to be called every time you alter a file, 
    whereas `svn add` only needs to be called once for each file.
   - it’s important to create atomic commits so that it’s easy to track down 
    bugs and revert changes with minimal impact on the rest of the project.

Stage all changes in <file> for the next commit.
```
git add <file>
```

Stage all changes in <directory> for the next commit.
```
$ git add <directory>
```

```
$ git add .
$ git commit
```

```
$ git add hello.py
$ git commit
```


git status/log  
--------------
```
git status

git log
git log -n 3 		# will desplay only 3 commits
git log --oneline	# condense each commit to a single line
git log --stat
git log -p		# Display the patch representing each commit.
git log --graph --decorate --oneline
git log --author="knowpd" -p hello.txt

git log --author="<pattern>"
git log --grep="<pattern>"	# Search for commits with a commit message that matches <pattern>, which can be a plain string or a regular expression.
git log <since>..<until>	# Both arguments can be either a commit ID, a branch name, HEAD, or any other kind of revision reference
git log <file>
git log --oneline master..some-feature
 ~ character
 3157e~1 refers to the commit before 3157e, and HEAD~3 is the great-grandparent of the current commit.
```


git checkout
------------
Check out a previous version of a file.
```
git checkout <commit> <file>
```

Update all files in the working directory to match the specified commit.
```
git checkout <commit>

# To return to the master:
git checkout master
```

Examples:
```
git log -> commit 7f8b92de8f727a156ebe8f0ab8bad6531e460961
git checkout 7f8b
git checkout master
git checkout 7f8b hello.txt
git checkout HEAD hello.txt
git log --oneline
```


git revert  
----------
Instead of deleting it, `git revert` added a new commit to undo its changes.
```
# Edit some tracked files
git commit -m "Make some changes that will be undone"

# Revert the commit we just created
git revert HEAD
```

If `git revert` is a safe way to undo changes, you can think of git reset as the dangerous method; it is a permanent undo.
The point is, make sure that you’re using `git reset <commit>` on a local experiment that went wrong—not on published changes.


git reset  
---------
```
git reset main.py
git commit -m "Make some changes to hello.py"
git add main.py
git commit -m "Edit main.py"
```

Create a new file called `foo.py` and add some code to it
```
git add foo.py
git commit -m "Start developing a crazy feature"
```

Edit `foo.py` again and change some other tracked files, too
```
git commit -a -m "Continue my crazy feature"
git reset --hard HEAD~2
```

git clean    
---------
The git clean command removes untracked files from your working directory.  

Perform a “dry run” of git clean. This will show you which files are going to be removed without actually doing it.
```
$ git clean -n			# dry run
```

```
git reset --hard
git clean -df			# -d: remove whole directories, -f: force
git clean -xf
```

git commit --amend 
------------------ 
Usage:
```
git commit --amend
```

Combine the staged changes with the previous commit and replace the previous commit with the resulting snapshot.

Edit hello.py and main.py
```
git add hello.py
git commit
```
Realize you forgot to add the changes from main.py
```
git add main.py
git commit --amend --no-edit			# <--- git commit --amend
```


git rebase  
----------
ref: <https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase>  

Usage
```
git rebase <base>
```

Rebase the current branch onto `<base>`, which can be any kind of commit reference 
(an ID, a branch name, a tag, or a relative reference to HEAD).

The primary reason for rebasing is to maintain a linear project history. 
For example, consider a situation where the master branch has progressed since you started working on a feature.
You have two options for integrating your feature into the master branch: 
merging directly or rebasing and then merging.

Rebasing is a common way to integrate upstream changes into your local repository.  

Start a new feature
```
git checkout -b new-feature master		# <--- create a new branch

# Edit files
git commit -a -m "Start developing a feature"
```

Create a hotfix branch from master
```
git checkout -b hotfix master

# Edit files
git commit -a -m "Fix security hole"
```

Merge back into master
```
git checkout master
git merge hotfix
git branch -d hotfix				# <--- delete fully merged branch
git checkout new-feature
git rebase master				# <--- rebase
git checkout master
git merge new-feature
```

Running git rebase with the -i flag begins an interactive rebasing session.
```
git rebase -i
```


git remote
----------
The git remote command lets you create, view, and delete connections to other repositories. 
Remote connections are more like bookmarks rather than direct links into other repositories.

```
$ git remote -v		# List the remote connections you have to other repositories.
origin	git+ssh://knowpd@forge.research.att.com//var/lib/gforge/chroot/scmrepos/git/sds/sds.git (fetch)
origin	git+ssh://knowpd@forge.research.att.com//var/lib/gforge/chroot/scmrepos/git/sds/sds.git (push)
```

```
$ git remote add <name> <url>
$ git remote rm <name>
$ git remote rename <old-name> <new-name>

$ git remote add john http://dev.example.com/john.git
```

When you clone a repository with git clone, it automatically creates a remote connection called origin pointing back to the cloned repository. 

Two ways to access a remote repo are via the HTTP and the SSH protocols.
- It's generally not possible to push commits to an HTTP address:
`http://host/path/to/repo.git`

- For read-write access, you should use SSH instead:
`ssh://user@host/path/to/repo.git`

Example:
```
git+ssh://knowpd@forge.research.att.com//var/lib/gforge/chroot/scmrepos/git/sds/sds.git
ssh://vhost@localhost/home/vhost/test/central_repo/proj1.git
```


git fetch/merge
---------------
ref:   
   - <https://www.atlassian.com/git/tutorials/syncing/git-fetch>
   - <https://www.youtube.com/watch?v=EnCe89ioCZQ>  

Fetch all of the branches from the repository.
```
$ git fetch <remote>
```

Same as the above command, but only fetch the specified branch.
```
git fetch <remote> <branch>
```

Fetches all registered remotes and their branches:
```
git fetch --all
```

The --dry-run option will perform a demo run of the command:
```
git fetch --dry-run
```

### Synchronize origin with git fetch
```
$ git fetch origin

$ git log --oneline master
7f82494 Burger
85dcece First Commit

$ git log --oneline origin/master
50083c7 New commit
7f82494 Burger
85dcece First Commit

$ git log --oneline master..origin/master
50083c7 New commit

$ git log origin/master
$ git merge origin/master
```

* NOTE:
   - Since fetched content is represented as a remote branch, it has absolutely no effect on your local development work.
   - Remote branches are just like local branches, except they represent commits from somebody else's repository.


git pull
--------
Fetch the specified remote’s copy of the current branch and immediately merge it into the local copy. 
```
git pull <remote>
```

This is the same as:
``` 
git fetch <remote>
git merge origin/<current-branch>.
```

Same as the above command, but instead of using git merge to integrate the remote branch with the local one, use git rebase.
```
git pull --rebase <remote>
```

Many developers prefer rebasing over merging, since it’s like saying, "I want to put my changes on top of what everybody else has done." In this sense, using git pull with the --rebase flag is even more like svn update than a plain git pull.

After running the following command, all git pull commands will integrate via git rebase instead of git merge.git 
```
git config --global branch.autosetuprebase always
```

```
git checkout master
git pull --rebase origin
```


git push
--------
Push the specified branch to <remote>, along with all of the necessary commits and internal objects.
```
$ git push <remote> <branch>
```

Push all of your local branches to the specified remote.
```
$ git push <remote> --all
```

If the remote history has diverged from your history, you need to pull the remote branch and merge it into your local one, then try pushing again. This is similar to how SVN makes you synchronize with the central repository via svn update before committing a changeset.
The --force flag overrides this behavior and makes the remote repository’s branch match your local one, deleting any upstream changes that may have occurred since you last pulled.
you should only push to repositories that have been created with the --bare flag. Since pushing messes with the remote branch structure, it’s important to never push to another developer’s repository.
```
git checkout master
git fetch origin master
git rebase -i origin/master
# Squash commits, fix up commit messages etc.
git push origin master
```


git branch
----------
* KEY POINT
   - Branches are just pointers to commits. When you create a branch, all Git needs to do is create a new pointer; it doesn't change the repository in any other way.
   - master is a default branch in git.

Create a branch
```
$ git branch crazy-experiment
```

Delete the branch
```
$ git branch -d crazy-experiment
```

Deletes the branch regardless of its status and without warnings
```
$ git branch -D crazy-experiment
```

Check out the specified branch
```
$ git checkout <existing-branch>
```

Create (`git branch <new-branch>`) and checkout a new branch (`git checkout <new-branch>`)
```
$ git checkout -b <new-branch>
```

Same as the above invocation, but base the new branch off of <existing-branch> instead of the current branch.
```
$ git checkout -b <new-branch> <existing-branch>
```

### Detached HEADs
- HEAD: Git's way of referring to the current snapshot.
- The git checkout command simply updates the HEAD to point to either the specified branch or commit. 
When it points to a branch, Git doesn't complain, but when you check out a commit, it switches into a “detached HEAD” state.
- If you were to start developing a feature while in a detached HEAD state, there would be no branch allowing you to get back to it.
- The point is, your development should always take place on a branch—never on a detached HEAD.

### Fast-forward merge
- Can occur when there is a linear path from the current branch tip to the target branch.
- However, a fast-forward merge is not possible if the branches have diverged.

### 3-way merge
Refer to <http://www.drdobbs.com/tools/three-way-merging-a-look-under-the-hood/240164902>

