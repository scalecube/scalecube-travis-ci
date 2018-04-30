# enable-ci-cd-using-travis
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
GPG_KEY=7
GITHUBUSER
```
