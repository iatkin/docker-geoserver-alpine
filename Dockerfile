from alpine:3.7 AS build
RUN mkdir /tmp/setup
WORKDIR /tmp/setup
RUN apk --no-cache add g++ gcc m4 make zlib-dev libc-dev curl-dev linux-headers

RUN wget -q ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4/hdf5-1.8.13.tar.gz
RUN wget -q https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.6.1.tar.gz

RUN tar -xzf hdf5-1.8.13.tar.gz
RUN tar -xzf netcdf-4.6.1.tar.gz

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub
RUN wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-2.27-r0.apk
RUN wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-dev-2.27-r0.apk
RUN apk --no-cache add glibc-2.27-r0.apk
RUN apk --no-cache add glibc-dev-2.27-r0.apk
ENV LD_LIBRARY_PATH "/usr/glibc-compat/lib"

WORKDIR /tmp/setup/hdf5-1.8.13
RUN ./configure  --prefix=/usr/local && make && make install

WORKDIR /tmp/setup/netcdf-4.6.1
RUN ./configure --prefix=/usr/local && make && make install

from alpine:3.7

ARG MIN_HEAP="4G"
ARG MAX_HEAP="6G"
ARG JAVA_OPTS="-Djava.awt.headless=true -server -Xrs -XX:PerfDataSamplingInterval=500 -Dorg.geotools.referencing.forceXY=true -XX:SoftRefLRUPolicyMSPerMB=36000 -XX:+UseParallelGC -XX:NewRatio=2 -XX:+CMSClassUnloadingEnabled -Xbootclasspath/a:/usr/local/marlin/marlin-0.9.2.jar -Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine"
ARG COMMUNITY_MODULES="true"
ENV LANG C.UTF-8

RUN apk -q --no-cache add wget unzip openjdk8-jre tomcat-native ca-certificates libcurl

ENV JAVA_HOME "/usr/lib/jvm/java-1.8-openjdk/jre"
ENV PATH "$JAVA_HOME/bin:$PATH"
ENV JAVA_OPTS "$JAVA_OPTS -Xms$MIN_HEAP -Xmx$MAX_HEAP"

COPY --from=build /usr/local/bin/* /usr/local/bin/
COPY --from=build /usr/local/lib/* /usr/local/lib/

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub
RUN wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-2.27-r0.apk
RUN apk --no-cache add glibc-2.27-r0.apk
ENV LD_LIBRARY_PATH "/usr/glibc-compat/lib"

RUN mkdir /tmp/setup
WORKDIR /tmp/setup

RUN wget -q http://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz
RUN tar -xzf apache-tomcat-8.5.32.tar.gz

ENV CATALINA_HOME "/usr/local/tomcat"
RUN mv apache-tomcat-8.5.32 $CATALINA_HOME

ARG GS_VERSION="2.13.0"
COPY plugins .
COPY download.sh .
RUN sh download.sh

ENV GEOSERVER_DATA_DIR /opt/geoserver/data
ENV FOOTPRINTS_DATA_DIR /opt/geoserver/footprints

COPY setup.sh .
RUN sh setup.sh

WORKDIR $CATALINA_HOME
RUN rm -rf /tmp/setup

EXPOSE 8080
CMD ["sh", "bin/catalina.sh", "run"]
