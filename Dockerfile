FROM ruby as enable-ci-cd-using-travis
RUN gem install travis

ADD entrypoint.sh /opt
ADD append.to.travis.yml /opt
ADD src /root/src
CMD chmod u+x /opt/entrypoint.sh && /opt/entrypoint.sh
