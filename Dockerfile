FROM ruby as enable-ci-cd-using-travis
RUN apt-get update -qy
RUN apt-get install -qy jq maven
RUN ruby -v
RUN mvn -version 
RUN gem install travis
ADD entrypoint.sh /opt
ADD append.to.travis.yml /opt
ADD prepend.to.travis.yml /opt

ADD src /root/src
CMD chmod u+x /opt/entrypoint.sh && /opt/entrypoint.sh
