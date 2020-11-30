#version=F33
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

# Generated using Blivet version 3.3.0
ignoredisk --only-use=sda
autopart --encrypted
# Partition clearing information
clearpart --all --initlabel

# SELinux
selinux --permissive

# System timezone
timezone America/Indiana/Indianapolis --utc

# System services
services --enabled=chronyd,sshd

#Root password
rootpw --lock

# Package groups to install
%packages
@^workstation-product-environment
@admin-tools
@core
@development-tools
@editors
@libreoffice
@office
@sound-and-video
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
filezilla
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
%end

# Reboot After Installation
reboot

