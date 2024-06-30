#!/bin/bash

#
# This script is for Gentoo Linux to configure XRDP for enhanced session mode
#

if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run with root privileges' >&2
    exit 1
fi

# Check if xrdp is installed
if ! emerge --search xrdp > /dev/null ; then
    echo 'xrdp not installed. Install xrdp using emerge.' >&2
    exit 1
fi

# Check if xorgxrdp is installed
if ! emerge --search xorgxrdp > /dev/null ; then
    echo 'xorgxrdp not installed. Install xorgxrdp using emerge.' >&2
    exit 1
fi

###############################################################################
# Configure XRDP
#
rc-update add xrdp default
rc-update add xrdp-sesman default

# Start services immediately
/etc/init.d/xrdp start
/etc/init.d/xrdp-sesman start

# Configure the installed XRDP ini files.
# use vsock transport.
sed -i_orig -e 's/port=3389/port=vsock:\/\/-1:3389/g' /etc/xrdp/xrdp.ini
# use rdp security.
sed -i_orig -e 's/security_layer=negotiate/security_layer=rdp/g' /etc/xrdp/xrdp.ini
# remove encryption validation.
sed -i_orig -e 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini
# disable bitmap compression since its local its much faster
sed -i_orig -e 's/bitmap_compression=true/bitmap_compression=false/g' /etc/xrdp/xrdp.ini
#
# sed -n -e 's/max_bpp=32/max_bpp=24/g' /etc/xrdp/xrdp.ini

# use the default lightdm x display
# sed -i_orig -e 's/X11DisplayOffset=10/X11DisplayOffset=0/g' /etc/xrdp/sesman.ini
# rename the redirected drives to 'shared-drives'
sed -i_orig -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini

# Change the allowed_users
echo "allowed_users=anybody" > /etc/X11/Xwrapper.config


# Ensure hv_sock gets loaded
if [ ! -e /etc/modules-load.d/hv_sock.conf ]; then
    echo "hv_sock" > /etc/modules-load.d/hv_sock.conf
fi

# Configure the policy xrdp session
cat > /etc/polkit-1/rules.d/02-allow-colord.rules <<EOF
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.color-manager.create-device" ||
         action.id == "org.freedesktop.color-manager.modify-profile" ||
         action.id == "org.freedesktop.color-manager.delete-device" ||
         action.id == "org.freedesktop.color-manager.create-profile" ||
         action.id == "org.freedesktop.color-manager.modify-profile" ||
         action.id == "org.freedesktop.color-manager.delete-profile") &&
        subject.isInGroup("users"))
    {
        return polkit.Result.YES;
    }
});
EOF

# Adapt the xrdp pam config
cat > /etc/pam.d/xrdp-sesman <<EOF
#%PAM-1.0
auth        include     system-remote-login
account     include     system-remote-login
password    include     system-remote-login
session     include     system-remote-login
EOF


###############################################################################
# .xinitrc has to be modified manually.
#
echo "You will have to configure .xinitrc to start your windows manager, see https://wiki.gentoo.org/wiki/Xinitrc"
echo "Reboot your machine to begin using XRDP."
