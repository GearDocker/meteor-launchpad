#!/bin/bash

#This is a hacked version of meteor script since we want to work with tarballs
#since downloading the tar balls was a problem with meteor and we are installing 
#a docker container

run_it () {

# This always does a clean install of the latest version of Meteor into your
# ~/.meteor, replacing whatever is already there. (~/.meteor is only a cache of
# packages and package metadata; no personal persistent data is stored there.)

RELEASE="1.5"
PLATFORM="os.linux.x86_64"
PREFIX="/usr/local"

set -e
set -u

# Let's display everything on stderr.
exec 1>&2

if [ -z $HOME ] || [ ! -d $HOME ]; then
  echo "The installation and use of Meteor requires the \$HOME environment variable be set to a directory where its files can be installed."
  exit 1
fi

# If you already have a tropohouse/warehouse, we do a clean install here:
if [ -e "$HOME/.meteor" ]; then
  echo "Removing your existing Meteor installation."
  rm -rf "$HOME/.meteor"
fi

INSTALL_TMPDIR="$HOME/.meteor-install-tmp"
TARBALL_FILE="$HOME/.meteor-tarball-tmp"

###########################################
## This is for downloading the tarball file. 
## We have already predownloaded
###########################################
#
#TARBALL_URL="https://static-meteor.netdna-ssl.com/packages-bootstrap/${RELEASE}/meteor-bootstrap-${PLATFORM}.tar.gz"
#
#cleanUp() {
#  rm -rf "$TARBALL_FILE"
#  rm -rf "$INSTALL_TMPDIR"
#}
#
#mkdir "$INSTALL_TMPDIR"
#
#VERBOSITY="--progress-bar"
##VERBOSITY="--silent";
#
#while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]
#do
#  ATTEMPTS=$((ATTEMPTS + 1))
#
#  curl $VERBOSITY --fail --continue-at - \
#    "$TARBALL_URL" --output "$TARBALL_FILE"
#
#  if [ $? -eq 0 ]
#  then
#      break
#  fi
#
#  echo "Retrying download in $RETRY_DELAY_SECS seconds..."
#  sleep $RETRY_DELAY_SECS
#done
#
###########################################
## END
###########################################

set -e

# bomb out if it didn't work, eg no net
test -e "${TARBALL_FILE}"
tar -xzf "$TARBALL_FILE" -C "$INSTALL_TMPDIR" -o

test -x "${INSTALL_TMPDIR}/.meteor/meteor"
mv "${INSTALL_TMPDIR}/.meteor" "$HOME"
# just double-checking :)
test -x "$HOME/.meteor/meteor"

# The `trap cleanUp EXIT` line above won't actually fire after the exec
# call below, so call cleanUp manually.
cleanUp

echo
echo "Meteor ${RELEASE} has been installed in your home directory (~/.meteor)."

METEOR_SYMLINK_TARGET="$(readlink "$HOME/.meteor/meteor")"
METEOR_TOOL_DIRECTORY="$(dirname "$METEOR_SYMLINK_TARGET")"
LAUNCHER="$HOME/.meteor/$METEOR_TOOL_DIRECTORY/scripts/admin/launch-meteor"

if cp "$LAUNCHER" "$PREFIX/bin/meteor" >/dev/null 2>&1; then
  echo "Writing a launcher script to $PREFIX/bin/meteor for your convenience."
  cat <<"EOF"

To get started fast:

  $ meteor create ~/my_cool_app
  $ cd ~/my_cool_app
  $ meteor

Or see the docs at:

  docs.meteor.com

EOF
elif type sudo >/dev/null 2>&1; then
  echo "Writing a launcher script to $PREFIX/bin/meteor for your convenience."
  echo "This may prompt for your password."

  # New macs (10.9+) don't ship with /usr/local, however it is still in
  # the default PATH. We still install there, we just need to create the
  # directory first.
  # XXX this means that we can run sudo too many times. we should never
  #     run it more than once if it fails the first time
  if [ ! -d "$PREFIX/bin" ] ; then
      sudo mkdir -m 755 "$PREFIX" || true
      sudo mkdir -m 755 "$PREFIX/bin" || true
  fi

  if sudo cp "$LAUNCHER" "$PREFIX/bin/meteor"; then
    cat <<"EOF"

To get started fast:

  $ meteor create ~/my_cool_app
  $ cd ~/my_cool_app
  $ meteor

Or see the docs at:

  docs.meteor.com

EOF
  else
    cat <<EOF

Couldn't write the launcher script. Please either:

  (1) Run the following as root:
        cp "$LAUNCHER" /usr/bin/meteor
  (2) Add "\$HOME/.meteor" to your path, or
  (3) Rerun this command to try again.

Then to get started, take a look at 'meteor --help' or see the docs at
docs.meteor.com.
EOF
  fi
else
  cat <<EOF

Now you need to do one of the following:

  (1) Add "\$HOME/.meteor" to your path, or
  (2) Run this command as root:
        cp "$LAUNCHER" /usr/bin/meteor

Then to get started, take a look at 'meteor --help' or see the docs at
docs.meteor.com.
EOF
fi


trap - EXIT
}

run_it

######################################################
## Original
######################################################
#set -e
#
#if [ "$DEV_BUILD" = true ]; then
#  # if this is a devbuild, we don't have an app to check the .meteor/release file yet,
#  # so just install the latest version of Meteor
#  printf "\n[-] Installing the latest version of Meteor...\n\n"
#  curl -v https://install.meteor.com/ | sh
#else
#  # download installer script
#  curl -v https://install.meteor.com -o /tmp/install_meteor.sh
#
#  # read in the release version in the app
#  METEOR_VERSION=$(head $APP_SOURCE_DIR/.meteor/release | cut -d "@" -f 2)
#
#  # set the release version in the install script
#  sed -i.bak "s/RELEASE=.*/RELEASE=\"$METEOR_VERSION\"/g" /tmp/install_meteor.sh
#
#  # replace tar command with bsdtar in the install script (bsdtar -xf "$TARBALL_FILE" -C "$INSTALL_TMPDIR")
#  # https://github.com/jshimko/meteor-launchpad/issues/39
#  sed -i.bak "s/tar -xzf.*/bsdtar -xf \"\$TARBALL_FILE\" -C \"\$INSTALL_TMPDIR\"/g" /tmp/install_meteor.sh
#
#  # install
#  printf "\n[-] Installing Meteor $METEOR_VERSION...\n\n"
#  sh /tmp/install_meteor.sh
#fi
#
#
