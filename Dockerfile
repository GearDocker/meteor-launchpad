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

# install all dependencies, build app, clean up
RUN mkdir -p $APP_SOURCE_DIR && \
    cd $APP_SOURCE_DIR && \
    $BUILD_SCRIPTS_DIR/install-meteor.sh

# We call the "meteor" command for the first time which will install the Meteor binaries in ~/.meteor.
USER meteor
RUN cd /tmp && meteor --version

USER root
RUN mkdir -p /home/meteor && \
    mkdir -p /usr/src/app && \
    chown -R meteor:meteor /home/meteor && \
    chown -R meteor:meteor /usr/src/app
