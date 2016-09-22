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
if [[ $(uname -m) == "x86_64" ]]; then
    sed -i '/\[multilib\]/{N;d}' /etc/pacman.conf
    cat >> "/etc/pacman.conf" <<EOF
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
fi

# yaourt
if ! grep -q "\[archlinuxfr\]" /etc/pacman.conf; then
    cat >> "/etc/pacman.conf" <<EOF
[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/\$arch
EOF
fi

pacman-db-upgrade
sync
pacman -Syu --noconfirm --needed sudo git gdb python rsync unzip vim yaourt
echo -e '\ny\ny\n' | pacman -S multilib-devel && echo -e '\r'
sudo -u vagrant /usr/bin/yaourt -S --noconfirm zsh
sync

# add vagrant user to sudoers list
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant

# install virtualbox guest additions
pacman -S virtualbox-guest-modules-arch virtualbox-guest-utils-nox --noconfirm

# load virtualbox guest addition modules
printf "vboxguest\nvboxsf\nvboxvideo\n" > /etc/modules-load.d/virtualbox.conf
