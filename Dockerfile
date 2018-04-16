FROM ruby as enable-ci-cd-using-travis

ADD entrypoint.sh /opt
ADD src /root/src
RUN yes | gem install travis
CMD chmod u+x /opt/entrypoint.sh && /opt/entrypoint.sh
