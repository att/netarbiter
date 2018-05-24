GitHub HOWTO
============
Author: Hee Won Lee <knowpd@gmail.com>

### Create a new repository on the command line
1. From your browser, create a new repository (e.g., git-test)
2. Open a terminal  
```
echo "# git-test" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin git@github.com:knowpd/git-test.git
git push -u origin master
# Or, `git push --set-upstream origin master`
```

### Adding an existing project to GitHub using the command line
ref: <https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line>
1. From your browser, create a new repository (e.g., git-test)
2. Open a terminal  
```
cd /my/directory
git init
git add .
git commit -m "first commit"
git remote add origin git@github.com:knowpd/git-test.git
git remote -v
git push -u origin master	

git status
git commit -m 'COPYING.LESSER added'
```

### Delete a repository  
ref: <https://help.github.com/articles/deleting-a-repository>
Manually enter the URL for your repository's Settings page in your browser:
https://github.com/YOUR-USERNAME/YOUR-REPOSITORY/settings

### Download a single folder or directory from a GitHub repo  
ref: <http://stackoverflow.com/questions/7106012/download-a-single-folder-or-directory-from-a-github-repo>

For example, if a git repo URL is <https://github.com/knowpd/tst-c/tree/master/c/kernel_module>, then
replace tree/master with trunk as follows:
```
svn checkout https://github.com/knowpd/tst-c/tree/trunk/c/kernel_module
``` 

