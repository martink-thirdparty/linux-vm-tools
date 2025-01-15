#!/bin/bash

#
# This script is for Gentoo Linux to download and install XRDP and XORGXRDP
#

if [ "$(id -u)" -eq 0 ]; then
    echo 'This script must be run as a non-root user, as building packages as root is unsupported.' >&2
    exit 1
fi

###############################################################################
# Prepare by installing build tools.
#
sudo emerge --sync
sudo emerge --update --newuse --deep @world
sudo emerge --ask app-portage/gentoolkit dev-vcs/git

# Create a build directory in tmpfs
TMPDIR=$(mktemp -d)
pushd "$TMPDIR" || exit

###############################################################################
# XRDP
#
(
    git clone https://github.com/neutrinolabs/xrdp.git
    cd xrdp || exit
    ./bootstrap
    ./configure
    make
    sudo make install
)
###############################################################################
# XORGXRDP
# Devel version, because release version includes a bug crashing gnome-settings-daemon
(
    git clone https://github.com/neutrinolabs/xorgxrdp.git
    cd xorgxrdp || exit
    ./bootstrap
    ./configure
    make
    sudo make install
)
###############################################################################

# Remove build directory
rm -rf "$TMPDIR"

echo "Installation complete. Please configure XRDP as needed."
