# gnat-builder
Makefile for downloading and building gnat from github source.

|Repository|Build Status|
|:-----|:-----:|
gnat-builder | [![Build Status](https://travis-ci.org/steve-cs/travis-test.svg?branch=master)](https://travis-ci.org/steve-cs/travis-test/branches) 
xmlada | [![Build Status](https://travis-ci.org/steve-cs/travis-test.svg?branch=xmlada)](https://travis-ci.org/steve-cs/travis-test/branches) 
gprbuild | [![Build Status](https://travis-ci.org/steve-cs/travis-test.svg?branch=gprbuild)](https://travis-ci.org/steve-cs/travis-test/branches) 
gnatcoll-core | [![Build Status](https://travis-ci.org/steve-cs/travis-test.svg?branch=gnatcoll-core)](https://travis-ci.org/steve-cs/travis-test/branches) 
gnatcoll-bindings | [![Build Status](https://travis-ci.org/steve-cs/travis-test.svg?branch=gnatcoll-bindings)](https://travis-ci.org/steve-cs/travis-test/branches) 
gnatcoll-db | [![Build Status](https://travis-ci.org/steve-cs/travis-test.svg?branch=gnatcoll-db)](https://travis-ci.org/steve-cs/travis-test/branches) 
libadalang | [![Build Status](https://travis-ci.org/steve-cs/travis-test.svg?branch=libadalang)](https://travis-ci.org/steve-cs/travis-test/branches) 
gtkada | [![Build Status](https://travis-ci.org/steve-cs/travis-test.svg?branch=gtkada)](https://travis-ci.org/steve-cs/travis-test/branches) 
gps | [![Build Status](https://travis-ci.org/steve-cs/travis-test.svg?branch=gps)](https://travis-ci.org/steve-cs/travis-test/branches)


## Overview

This is a Makefile and a set of patches to build a gcc/gnat tool chain including gcc compiler, libraries, and GPS IDE.

## Typical usage

### Starting from scratch, download and install a recent release
* \# install ubuntu artful
* sudo mkdir -p /usr/local/gnat
* sudo chown $USER /usr/local/gnat
* sudo apt-get install build-essential git
* git clone https://github.com/steve-cs/gnat-builder
* cd gnat-builder
* sudo make prerequisites-install
* make release-download
* make release-install

### Don't forget to add the \<prefix\>/bin to your PATH, check that it works...

* export PATH=/usr/local/gnat/bin:$PATH
* which gcc

### Bootstrap from source (not requiring a prexisting release or gpl-2017 binaries)

This starts from linux distribution gcc/gnat compiler and bootstraps a new compiler, ada tool chain, and gps.  The first time you bootstrap the gcc compiler it may take some time as it downloads the entire github/gcc-mirror/gcc repository and then does an enable-bootstrap (build the compiler three times) build.

After doing the prerequisites above it should be as simple as:

* make bootstrap-clean
* make bootstrap-install

### Build and install the development trunk of gcc

After doing (at least) the prerequisites above:

* make gcc-version=trunk gcc
* make gcc-install

### Build and install Adacore open source

After installing a release or bootstrap:

* make all
* make all-install

-or simply-

* make
* make install

### Saving and installing a local release/snapshot

Save a snapshot of the contents of the prefix as a locally defined release.  Change \<my-release-id\>.  It ends up being both part of a directory name and part of a filename, so no spaces, "/", or other special characters. If release= isn't specified it will repace the default release in the local cache.

* \# save a release
* make release=\<my-release-id\> release

* \# re-install a release
* make release=\<my-release-id\> release-install

## Variables and their current defaults

### release ?= \<latest-release\>, e.g. 0.1.0-20180109

This is used by the release, release-download, and release-install targets.

### gcc-version ?= gcc-7-branch

This is either a tag or a branch of gcc as it exists in the github.com gcc-mirror/gcc repository.
Currently this is limited to: master, trunk, gcc-7-branch, gcc-7_2_0-release.

### adacore-version ?= master

Currently this is limited to master.

### prefix ?= /usr/local/gnat

This specifies where the build tools directory is or will be located.  Its contents are deleted by a number of targets including prefix-clean, bootstrap-clean and release-install.

## Main make targets

### default, all, install, all-install, bootstrap-install

### prerequisites-install

### release, release-install, release-download

### clean, dist-clean, bootstrap-clean, prefix-clean

## Individual component make targets 

### gcc, gcc-bootstrap, gcc-install, gcc-clean

### gprbuild-bootstrap-install, xmlada-bootstrap-clean, gprbuild-bootstrap-clean

### xmlada, xmlada-install, xmlada-clean

### gprbuild, gprbuild-install, gprbuild-clean

### gnatcoll-core, gnatcoll-core-install, gnatcoll-core-clean

### gnatcoll-bindings, gnatcoll-bindings-install, gnatcoll-bindings-clean

### gnatcoll-db, gnatcoll-db-install, gnatcoll-db-clean

### libadalang, libadalang-install, libadalang-clean

### gtkada, gtkada-install, gtkada-clean

### gps, gps-install, gps-clean
