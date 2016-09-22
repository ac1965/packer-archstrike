Packer ArchStrike Minimal
=========================

This repository contains a packer configuration, install script, and provisioning script that together are capable of building a minimal ArchStrike vagrant box.

Features
--------

I had simplicity in mind when creating this box. It has the following features.
- 64-bit
- Up to date as of September 3rd, 2016
- All space on / partition
- No Swap
- Includes base and base-devel package groups
- OpenSSH installed and running
- VirtualBox Guest Additions installed
- Instructions to set up the repository

Build instructions
------------------
~~~
$ git clone https://github.com/ac1965/packer-archstrike.git
$ cd archstrike-vm/vagrant
$ make
~~~

Resources used to create this
-----------------------------
- https://github.com/ChrisOrlando/packer-archlinux-minimal
- https://archstrike.org/wiki/setup

