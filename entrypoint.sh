#! /bin/bash 

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
git pull
DEFAULT_BRANCH=$(curl -u "$GITHUBUSER:$GITHUBTOKEN" https://api.github.com/repos/$GITREPONAME | jq '.default_branch')

mkdir -p $TRAVIS_BUILD_DIR/src/main/scripts/cd/
cp ~/src/main/scripts/cd/*.sh $TRAVIS_BUILD_DIR/src/main/scripts/cd/
chmod u+x $TRAVIS_BUILD_DIR/src/main/scripts/cd/*.sh

mkdir -p ~/repo/src/main/scripts/ci/
cp ~/src/main/scripts/ci/*.sh $TRAVIS_BUILD_DIR/src/main/scripts/ci/
chmod u+x $TRAVIS_BUILD_DIR/src/main/scripts/ci/*.sh

cp /opt/travis-settings.xml $TRAVIS_BUILD_DIR/travis-settings.xml
cp /opt/requirements.txt $TRAVIS_BUILD_DIR/requirements.txt
md5sum $TRAVIS_BUILD_DIR/travis-settings.xml

git add --all
git commit -am "+ script files" | true 

cp /opt/.gitignore $TRAVIS_BUILD_DIR/.gitignore
git commit -am "+ git ignore" | true 

yes | travis login --org --github-token $GITHUBTOKEN
travis enable --org --store-repo $GITREPONAME

if [ ! -f '.travis.yml'  ]; then
   travis init java --jdk openjdk8
   
   cp /opt/fix.travis.yml .travis.yml
   git add .travis.yml
   git commit -m "new: travis ci configuration file"
   
   echo ***** travis.yml *****
   cat .travis.yml
   echo ***** travis.yml *****
else
   cp /opt/fix.travis.yml .travis.yml
   git add .travis.yml && git commit -m "updated: travis ci configuration file" || true
fi

export encrypted_SOME_iv=$encrypted_iv
export encrypted_SOME_key=$encrypted_key

travis env copy encrypted_SOME_iv encrypted_SOME_key SONATYPE_USERNAME SONATYPE_PASSWORD GPG_KEYID GPG_PASSPHRASE GPG_KEY GITHUBUSER GITHUBTOKEN DOCKER_USERNAME DOCKER_PASSWORD TRAVIS_AUTH_TOKEN -f -p

git add .travis.yml && git commit -a -m "+ secret keys" || true

openssl aes-256-cbc -d -K $encrypted_key -iv $encrypted_iv -in ~/src/main/scripts/cd/secrets.tar.enc | openssl aes-256-cbc -K $encrypted_SOME_key -iv $encrypted_SOME_iv -out $TRAVIS_BUILD_DIR/src/main/scripts/cd/secrets.tar.enc
git add src/main/scripts/cd/secrets.tar.enc
git commit -a -m "+ secret file" || true

CLEAN_BRANCH_NAME="${DEFAULT_BRANCH%\"}" && CLEAN_BRANCH_NAME="${CLEAN_BRANCH_NAME#\"}"
if git diff origin/$CLEAN_BRANCH_NAME --exit-code; then 
   echo CI is already applied. deleting unused branch...
   # delete old version of CI (if any)
   git push --delete origin $TRAVIS_BRANCH
   exit 0 # we should stop here
else
   echo Pushing CI branch...
   git push origin travis-ci-cd
fi

cd ~

# create a PR
curl -XPOST -u "$GITHUBUSER:$GITHUBTOKEN" \
  -o ~/pullrequest.json \
  -d '{"title": "ci-cd using Travis CI", "body": "ci-cd using Travis CI",  "head": "travis-ci-cd",  "base": '$DEFAULT_BRANCH'}'\
 https://api.github.com/repos/$GITREPONAME/pulls
 
eval "export comments=`jq '._links.comments.href' ~/pullrequest.json`"

if [ ! -f $TRAVIS_BUILD_DIR/travis-settings.xml ]; then
   echo missing travis-settings.xml
   curl -XPOST -u "$GITHUBUSER:$GITHUBTOKEN" -d '{"body":"missing travis-settings.xml"}' $comments
   exit 142
fi

if [ ! -f $TRAVIS_BUILD_DIR/pom.xml ]; then
   echo missing pom.xml. is it a java project?
   curl -XPOST -u "$GITHUBUSER:$GITHUBTOKEN" -d '{"body":"missing pom.xml. is it a java project?"}' $comments
   exit 142
fi

mvn -B -q -f $TRAVIS_BUILD_DIR/pom.xml -s $TRAVIS_BUILD_DIR/travis-settings.xml -P release \
   help:evaluate -Dexpression=project.scm.connection -Doutput=/tmp/project.scm.connection

echo project.scm.connection = `cat /tmp/project.scm.connection`
projectscmconnection=`cat /tmp/project.scm.connection`

if [ -z "$projectscmconnection" ]; then
   echo "missing project.scm.connection in pom.xml"
   curl -XPOST -u "$GITHUBUSER:$GITHUBTOKEN" -d '{"body":"missing project.scm.connection in pom.xml"}' $comments
fi

if [ "scm:git:git@github.com:$TRAVIS_REPO_SLUG.git" != "$projectscmconnection" ]; then
   echo invalid project.scm.connection in pom.xml: expected scm:git:git@github.com:$TRAVIS_REPO_SLUG.git but was $projectscmconnection
   curl -XPOST -u "$GITHUBUSER:$GITHUBTOKEN" -d '{"body":"invalid project.scm.connection in pom.xml: expected scm:git:git@github.com:'$TRAVIS_REPO_SLUG'.git but was '$projectscmconnection'!"}' $comments
fi

mvn -B -q -f $TRAVIS_BUILD_DIR/pom.xml -s $TRAVIS_BUILD_DIR/travis-settings.xml -P release \
   help:evaluate -Dexpression=gpg.passphrase -Doutput=/tmp/gpg.passphrase

mvn -B -q -f $TRAVIS_BUILD_DIR/pom.xml -s $TRAVIS_BUILD_DIR/travis-settings.xml -P release \
   fr.jcgay.maven.plugins:buildplan-maven-plugin:list-plugin -Dbuildplan.plugin=nexus-staging-maven-plugin -Dbuildplan.outputFile=/tmp/nexus-staging-maven-plugin
   


