FROM maven:3.5.3-jdk-8
FROM ruby as enable-ci-cd-using-travis
RUN gem install travis
RUN apt-get update
RUN apt-get install -y jq
RUN apt-get install -y 
ADD entrypoint.sh /opt
ADD append.to.travis.yml /opt
ADD prepend.to.travis.yml /opt

ADD src /root/src
CMD chmod u+x /opt/entrypoint.sh && /opt/entrypoint.sh
