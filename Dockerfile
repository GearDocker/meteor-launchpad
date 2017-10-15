FROM debian:jessie
MAINTAINER Jeremy Shimko <jeremy.shimko@gmail.com>

RUN groupadd -r node && useradd -m -g node node

# Gosu
ENV GOSU_VERSION 1.10

# PhantomJS
ENV PHANTOM_VERSION 2.1.1

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV APP_BUNDLE_DIR /opt/meteor/dist
ENV BUILD_SCRIPTS_DIR /opt/build_scripts

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
RUN chmod -R 750 $BUILD_SCRIPTS_DIR

ARG INSTALL_PASSENGER
ENV INSTALL_PASSENGER ${INSTALL_PASSENGER:-true}

ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-4.8.4}

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

#RUN cd $APP_SOURCE_DIR && \
#  $BUILD_SCRIPTS_DIR/install-node.sh
#
#RUN cd $APP_SOURCE_DIR && \
#  $BUILD_SCRIPTS_DIR/install-phantom.sh 
#
#RUN cd $APP_SOURCE_DIR && \
#  $BUILD_SCRIPTS_DIR/install-graphicsmagick.sh 
#
#RUN cd $APP_SOURCE_DIR && \
#  $BUILD_SCRIPTS_DIR/install-graphicsmagick.sh
#
#RUN cd $APP_SOURCE_DIR && \
#  $BUILD_SCRIPTS_DIR/install-meteor.sh
#
#RUN cd $APP_SOURCE_DIR && \
#  $BUILD_SCRIPTS_DIR/install-passenger.sh
#
#ONBUILD COPY . $APP_SOURCE_DIR
#  $BUILD_SCRIPTS_DIR/install-deps.sh
#
#ONBUILD RUN cd $APP_SOURCE_DIR && \
#  $BUILD_SCRIPTS_DIR/build-meteor.sh
#
## start the app
#WORKDIR $APP_BUNDLE_DIR/bundle
#CMD ["passenger", "start", "--app-type", "node", "--startup-file", "main.js"]
#
##WORKDIR $APP_BUNDLE_DIR/bundle
##ENTRYPOINT ["./entrypoint.sh"]
##CMD ["node", "main.js"]
