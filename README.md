# enable-ci-cd-using-travis
This project automatically apply CI/CD for your scalecube project. it apply the relevant script files for ci/cd that will manage the release/snapshoot versions and continusly deploy the artifacts to maven central.


In order to enable CI-CD on your project:

0. git clone git@github.com:scalecube/enable-ci-cd-using-travis.git
1. download secrets file.
2. `docker build . --tag enable-ci-cd-using-travis`
3. `docker run -it --rm  --env-file secrets -e GITREPONAME=scalecube/your-new-repo enable-ci-cd-using-travis`


the secrets file should have:

```
encrypted_key=1
encrypted_iv=2
GITHUBTOKEN=3
SONATYPE_USERNAME=4
SONATYPE_PASSWORD=5
GPG_PASSPHRASE=6
GPG_KEYID=7
GPG_KEY=8
GITHUBUSER=9
DOCKER_USERNAME=10
DOCKER_PASSWORD=11
```
