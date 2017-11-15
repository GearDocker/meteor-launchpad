FROM debian:jessie
MAINTAINER Jeremy Shimko <jeremy.shimko@gmail.com>

RUN groupadd -r node && useradd -m -g node node

# Gosu
ENV GOSU_VERSION 1.10

# PhantomJS
ENV PHANTOM_VERSION 2.1.1

COPY tar_1.29b-2_amd64.deb /var/tmp/tar_1.29b-2_amd64.deb
RUN dpkg -i /var/tmp/tar_1.29b-2_amd64.deb

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV APP_BUNDLE_DIR /opt/meteor/dist
ENV BUILD_SCRIPTS_DIR /opt/build_scripts

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
RUN chmod -R 750 $BUILD_SCRIPTS_DIR

RUN mkdir -p $APP_SOURCE_DIR
RUN mkdir -p $APP_BUNDLE_DIR

ARG INSTALL_PASSENGER
ENV INSTALL_PASSENGER ${INSTALL_PASSENGER:-true}

ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-4.8.6}

ARG NPM_TOKEN
ENV NPM_TOKEN $NPM_TOKEN

ARG INSTALL_PHANTOMJS
ENV INSTALL_PHANTOMJS $INSTALL_PHANTOMJS

ARG INSTALL_GRAPHICSMAGICK
ENV INSTALL_GRAPHICSMAGICK $INSTALL_GRAPHICSMAGICK

# Node flags for the Meteor build tool
ARG TOOL_NODE_FLAGS
ENV TOOL_NODE_FLAGS $TOOL_NODE_FLAGS

RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/install-deps.sh

RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/install-node.sh

RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/install-phantom.sh 

RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/install-graphicsmagick.sh 

RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/install-graphicsmagick.sh

RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/install-passenger.sh

RUN cd $APP_SOURCE_DIR && \
  curl "https://install.meteor.com/?release=1.5.2" | sh

RUN apt-get update && apt-get install p7zip-full -y
#RUN apt-get update && apt-get install p7zip-full p7zip-rar -y

#RUN cd $APP_SOURCE_DIR && \
#  curl "https://install.meteor.com/?release=1.4.4.4" | sh

#RUN /bin/bash -c "export TOTAL_MEMORY=`awk '/^(MemTotal)/{print $2}' /proc/meminfo` && \
#    export MEMORY_ALLOCATION=$(echo \"$TOTAL_MEMORY*0.75\"|bc) && \
#    export MEMORY_ALLOCATION=`echo $MEMORY_ALLOCATION | cut -c1-4` && \
#    export TOOL_NODE_FLAGS=\"--max-old-space-size=$MEMORY_ALLOCATION\ && \" 
#    echo $TOOL_NODE_FLAGS"

ONBUILD COPY . $APP_SOURCE_DIR
#ONBUILD ENV TOOL_NODE_FLAGS "--max-old-space-size=4096"
#ONBUILD RUN cd $APP_SOURCE_DIR && \
#  $BUILD_SCRIPTS_DIR/build-meteor.sh

RUN export TOTAL_MEMORY=`awk '/^(MemTotal)/{print $2}' /proc/meminfo` && \
    export MEMORY_ALLOCATION=$(echo "$TOTAL_MEMORY*0.75"|bc) && \
    export MEMORY_ALLOCATION=`echo $MEMORY_ALLOCATION | cut -c1-4` && \
    export TOOL_NODE_FLAGS="--max-old-space-size=$MEMORY_ALLOCATION" && \
    cd $APP_SOURCE_DIR && \
    $BUILD_SCRIPTS_DIR/build-meteor.sh

## start the app
#WORKDIR $APP_BUNDLE_DIR/bundle
#CMD ["passenger", "start", "--app-type", "node", "--startup-file", "main.js"]
#
##WORKDIR $APP_BUNDLE_DIR/bundle
##ENTRYPOINT ["./entrypoint.sh"]
##CMD ["node", "main.js"]
#CMD passenger start --app-type node --startup-file main.js --port 8090
