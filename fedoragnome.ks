# version=F33
# Reference https://docs.fedoraproject.org/en-US/fedora/rawhide/install-guide/appendixes/Kickstart_Syntax_Reference
# Warning.  This will wipe all data.  It will wipe the first disk, but could potentially wipe all data on all disks.
# URLs and REPOs
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-33&arch=x86_64"
repo --name=fedora-updates --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f33&arch=x86_64" --cost=0
# RPMFusion Free
repo --name=rpmfusion-free --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-33&arch=x86_64" --includepkgs=rpmfusion-free-release
repo --name=rpmfusion-free-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-33&arch=x86_64" --cost=0
repo --name=rpmfusion-free-tainted --mirrorlist="https://mirrors.rpmfusion.org/metalink?repo=free-fedora-tainted-33&arch=x86_64"
# RPMFusion NonFree
repo --name=rpmfusion-nonfree --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-33&arch=x86_64" --includepkgs=rpmfusion-nonfree-release
repo --name=rpmfusion-nonfree-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-33&arch=x86_64" --cost=0
repo --name=rpmfusion-nonfree-tainted --mirrorlist="https://mirrors.rpmfusion.org/metalink?repo=nonfree-fedora-tainted-33&arch=x86_64"
# Google Chrome
repo --name google-chrome --install --baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64

# Use text install
text

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate
network  --hostname=localhost.localdomain

# Run the Setup Agent on first boot
firstboot --enable

# Only use first disk
ignoredisk --only-use=sda

# Automatic partitioning  -  creates two subvolumes: root home
autopart --encrypted

# Partition clearing information
clearpart --all --initlabel
zerombr
# SELinux
selinux --permissive

# System timezone
timezone America/Indiana/Indianapolis --utc

# System services
services --enabled=chronyd,sshd

# Lock Root
rootpw --lock

# User fedora with password fedoraworkstation
user --name=fedora --password=fedoraworkstation --plaintext --groups=wheel

# Configure X Window System
xconfig --defaultdesktop=GNOME --startxonboot


# Package groups to install
# Listed on fedora workstation with: sudo dnf group list -v hidden
   Common NetworkManager Submodules
%packages
@^workstation-product-environment
@workstation-product
@admin-tools
@base-x
@basic-desktop
@core
@development-tools
-@dial-up
@editors
@firefox
@fonts
@guest-desktop-agents
@hardware-support
@java
@libreoffice
@multimedia
@networkmanager-submodules
@office
@printing
@gnome-desktop
@Sound and Video
@system-tools
alacarte
audacity
autoconf
autofs
automake
backintime-qt
baobab
bijiben
-biosdevname
blivet-gui
borgbackup
cachefilesd
chromium-freeworld
# necessary for nm-connection-editor
dbus-x11
distribution-gpg-keys
dnf-automatic
dnf-plugin-system-upgrade
# Network-Monitoring
etherape
evince
evolution
exfat-utils
fdupes
fedora-release-workstation
firefox
ffmpeg
flatpak
freerdp
gedit
git-all
gnome-calendar
gnome-clocks
gnome-contacts
gnome-firmware
gnome-maps
gnome-online-accounts
gnome-terminal
gnome-todo
gnome-tweaks
gnome-usage
gnome-weather
gparted
gthumb
htop
icedtea-web
iftop
java-openjdk
langpacks-en
NetworkManager-*
nmap
syncthing
transmission
vim-enhanced
vlc
%end

%addon com_redhat_kdump --disable --reserve-mb='128'
%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

%post
# Repositories
dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
%end

# Post-installation Script
%post
# Disable IPv6
cat <<EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
#Enable GPG key for Google
cat <<EOF >> /etc/yum.repos.d/google-chrome.repo
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF
echo "fedora   ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers.d/fedora
%end

# Reboot After Installation
reboot

