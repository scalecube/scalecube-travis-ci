#! /bin/bash 
#set -xe

encrypted_SOME_iv=$encrypted_iv
encrypted_SOME_key=$encrypted_key

TRAVIS_PULL_REQUEST=''
TRAVIS_REPO_SLUG=$GITREPONAME
cd ~
mkdir ~/.ssh
chmod 700 ~/.ssh
. ~/src/main/scripts/cd/before-deploy.sh

decryptsecrets
#importpgp
setupssh

git clone git@github.com:$GITREPONAME.git repo
cd repo

setupgit

yes | travis login --github-token $GITHUBTOKEN

