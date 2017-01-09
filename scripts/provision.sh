#!/bin/bash

# create vagrant user
useradd vagrant

# set vagrant user's password
echo "vagrant:vagrant" | chpasswd

# create vagrant user's home directory and .ssh directory
mkdir -p /home/vagrant/.ssh

# chown home folder and .ssh folder to vagrant user
chown -R vagrant:vagrant /home/vagrant/

# change .ssh dir to 700 permissions
chmod 700 /home/vagrant/.ssh

# add vagrant's default insecure public key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" >> /home/vagrant/.ssh/authorized_keys

# change permissions on authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys

# change ownership on authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

# pacman
pacm-db-upgrade
sync
if [[ $(uname -m) == "x86_64" ]]; then
    sed -i '/\[multilib\]/{N;d}' /etc/pacman.conf
    cat >> "/etc/pacman.conf" <<EOF
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    echo -e '\ny\ny\n' | pacman -S multilib-devel && echo -e '\r'
fi

# yaourt
if ! grep -q "\[archlinuxfr\]" /etc/pacman.conf; then
    cat >> "/etc/pacman.conf" <<EOF
[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/\$arch
EOF
fi

pacman -Syu --noconfirm --needed \
	linux-grsec linux-grsec-headers \
	sudo git gdb rsync unzip vim wget yaourt \
	bzr dnsutils inetutils ltrace strace mercurial net-tools openvpn \
	proxychains-ng \
	python python2 python-pip python2-pip ruby subversion \
	tcpdump tor \
	adobe-source-code-pro-fonts adobe-source-sans-pro-fonts \
	ttf-inconsolata \
	firefox fontforge geany mate openbox python-numpy pyxdg rdesktop \
	x11vnc xorg xterm lxterminal network-manager-applet \
	networkmanager slim slim-themes
sudo -u vagrant /usr/bin/yaourt -S --noconfirm zsh otf-takao ttf-ms-fonts
sync

systemctl enable slim.service

# add vagrant user to sudoers list
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant

# # install virtualbox guest additions
# pacman -S virtualbox-guest-modules-arch virtualbox-guest-utils-nox --noconfirm
pacman -S virtualbox-guest-utils-nox --noconfirm

# # load virtualbox guest addition modules
# printf "vboxguest\nvboxsf\nvboxvideo\n" > /etc/modules-load.d/virtualbox.conf
systemctl enable vboxservice

# 
su - vagrant -c "\
git clone https://github.com/ac1965/vagrant-dotfiles.git --recursive && \
	cd vagrant-dotfiles && ./setup.sh
"
