#! /bin/bash 

docker run -it --rm -e GITREPONAME=$SLUG \
    -e encrypted_key=$encrypted_SOME_iv \
    -e encrypted_iv=$encrypted_SOME_key \
    -e GITHUBTOKEN=$GITHUBTOKEN \
    -e SONATYPE_USERNAME=$SONATYPE_USERNAME \
    -e SONATYPE_PASSWORD=$SONATYPE_PASSWORD \
    -e GPG_PASSPHRASE=$GPG_PASSPHRASE \
    -e GPG_KEYID=$GPG_KEYID \
    -e GPG_KEY=$GPG_KEY \
    -e GITHUBUSER=$GITHUBUSER \
    -e DOCKER_USERNAME=$DOCKER_USERNAME \
    -e DOCKER_PASSWORD=$DOCKER_PASSWORD \
    enable-ci-cd-using-travis:latest