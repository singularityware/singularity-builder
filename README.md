# Singularity Builder 
[![Build Status](https://travis-ci.org/ArangoGutierrez/singularity-builder.svg?branch=master)](https://travis-ci.org/ArangoGutierrez/singularity-builder)

build, install, and update Singularity software. 
Support for Debian/Ubuntu, Centos/Fedora

## USAGE: 
```
./singularity_build.sh <command> [options] ...
```

## COMMANDS:
	- all		setup, build, and install [sudo]
	- setup		install dependencies for your distribution [sudo]
	- build		configure and make the installation, with optional --prefix
	- install	make, and make install [sudo]
	- update	[sudo]
### Options:
	- --prefix=/my/path Set a PATH for Install different from default /usr/local
## DEVELOPMENT:
	- install-devel: 	equivalent to install, but using development branch 
	- update-devel  	equivalent to update, but using development branch

## Examples:

- Install dependencies, setup, build + install
```bash
 $ sudo ./singularity_build.sh all
```
- Build + optional prefix
```bash
$ sudo ./singularity_build.sh build --prefix=/my/path
```
- If you already have the needed dependencies, just install
```bash
  $ sudo ./singularity_build.sh install
```
- Update to the latest release
```bash
 sudo ./singularity_build.sh update
```

Singularity: Application containers for Linux
For additional help, see http://singularity.lbl.gov/

## cloud platforms

With this [packer](https://www.packer.io/docs/command-line/build.html) configuration you can generate build instances (images) on different cloud platforms. 


	packer build builder.json 
	googlecompute output will be in this color.

	==> googlecompute: Checking image does not exist...
	==> googlecompute: Creating temporary SSH key for instance...
	==> googlecompute: Creating instance...
	    googlecompute: Loading zone: us-west1-a
	    googlecompute: Loading machine type: n1-standard-1
	    googlecompute: Loading network: default
	    googlecompute: Requesting instance creation...
	    googlecompute: Waiting for creation operation to complete...
	    googlecompute: Instance has been created!
	==> googlecompute: Waiting for the instance to become running...
	    googlecompute: IP: 104.196.236.212
	==> googlecompute: Waiting for SSH to become available...
	==> googlecompute: Connected to SSH!
	==> googlecompute: Waiting for any running startup script to finish...
	==> googlecompute: Startup script not finished yet. Waiting...
	==> googlecompute: Startup script not finished yet. Waiting...
	==> googlecompute: Startup script, if any, has finished running.
	==> googlecompute: Deleting instance...
	    googlecompute: Instance has been deleted!
	==> googlecompute: Creating image...
	==> googlecompute: Deleting disk...
	    googlecompute: Disk has been deleted!
	Build 'googlecompute' finished.

	==> Builds finished. The artifacts of successful builds are:
	--> googlecompute: A disk image was created: singularity-hub-test-58151473-5671-eed2-1511-c8afdb680a36

This script can be used outside of Singularity Hub/Singularity Python - currently we aren't using Packer to generate the image because there seems to be an issue with installing Singularity with it. Instead, the image is created interactively, and saved for Singularity Hub. If you get the packer version to work, please let us know!
