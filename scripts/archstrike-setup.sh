#!/bin/bash

set -e

# 1. Setup the master ArchStrike repository mirror
if ! grep -q "\[archstrike\]" /etc/pacman.conf; then
    cat >> "/etc/pacman.conf" <<EOF
[archstrike]
Server = https://mirror.archstrike.org/\$arch/\$repo
EOF
fi
if ! grep -q "\[archstrike-testing\]" /etc/pacman.conf; then
    cat >> "/etc/pacman.conf" <<EOF
[archstrike-testing]
Server = https://mirror.archstrike.org/\$arch/\$repo
EOF
fi
pacman -Syy

# 2. Bootstrap and install the ArchStrike keyring
pacman-key --init
dirmngr < /dev/null
pacman-key -r 9D5F1C051D146843CDA4858BDE64825E7CBC0D51 && pacman-key --lsign-key 9D5F1C051D146843CDA4858BDE64825E7CBC0D51

# 3. Install required packages
pacman -S archstrike-keyring --noconfirm
pacman -S archstrike-mirrorlist --noconfirm

# 4. Configure pacman to use the mirrorlist
if grep -q "\[archstrike\]" /etc/pacman.conf; then
    sed -i '/archstrike/{N;d}' /etc/pacman.conf
    cat >> "/etc/pacman.conf" <<EOF
[archstrike]
Include = /etc/pacman.d/archstrike-mirrorlist
EOF
fi
if grep -q "\[archstrike-testing\]" /etc/pacman.conf; then
    sed -i '/archstrike-testing/{N;d}' /etc/pacman.conf
    cat >> "/etc/pacman.conf" <<EOF
[archstrike-testing]
Include = /etc/pacman.d/archstrike-mirrorlist
EOF
fi
pacman -Syy

pacman -Rdd --noconfirm cryptsetup
# A feeling of fondness :p
# pacman -Syu --noconfrim archstrike

/usr/bin/paccache -rk0
/usr/bin/pacman -Scc --noconfirm
rm /tmp/yaourt-* -Rf
