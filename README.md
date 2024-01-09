# win10box: create a useable Windows 10 Vagrant box with compiler and Python

Testing Python code on Windows is an unspeakably time consuming task for
someone accustomed to work on open-source OSes. Annoying surprises everywhere:
from the Windows installation which requires you to open an account at
Microsoft, to the fact that you cannot download older versions of Microsoft's
compilers without registering. How do you install stuff without using the
graphical installers? What is the equivalent of `top` on the Windows command
line? Why can't you SSH into your admin account in the VM even though it works
for a normal account? Why does Vagrant always hang when it is connecting to the
VM with `winrm`? Why isn't it possible to clone a git repository containing a
directory `aux`? Don't believe it? Try for yourself!

This repository provides scripts and configuration to set up a
[Vagrant](https://www.vagrantup.com/) box with Windows, Python, Conda, and
working C compiler (MSVC).

Now you can halfway enjoy your day again and test your stuff on Windows with
just a few commands (output omitted):

```
linuxbox$ vagrant import win10.box --name win10`
linuxbox$ vagrant up
linuxbox$ vagrant ssh
vagrant@MSEDGEWIN10 C:\Users\IEUser>conda activate
(base) vagrant@MSEDGEWIN10 C:\Users\IEUser>git clone https://git.pyrocko.org/pyrocko/pyrocko.git
(base) vagrant@MSEDGEWIN10 C:\Users\IEUser>cd pyrocko
(base) vagrant@MSEDGEWIN10 C:\Users\IEUser\pyrocko>conda install numpy scipy matplotlib pyqt pyyaml progressbar2 requests jinja2 nose
(base) vagrant@MSEDGEWIN10 C:\Users\IEUser\pyrocko>python setup.py install
```

This repository provides scripts to configure and package a Vagrant box
`win10.box` for VirtualBox with

- Windows 10 guest OS
- Based on [Edge Test VM from MS](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/) with 90 day trial license
- Working Vagrant SSH access

Additionally, the directory `vagrant` contains

- Workaround to fix winrm connection problems
- Provisioning script to install
  - Visual Studio Build Tools 2017 (update 9) MSBuildTools and VCTools
  - Miniconda3

## Warning

Do not use the information gathered in this repository to advertise the use of
closed-source operating systems. **This is a temporary fallback to help you out
if you must support those pitiable users of your code who are imprisoned in
their Windows machines by whatever gruesome reasons.**

## Requirements

- `sudo apt install vagrant vinagre virtualbox`
- Enough free disk space on `$HOME` and where `VirtualBox VMs` live > 40 GB.
- Port 5940 should be free.

## Overview

The whole process includes the following steps:

- (1) We get the VirtualBox VM image straight from Microsoft.
- (2) Then we configure the VM so that it cannot access the internet in order
  to prevent activation and start of the 90 day trial period (like this the
  trial period starts anew after each `vagrant destroy ; vagrant up` later).
- (3) Start the VM with plain VirtualBox (no Vagrant).
- (4) Now we unfortunately have to interactively call a configuration script
  via the Windows GUI. This script will enable SSH and rename user account to
  `vagrant`.
- (5) Shutdown VM.
- (6) Package vagrant box for distribution.
- (7) Cleanup
- (8) (Somewhere else) The created box can now be imported into Vagrant.
- (9) Use the provided Vagrantfile to get around the winrm connection issues
  and further provision the box.

## Step by step

- (1) - (2) are carried out by running `./prepare.sh create`
- (2b) optionally grow the disk image to 100 GB with ./prepare.sh grow. If
  done, also grow the partition from within Windows with 'Disk Manager' when 
  machine is running for performing (4) - (5).
- (4) - (5)
  - Connect to the machine via RDP with `vinagre`, connect to `localhost` port
    `5940`. Screen size to 1024 x 768. Password is `Passw0rd!`
  - Right-click and run as administrator `z:\prepare.bat`, hit any key 2 times.
  - Shut down the VM with the Windows menu.
- (6) run `./prepare.sh package` this will create the precious `win10.box`
  which can be copied to other machines.
- (7) run `./prepare.sh cleanup`
- (8) run `vagrant box add win10.box --name win10`
- (9) put in place `Vagrantfile` and `provision.bat` and run `vagrant up`. This
  will start the machine, install VisualStudio Build Tools and Miniconda3, and
  activate the 90 day trial period of the Windows.
- Now login with `vagrant ssh`, run `conda activate` and you have git and conda
  and can compile Python C extensions.
- You can check the remaining days available on the Windows trial license with
  `cscript C:\Windows\System32\slmgr.vbs /dli`. Maybe it is possible to extend
  the period once by running one of the `slmgr` subcommands (can't remember
  which one).

## Good to know

- This post on [How to setup a Windows VM...](https://beenje.github.io/blog/posts/how-to-setup-a-windows-vm-to-build-conda-packages)
  helped for the initial setup.
- It is important to install the old 2017 version of *Build Tools for Visual
  Studio* if you want to build Python packages for Conda.
- You can configure VirtualBox to either provide RDP or VNC, use `vinagre` as
  client on Linux.
- Get vim on Windows
  ```
  conda install m2-libiconv m2-libintl m2-vim
  curl https://data.pyrocko.org/scratch/vimrc_minimal -o .vimrc
  setx HOME "%USERPROFILE%"   # needed so that vim finds its vimrc :-0
  # open new cmd
  ```
- `rm -rf`: `rmdir /s /q`
- `kill -9`: `taskkill /f /pid`
- `ps`: `tasklist`
- `cp -r`: `xcopy`
- `top`: (powershell) `While(1) {ps | sort -des cpu | select -f 15 | ft -a; sleep 1; cls}`
- Mount a guest disk image (VMDK) under Linux:
  ```
  guestmount -v -a "Win10-disk001.vmdk" -m /dev/sda1 --rw mnt
  guestunmount mnt
  ```
- List disk images `vboxmanage list hdds`
- Remove disk images `vboxmanage closemedium disk <uuid> --delete`
