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

encrypted_SOME_iv=$(date | md5sum | head -c10)
encrypted_SOME_key=$(date | sha256sum | head -c120)

travis encrypt encrypted_SOME_iv=$encrypted_SOME_iv --add
travis encrypt encrypted_SOME_key=$encrypted_SOME_key --add

## TODO create tar file


openssl aes-256-cbc -K $encrypted_SOME_key -iv $encrypted_SOME_iv -in ~/tmp/secrets.tar -out secrets.tar.enc



