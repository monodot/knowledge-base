---
layout: page
title: Git
---

## Getting started

Cloning a repo and setting a custom email address for commit logs:

```
git clone https://git.mycorporatecompany.example.com/monolith
cd monolith
git config user.email tdonohue@mycorporatecompany.example.com
```

Enabling the credential cache, timeout in seconds (default cache timeout = 15 minutes):

```
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
```

## Working with files (checkouts and commits)

Undo changes (check out) to a file `filename.txt` (discard unstaged changes):

```
git checkout -- filename.txt
```

Check out the branch `stuff`:

```
git checkout stuff
```

Add more files to the last commit (when you've just committed but you forgot about a few files that need to go into the same commit):

```
git add <left_out_files>
git commit --amend --no-edit
```

## Stashing

Stash unfinished changes:

```
git stash push -m "My stash description" <pathspec>
# or just 'git stash'
```

To include untracked files in a stash:

```
git stash --all
```

List all stashes:

```
git stash list
```

Apply the most recent stash **and keep the changes in the stash stack**:

```
git stash apply
```

Apply the most recent stash **and remove the changes from the stash stack**:

```
git stash pop
```

Create a new branch from a stash:

```
git stash branch new_branch_name stash_id
```

## Branches and Tags

List all branches (including remotes):

```
git branch -a
```

List all local branches with their most recent commit dates:

```shell
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' refs/heads/
# monodot/keycloak 2 minutes ago
# main 2 weeks ago
# monodot/config-update 2 weeks ago
# monodot/update-scripts 8 weeks ago
```

Check out a new local branch `mybranch` which tracks the remote branch `mybranch` (if it exists):

```
git checkout mybranch
```

Fetch branches from the remote repository called `origin`:

```
git fetch origin
```

Fetch all branches **and tags** from all remote repositories:

```
git fetch --all --tags --prune
```

Create (checkout) a new branch:

```
git checkout -b mybranch
```

Create a new branch and commit existing, uncommitted work to it:

```
git checkout -b mynewbranch
git add .
git commit -m "New branchy stuff"
```

Push a branch remotely (to the `origin` remote repository):

```
git push -u origin mybranch
```

Delete a branch both locally and remotely:

```
git push origin -d mybranch
git branch -d mybranch
```

List all tags:

```
git tag
```

Check out a tag:

```
git checkout tags/<tag_name> -b <branch_name>
```

## Merging and rebasing

**Merge** changes from the development branch into master, and squashing the intermediate commits:

```
git checkout master
git merge --squash develop
git commit
```

**Merge** changes from origin's `master` branch into a public or shared development branch:

```
git checkout my-branch-name
git fetch origin
git merge origin/master
```

Or, use **rebase**, if:

- Your branch is local only, and hasn't been pushed to `origin`.

**Rebase:** 

```
git checkout my-feature-branch
git merge origin/master
```

## Merge conflicts

When Git sees a conflict between two branches being merged, it adds **merge conflict markers** into the code and **marks the file as conflicted** to let you resolve it.

Git **conflict markers** follow this syntax:

```
<<<<<<< HEAD
text from branch you are merging INTO (i.e. your local changes)
=======
text from commit that you are trying to merge IN (i.e. the remote changes, being merged in)
>>>>>>> somebranchidentifiergoeshere
```

## Remote repositories

List all remote repositories:

```
git remote -v
```

## Forks

Sync a fork to keep it up-to-date with its upstream repository:

```
cd my-forked-repo
git remote add upstream https://github.com/username/original-repo
git fetch upstream
git checkout master
git merge upstream/master
git push origin master
```

## Exporting/packaging

Export a Git repository to a zip:

```
git archive -o /path/to/ouputfile.zip HEAD
```

## Submodules

Add a submodule to an existing project:

```
git submodule add https://github.com/username/example-repo new-directory-name
```

## Emergency panic stations

Revert the repository to the last committed state (any uncommitted work will be lost!):

```
git reset --hard HEAD
```

Remove a file from a historical commit:

```
git filter-branch --index-filter \
    'git rm --cached --ignore-unmatch path/to/file/to/be/deleted.xml' \
    --tag-name-filter cat -- --all
```

## Advanced

Configure Git to use a SOCKS5 proxy (e.g. when using an SSH tunnel to reach the host), where the hostname lookup itself also must go through the proxy:

```
git config --global http.proxy socks5h://hostname:port
```

## Hooks

### Example hook to build a Jekyll site when pushed

Add the following to your remote repo's `hooks/post-receive` file.

Note the use of `bash -l` which **inherits your login shell** and all the path settings required for running commands like `bundle`, etc:

```
#!/bin/bash -l

GIT_REPO=$HOME/git/myrepo.git
TMP_GIT_CLONE=$HOME/tmp/mysite.co.uk
PUBLIC_WWW=/var/www/mysite.co.uk/public_html
BRANCH_NAME=master
export JEKYLL_ENV=production

git clone -b $BRANCH_NAME $GIT_REPO $TMP_GIT_CLONE

echo "Cloned repo. Running timestamp update..."

pushd $TMP_GIT_CLONE
IFS="
"
# TODO fix this, because git ls-files clearly returns nothing
# when this script is invoked using git push REMOTE branch
for FILE in $(git ls-files)
do
    TIME=$(git log --pretty=format:%cd -n 1 --date=iso -- "$FILE")
    TIME=$(date --date="$TIME" +%Y%m%d%H%M.%S)
    echo "Touching $FILE to $TIME"
    touch -m -t "$TIME" "$FILE"
done
popd

pushd $TMP_GIT_CLONE
bundle install
bundle exec jekyll build -s $TMP_GIT_CLONE -d $PUBLIC_WWW
popd

echo "Site built. Removing temp dir..."

rm -Rf $TMP_GIT_CLONE

echo "Done."
exit
```

## Branching models

Some different thoughts on Git branching:

**Forking Flow**

- Developers fork from the `master` in the main repository
- Create a feature branch in the developer's fork.
- Feature branches should be short-lived, i.e. merged after a few days max
- Merge frequently to `master`, either manually or automatically from the CICD pipeline after passing tests.

**Master branch is always deployable to production**/**master is always stable**

- Only working, tested code makes it into master
- Anything in master can be deployed by anyone at any time
- Have Jenkins create a build artifact on every commit to master, and then move this artifact through staging and production.
- Rebase on master before merging
