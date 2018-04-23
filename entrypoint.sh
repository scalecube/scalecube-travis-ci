#! /bin/bash 
set -xe
encrypted_SOME_iv=$encrypted_iv
encrypted_SOME_key=$encrypted_key

TRAVIS_PULL_REQUEST='false'
TRAVIS_REPO_SLUG=$GITREPONAME
TRAVIS_BUILD_DIR=~/repo
TRAVIS_BRANCH=travis-ci-cd

cd ~
mkdir ~/.ssh
chmod 700 ~/.ssh

. ~/src/main/scripts/cd/before-deploy.sh
TRAVIS_BUILD_DIR=~
decryptsecrets
TRAVIS_BUILD_DIR=~/repo
setupssh

git clone git@github.com:$GITREPONAME.git $TRAVIS_BUILD_DIR
cd $TRAVIS_BUILD_DIR
setupgit
importpgp


DEFAULT_BRANCH=$(curl -u "$GITHUBUSER:$GITHUBTOKEN" https://api.github.com/repos/$GITREPONAME | jq '.default_branch')

mkdir -p $TRAVIS_BUILD_DIR/src/main/scripts/cd/
cp ~/src/main/scripts/cd/*.sh $TRAVIS_BUILD_DIR/src/main/scripts/cd/

mkdir -p ~/repo/src/main/scripts/ci/
cp ~/src/main/scripts/ci/*.sh $TRAVIS_BUILD_DIR/src/main/scripts/ci/
git add --all
git commit -am "+ script files" | true 

yes | travis login --github-token $GITHUBTOKEN
travis enable --store-repo $GITREPONAME

if [ ! -f .travis.yml  ]; then
    cat /opt/prepend.to.travis.yml > .travis.yml
	travis init java --jdk openjdk8 \
	   --before-install "./src/main/scripts/ci/before-install.sh" \
	   --before-install "./src/main/scripts/cd/before-deploy.sh" \
	   --after-success "java -jar ~/codacy-coverage-reporter-assembly.jar -l Java -r ./target/site/jacoco/jacoco.xml"
    
    cat /opt/append.to.travis.yml >> .travis.yml
	git add .travis.yml
    git commit -m "new: travis ci configuration file"
    echo ***** travis.yml *****
    cat travis.yml
    echo ***** travis.yml *****
fi
encrypted_SOME_iv=$(date | md5sum | head -c10)
encrypted_SOME_key=$(date | sha256sum | head -c64)

travis env copy encrypted_SOME_iv encrypted_SOME_key SONATYPE_USERNAME SONATYPE_PASSWORD GPG_PASSPHRASE GPG_KEY -p

git add .travis.yml && git commit -m "+ secret keys" || true

openssl aes-256-cbc -d -K $encrypted_key -iv $encrypted_iv -in ~/src/main/scripts/cd/secrets.tar.enc | openssl aes-256-cbc -K $encrypted_SOME_key -iv $encrypted_SOME_iv -out $TRAVIS_BUILD_DIR/src/main/scripts/cd/secrets.tar.enc
git add src/main/scripts/cd/secrets.tar.enc
git commit -m "+ secret file"

git push origin travis-ci-cd

# create a PR
curl -XPOST -u "$GITHUBUSER:$GITHUBTOKEN" \
  -d '{"title": "ci-cd using Travis CI", "body": "ci-cd using Travis CI",  "head": "travis-ci-cd",  "base": '$DEFAULT_BRANCH'}'\
 https://api.github.com/repos/$GITREPONAME/pulls
