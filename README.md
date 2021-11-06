# win10box: create a useable Windows 10 Vagrant box with compiler and python

This repository provides scripts to configure and package a Vagrant box
`win10.box` for VirtualBox with

- Windows 10 guest OS
- Based on Edge Test VM from MS with 90 day trial license
- Working Vagrant SSH access

The directory `vagrant` contains a `Vagrantfile` with

- Workaround to fix winrm connection problems
- Provisioning script to install
  - Visual Studio Build Tools 2017 (update 9) MSBuildTools and VCTools
  - Miniconda

## Requirements

- `sudo apt install vagrant vinagre virtualbox`
- Enough free disk space on `$HOME` and where `VirtualBox VMs` live > 40 GB.
- Port 5940 should be free.

## Overview

The whole process includes the following steps:

- (1) We get the VirtualBox VM image staight from Microsoft.
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
- (3) is done by running `./prepare.sh start`
- (4) - (5)
  - Connect to the machine via RDP with `vinagre`, connect to `localhost` port
    `5940`. Screen size to 1024 x 768. Password is `Passw0rd!`
  - Right-click and run as administrator `z:\prepare.bat` hit any key 2 times.
  - Shut down the VM with the Windows menu.
- (6) run `./prepare.sh package` this will create the precious `win10.box` which
  can be copied to other machines.
- (7) run `./prepare.sh cleanup`
- (8) run `vagrant import win10.box --name win10`
- (9) put in place `Vagrantfile` and `provision.bat` and run `vagrant up`
- Now login with `vagrant ssh`, run `conda activate` and you gave git and
  conda and can compile Python C extensions.
