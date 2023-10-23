# File: vdoc/Dockerfile
FROM tomcat:9.0

ENV CATALINA_BASE /usr/local/tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV CATALINA_TMPDIR /usr/local/tomcat/temp
# ENV JRE_HOME /usr

WORKDIR $CATALINA_HOME

RUN apt-get update && \
  apt-get -y install mariadb-server && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN /etc/init.d/mariadb start

EXPOSE 8080

ENTRYPOINT ["catalina.sh", "run"]):