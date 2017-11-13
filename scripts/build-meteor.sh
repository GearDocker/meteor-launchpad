#!/bin/bash

#
# builds a production meteor bundle directory
#
set -e

# set up npm auth token if one is provided
if [[ "$NPM_TOKEN" ]]; then
  echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >> ~/.npmrc
fi

# Fix permissions warning in Meteor >=1.4.2.1 without breaking
# earlier versions of Meteor with --unsafe-perm or --allow-superuser
# https://github.com/meteor/meteor/issues/7959
export METEOR_ALLOW_SUPERUSER=true

cd $APP_SOURCE_DIR

printf "\n[-] Resetting meteor ...\n\n"
meteor reset --allow-superuser

# Install app deps
printf "\n[-] Show the meteror version number ...\n\n"
VERSION=`meteor --version --allow-superuser`
echo "Meteror version is $VERSION"
sleep 4

# Install app deps
printf "\n[-] Running npm install --allow-superuser in app directory at $APP_BUNDLE_DIR ...\n\n"
meteor npm install --allow-superuser

# build the bundle
printf "\n[-] Building Meteor application as --allow-superuser at $APP_BUNDLE_DIR ...\n\n"
mkdir -p $APP_BUNDLE_DIR
meteor build --directory $APP_BUNDLE_DIR --server-only --allow-superuser

# run npm install in bundle
printf "\n[-] Running npm install --allow-superuser in the server bundle at $APP_BUNDLE_DIR/bundle/programs/server/ ...\n\n"
cd $APP_BUNDLE_DIR/bundle/programs/server/
meteor npm install --production --allow-superuser

#Create public and tmp directory 
#needed for container runners like passenger
cd $APP_BUNDLE_DIR/bundle

for DIRECTORY in public tmp
do
  if [ ! -d "$DIRECTORY" ]; then
        printf "\n[-] Making directory $APP_BUNDLE_DIR/$DIRECTORY/bundle ...\n\n"
        mkdir $DIRECTORY
  fi
done

cd -

# put the entrypoint script in WORKDIR
mv $BUILD_SCRIPTS_DIR/entrypoint.sh $APP_BUNDLE_DIR/bundle/entrypoint.sh

# change ownership of the app to the node user
chown -R node:node $APP_BUNDLE_DIR
