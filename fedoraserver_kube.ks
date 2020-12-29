# version=F33
# Reference https://docs.fedoraproject.org/en-US/fedora/rawhide/install-guide/appendixes/Kickstart_Syntax_Reference
# Warning.  This will wipe all data.  It will wipe the first disk, but could potentially wipe all data on all disks.
# URLs and REPOs
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-33&arch=x86_64"
repo --name=fedora-updates --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f33&arch=x86_64" --cost=0

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
ignoredisk --only-use=sda,sdb

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
%packages
@^server-product-environment
-@dial-up
@hardware-support
dnf-automatic
dnf-plugin-system-upgrade
nmap
vim
vim-enhanced
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
# Get icon theme
mkdir ~/.icons
cd ~/.icons
git clone https://github.com/keeferrourke/la-capitaine-icon-theme.git
# OR install via copr rep, but less repos are better
#sudo dnf copr enable tcg/themes
#sudo dnf install la-capitaine-icon-theme
# Get some fonts
mkdir ~/tmp
wget -O ~/Downloads/font-archive.zip http://fonts.google.com/download\?family=Ubuntu
nzip "font-archive.zip" -d ~/tmp
sudo cp '~/tmp/*.ttf /usr/share/fonts/'
fc-cache -f -v
# Enable multimedia playback with gstreamer
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate sound-and-video
# Install TLP for optimizing laptop battery
sudo dnf install tlp tlp-rdw
sudo systemctl enable tlp
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
echo "
echo "fastestmirror=true" >> /etc/dnf/dnf.conf
echo "deltarpm=true" >> /etc/dnf/dnf.conf
#
%end

# Reboot After Installation
reboot
