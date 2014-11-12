#!/bin/sh

# BEGIN - Change Variables for Platform, Architecture & Source Code Version
BUILD_ARCHITECTURE="x86"
ARCHIVE_NAME="zlib-1.2.8"
SRC_ARCHIVE="$ARCHIVE_NAME.tar.gz"
# END - Change Variables for Platform, Architecture & Source Code Version

# Directory Variables
BUILD_ENV_DIR="BuildEnvironments/$BUILD_ARCHITECTURE/sys-root"
APP_PREFIX="zlib"
SRC_TAR_ROOT="$ARCHIVE_NAME"
SRC_DIR="appSrc/$APP_PREFIX"
BUILD_DIR="appBuild/$APP_PREFIX"
QPKG_DIR="package"
QPKG_ENV="$QPKG_DIR/$BUILD_ARCHITECTURE"
QPKG_CONFIG="$QPKG_ENV/config"
QPKG_BUILD="$QPKG_DIR/build"

# Get the Script's Current Directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
PACKAGE_ROOT="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
PACKAGE_PARENT="$(dirname "$PACKAGE_ROOT")"

# Clean any Existing Source Code & Installed Binaries
rm -rf $PACKAGE_PARENT/$BUILD_ENV_DIR/$SRC_DIR
rm -rf $PACKAGE_PARENT/$BUILD_ENV_DIR/$BUILD_DIR

# Extract Source Code Archive
mkdir -p $PACKAGE_PARENT/$BUILD_ENV_DIR/$SRC_DIR
tar -xf $SRC_ARCHIVE -C $PACKAGE_PARENT/$BUILD_ENV_DIR/$SRC_DIR

# Clean, Build & Install the Source Code
chroot $PACKAGE_PARENT/$BUILD_ENV_DIR bash -c "cd /$SRC_DIR/$ARCHIVE_NAME && ./configure && make test && make install prefix=/$BUILD_DIR"

# Clean the QDK Package Environment
rm -rf $PACKAGE_ROOT/$QPKG_ENV/*
rm -rf $PACKAGE_ROOT/$QPKG_BUILD/

# Copy the Installed Binaries to the QDK Package Environment
cp -r $PACKAGE_PARENT/$BUILD_ENV_DIR/$BUILD_DIR/* $PACKAGE_ROOT/$QPKG_ENV

# Build the QPKG File
qbuild --root $PACKAGE_ROOT/$QPKG_DIR
