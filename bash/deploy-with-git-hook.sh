#!/bin/sh

#####
#####
##### PLEASE UNDERSTAND WHAT THIS DOES BEFORE USING IT
##### DON'T BLAME ME IF YOUR SERVER EXPLODES
#####
#####
##### This script intends to help you create a simple git-hook based deploy system.
##### For this, give it the repository root dir, a project/repo name, and its owner.
##### A post-receive git-hook will be created for each repo, which you're encouraged
##### to edit so it can perform the tasks needed.
#####
##### Read the warning at the top.
#####
#####

E_MISSINGARGS=85

# The root dir that will contain all the repositories
# The current user must have write access here
REPOS_DIR=$1
D_REPOS_DIR=/srv/repos

# The inside dir that will contain the current project
PROJECT_NAME=$2
D_PROJECT_NAME=new-project

CUR_USER=$(whoami)

# The owner.group which will be set onto the root dir
REPOS_DIR_OWNER=$3
D_REPOS_DIR_OWNER=$CUR_USER.$CUR_USER

echo "Hi. I'll need root"

# Checking arguments
if [ -z "${REPOS_DIR}" ]; then
  echo "Gimme the repositories root dir"
  echo [$D_REPOS_DIR]
  read REPOS_DIR
  if [ -z "${REPOS_DIR}" ]; then
    REPOS_DIR=$D_REPOS_DIR
  fi
fi

if [ -z "${PROJECT_NAME}" ]; then
  echo "Gimme the project name"
  echo [$D_PROJECT_NAME]
  read PROJECT_NAME
  if [ -z "${PROJECT_NAME}" ]; then
    PROJECT_NAME=$D_PROJECT_NAME
  fi
fi

if [ -z "${REPOS_DIR_OWNER}" ]; then
  echo "Gimme the repository owner, eg: user.group"
  echo [$D_REPOS_DIR_OWNER]
  read REPOS_DIR_OWNER
  if [ -z "${REPOS_DIR_OWNER}" ]; then
    REPOS_DIR_OWNER=$D_REPOS_DIR_OWNER
  fi
fi

if [ -z "${REPOS_DIR_OWNER}" -o -z "${PROJECT_NAME}" -o -z "${REPOS_DIR}" ]; then
  echo "Empty variables. existing"
  exit $E_MISSINGARGS
fi

echo "Creating new repo on ${REPOS_DIR}/${PROJECT_NAME} owned by ${REPOS_DIR_OWNER}"
echo "Confirm? [Y/n]"

read CONFIRM

if [ ${CONFIRM} ]; then
  if [ "${CONFIRM}" != 'Y' -a "${CONFIRM}" != 'y' ]; then
    echo "noped. exiting"
    exit 0
  fi
fi

# Creating the repos dir
sudo mkdir $REPOS_DIR -p -m 774
sudo chown $REPOS_DIR_OWNER $REPOS_DIR
cd $REPOS_DIR
# Creating the git repo
git init --bare $PROJECT_NAME

# Creating the post-receive hook file
OUTFILE=$PROJECT_NAME/hooks/post-receive

(
cat <<'EO_OUTFILE'
#!/bin/sh

ALLOWED_BRANCH=master

while read oldrev newrev ref
do
  echo
  echo "*** DEPLOY SCRIPT ***"

  # only checking out the master branch
  if [[ $ref = refs/heads/$ALLOWED_BRANCH ]];
  then
    branch_name=$(echo $ALLOWED_BRANCH | sed 's/refs\/heads\///')

    echo "*** Ref $ref received. Deploying $branch_name branch to production..."
    echo "*** Checking out repo..."

    WORK_TREE=.

    git --work-tree=$WORK_TREE checkout -qf $branch_name
    cd $WORK_TREE

    # Common node.js deploy tasks. You'll probably want to change these
    # The output from any command here will be sent to the local machine

    echo "*** yarning..."
    yarn install

    echo "*** gulping..."
    gulp

    echo "*** building..."
    yarn build

    # Create this dir if you haven't already
    # echo "*** dist folder copying..."
    # cp dist/* /var/www/html/$PROJECT_NAME

    echo "*** $(date -Iseconds) - Deploy of $branch_name branch, from ${oldrev:0:7} to ${newrev:0:7}, finished" >> deploy.log
    echo "*** done. fly safe"
  else
    echo "*** Ref $ref received. Doing nothing: only the $ALLOWED_BRANCH branch may be deployed on this server"
  fi

  echo
done
EO_OUTFILE
) > $OUTFILE

# Configuring permissions
sudo chown $REPOS_DIR_OWNER $PROJECT_NAME -R
sudo chmod g+rwx $PROJECT_NAME -R
sudo chmod +x $OUTFILE

REPOS_PATH=$(pwd)

echo
echo "Shiny!"
echo "Now add the git remote with something like:"
echo "git remote add prod $CUR_USER@mysecureserver.com:$REPOS_PATH/$PROJECT_NAME"
echo "and make sure to check the hook deploy steps at $REPOS_PATH/$OUTFILE"
echo "Then, deploy with git push prod"

exit 0
