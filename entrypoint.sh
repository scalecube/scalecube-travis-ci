#! /bin/bash 
set -xe

encrypted_SOME_iv=$encrypted_iv
encrypted_SOME_key=$encrypted_key

TRAVIS_PULL_REQUEST=''
TRAVIS_REPO_SLUG=$GITREPONAME
cd ~
mkdir ~/.ssh
chmod 700 ~/.ssh

#backup encrypted tar
mkdir -p ~/bkp
chmod 700 ~/bkp
cp ~/src/main/scripts/cd/secrets.tar.enc ~/bkp/secrets.tar.enc


. ~/src/main/scripts/cd/before-deploy.sh

decryptsecrets
#importpgp
setupssh

git clone git@github.com:$GITREPONAME.git ~/repo
cd ~/repo
setupgit

travis login --github-token $GITHUBTOKEN
travis enable -r $GITREPONAME 
encrypted_SOME_iv=$(date | md5sum | head -c10)
encrypted_SOME_key=$(date | sha256sum | head -c120)

travis encrypt encrypted_SOME_iv=$encrypted_SOME_iv --add
travis encrypt encrypted_SOME_key=$encrypted_SOME_key --add

## TODO create tar file

openssl aes-256-cbc -K $encrypted_key -iv $encrypted_iv -in ~/bkp/secrets.tar.enc | openssl aes-256-cbc -K $encrypted_SOME_key -iv $encrypted_SOME_iv -out ~/repo/src/main/scripts/cd/secrets.tar.enc



