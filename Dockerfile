FROM phusion/passenger-nodejs
MAINTAINER Gary Leong <gwleong@gmail.com>

###########################
#Originally from
#FROM debian:jessie
#MAINTAINER Jeremy Shimko <jeremy.shimko@gmail.com>
###########################

#RUN useradd -m -G users -s /bin/bash meteor
RUN groupadd -r meteor && useradd -m -g meteor meteor

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV BUILD_SCRIPTS_DIR /opt/build_scripts

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
RUN chmod -R 750 $BUILD_SCRIPTS_DIR

ONBUILD ARG NODE_VERSION
ONBUILD ENV NODE_VERSION ${NODE_VERSION:-4.8.4}

# Node flags for the Meteor build tool
ONBUILD ARG TOOL_NODE_FLAGS
ONBUILD ENV TOOL_NODE_FLAGS $TOOL_NODE_FLAGS

# install all dependencies, build app, clean up
ONBUILD RUN cd $APP_SOURCE_DIR && \
               $BUILD_SCRIPTS_DIR/install-node.sh && \
               $BUILD_SCRIPTS_DIR/install-meteor.sh

# We call the "meteor" command for the first time which will install the Meteor binaries in ~/.meteor.
ONBUILD USER meteor
ONBUILD RUN cd /tmp && meteor --version

ONBUILD USER root
ONBUILD RUN mkdir -p /home/meteor && \
            mkdir -p /usr/src/app && \
            chown -R meteor:meteor /home/meteor && \
            chown -R meteor:meteor /usr/src/app
