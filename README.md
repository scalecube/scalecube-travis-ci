# enable-ci-cd-using-travis
This project automatically apply CI/CD for your scalecube project. it apply the relevant script files for ci/cd that will manage the release/snapshoot versions and continusly deploy the artifacts to maven central.

### Before starting you should test your project for deployablilty and releaseablility:

0. Make sure your *default branch* contains a `pom.xml` file
1. Make sure there are **no dependencies on snapshots** in the POMs to be released. However, the project you want to stage must be a **SNAPSHOT** version.
2. Check that your POMs will not lose content when they are rewritten during the release process:
2.1. Verify that all `pom.xml` files have an *SCM* definition. a parent project is sometime not suffice (e.g. in maven modules as git modules)
3. Do a dryRun release: `mvn release:prepare -DdryRun=true` p.s. you may also wish to pass `-DautoVersionSubmodules=true` as this will save you time if your project is multi-module. Follow the warnings or errors during this build. **Fix** any error before enabling the CI on your project.
3.1 Diff the original file `pom.xml` with the one called `pom.xml.tag` to see if the license or any other info has been removed. This has been known to happen if the starting **`<project>`** tag is **not** on a single line. The only things that should be different between these files are the **`<version>`** and **`<scm>`** elements. Any other changes you must backport yourself to the original `pom.xml` file and commit before proceeding with the release.

### In order to enable CI-CD on your project:

0. git clone git@github.com:scalecube/scalecube-travis-ci.git
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
TRAVIS_AUTH_TOKEN=12
```
