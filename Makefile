# version = master
# gcc-version = master, trunk, gcc-8-branch gcc-7-branch, gcc-7_2_0-release
# prefix = /usr/local/gnat, /usr/gnat, etc.

release ?= 0.1.0-20190225
gcc-version ?= gcc-8-branch
adacore-version ?= master
libadalang-version ?= stable
prefix ?= /usr/local
sudo ?= sudo

# Ubuntu bionic configuration
#
llvm-version ?= 6.0
iconv-opt ?= "-lc"

# gcc configuration
#
host  ?= x86_64-linux-gnu
build ?= $(host)
target ?= $(build)
gcc-jobs ?= 8

# release location and naming details
#
release-loc = release
release-url = https://github.com/steve-cs/gnat-builder/releases/download
release-tag = v$(release)
release-name = gnat-build_tools-$(release)

.PHONY: prerequisites-install
prerequisites-install: base-depends

.PHONY: depends
depends: base-depends

.PHONY: default
default: all

.PHONY: install
install: all-install

##############################################################
#
# A L L
#

.PHONY: all-src
all-src: |               \
base-depends             \
gcc-src                  \
xmlada-src               \
gprbuild-src             \
gnatcoll-core-src        \
gnatcoll-bindings-src    \
gnatcoll-db-src          \
langkit-src              \
quex-src                 \
libadalang-src           \
gtkada-src               \
gps-src

.PHONY: all
all: |                   \
base-depends             \
gcc                      \
xmlada                   \
gprbuild                 \
gnatcoll-core            \
gnatcoll-bindings        \
gnatcoll-db              \
libadalang               \
gtkada                   \
gps

.PHONY: all-install
all-install: |                   \
base-depends                     \
gcc-install                      \
xmlada-install                   \
gprbuild-install                 \
gnatcoll-core-install            \
gnatcoll-bindings-install        \
gnatcoll-db-install              \
libadalang-install               \
gtkada-install                   \
gps-install

#
# E N D  A L L
#
##############################################################
#
# B O O T S T R A P
#

.PHONY: bootstrap
bootstrap: |                                              \
gcc-bootstrap                                             \
adacore-bootstrap

.PHONY: gcc-bootstrap
gcc-bootstrap: |                                          \
base-depends                                              \
gcc gcc-install

.PHONY: adacore-bootstrap
adacore-bootstrap: |                                      \
gprbuild-bootstrap                                        \
gnatcoll-bootstrap                                        \
gps-bootstrap

.PHONY: gprbuild-bootstrap
gprbuild-bootstrap: |                                     \
base-depends                                              \
gprbuild-boot                                             \
xmlada xmlada-install                                     \
gprbuild gprbuild-install

.PHONY: gnatcoll-bootstrap
gnatcoll-bootstrap: |                                     \
base-depends                                              \
gnatcoll-core gnatcoll-core-install                       \
gnatcoll-bindings gnatcoll-bindings-install               \
gnatcoll-sql gnatcoll-sql-install                         \
gnatcoll-gnatcoll_db2ada gnatcoll-gnatcoll_db2ada-install \
gnatcoll-sqlite gnatcoll-sqlite-install                   \
gnatcoll-xref gnatcoll-xref-install                       \
gnatcoll-gnatinspect gnatcoll-gnatinspect-install

.PHONY: gps-bootstrap
gps-bootstrap: |                                          \
base-depends                                              \
libadalang libadalang-install                             \
gtkada gtkada-install                                     \
gps gps-install

#
# E N D  B O O T  S T R A P
#
##############################################################
#
# R E L E A S E
#

.PHONY: release
release: $(release-name) base-depends

.PHONY: $(release-name)
$(release-name):
	mkdir -p $(release-loc)
	cd $(release-loc) && rm -rf $@ $@.tar.gz
	mkdir -p $(release-loc)/$@
	cp -r $(prefix)/* $(release-loc)/$@/
	cd $(release-loc) && tar czf $@.tar.gz $@

.PHONY: release-install
release-install: release-download base-depends
	$(sudo) cp -a $(release-loc)/$(release-name)/* $(prefix)/

.PHONY: release-download
release-download: $(release-loc)/$(release-name) base-depends

$(release-loc)/$(release-name):
	rm -rf $@ $@.tar.gz
	mkdir -p $(@D)
	cd $(@D) && wget -q $(release-url)/$(release-tag)/$(@F).tar.gz
	cd $(@D) && tar xf $(@F).tar.gz

#
# E N D  R E L E A S E
#
##############################################################
#
# C L E A N
#

.PHONY: clean
clean: 
	rm -rf *-src *-build

%-clean:
	rm -rf $(@:%-clean=%)-src $(@:%-clean=%)-build

.PHONY: dist-clean
dist-clean : clean
	rm -rf downloads github-repo release

.PHONY: bootstrap-clean
bootstrap-clean: clean prefix-clean

.PHONY: prefix-clean
prefix-clean:
	$(sudo) rm -rf $(prefix)/*
	$(sudo) mkdir -p $(prefix)

#
# E N D  C L E A N
#
##############################################################
#
# E X T E R N A L  B U I L D  D E P E N D E N C I E S
#

.PHONY: base-depends
base-depends:
	$(sudo) apt-get -qq -y install \
	ubuntu-minimal ubuntu-standard build-essential git

.PHONY: gcc-depends
gcc-depends: base-depends
	$(sudo) apt-get -qq -y install \
	gnat gawk flex bison libc6-dev libc6-dev-i386

.PHONY: xmlada-depends
xmlada-depends: base-depends

.PHONY: gprbuild-depends
gprbuild-depends: base-depends

.PHONY: gnatcoll-core-depends
gnatcoll-core-depends: base-depends

.PHONY: gnatcoll-bindings-depends
gnatcoll-bindings-depends: base-depends
	$(sudo) apt-get -qq -y install \
	python-dev libgmp-dev zlib1g-dev libreadline-dev

.PHONY: gnatcoll-db-depends
gnatcoll-db-depends: base-depends

.PHONY: libadalang-depends
libadalang-depends: base-depends
	$(sudo) apt-get -qq -y install \
	virtualenv python-dev libgmp-dev

.PHONY: gtkada-depends
gtkada-depends: base-depends
	$(sudo) apt-get -qq -y install \
	pkg-config libgtk-3-dev

.PHONY: gps-depends
gps-depends: base-depends
	$(sudo) apt-get -qq -y install \
	pkg-config libglib2.0-dev libpango1.0-dev libatk1.0-dev libgtk-3-dev \
	python-pip python-dev python-gi-dev python-cairo-dev \
	libclang-dev libgmp-dev

#
# E N D  E X T E R N A L  B U I L D  D E P E N D E N C I E S
#
##############################################################
#
# * - S R C
#

# most %-src are just symbolic links to their dependents

%-src:
	if [ "x$<" = "x" ]; then false; fi
	ln -s $< $@

# downloads

downloads/quex-0.65.4:
	mkdir -p $(@D)
	cd $(@D) && rm -rf $(@F) $(@F).tar.gz
	cd $(@D) && wget https://phoenixnap.dl.sourceforge.net/project/quex/HISTORY/0.65/$(@F).tar.gz
	cd $(@D) && tar xf $(@F).tar.gz

# from github

gcc-src: github-src/gcc-mirror/gcc/$(gcc-version)
	ln -s $< $@
	cd $@ && ./contrib/download_prerequisites

xmlada-src: github-src/adacore/xmlada/$(adacore-version)
gprbuild-src: github-src/adacore/gprbuild/$(adacore-version)
gtkada-src: github-src/adacore/gtkada/$(adacore-version)
gnatcoll-core-src: github-src/adacore/gnatcoll-core/$(adacore-version)
gnatcoll-bindings-src: github-src/adacore/gnatcoll-bindings/$(adacore-version)
gnatcoll-db-src: github-src/adacore/gnatcoll-db/$(adacore-version)
langkit-src: github-src/adacore/langkit/$(libadalang-version)
libadalang-src: github-src/adacore/libadalang/$(libadalang-version)
libadalang-tools-src: github-src/adacore/libadalang-tools/$(adacore-version)
gps-src: github-src/adacore/gps/$(adacore-version)

quex-src: downloads/quex-0.65.4

# aliases to other %-src

xmlada-bootstrap-src: xmlada-src
gprbuild-bootstrap-src: gprbuild-src

# linking github-src/<account>/<repository>/<branch> from github
# get the repository, update it, and checkout the requested branch

# github branches where we want to pull updates if available
#
github-src/%/stable-gps        \
github-src/%/stable            \
github-src/%/0.65.4            \
github-src/%/gcc-7-branch      \
github-src/%/gcc-8-branch      \
github-src/%/trunk             \
github-src/%/master: github-repo/%
	cd github-repo/$(@D:github-src/%=%) && git checkout -f $(@F)
	cd github-repo/$(@D:github-src/%=%) && git pull
	rm -rf $(@D)/*
	mkdir -p $(@D)
	ln -sf $(PWD)/github-repo/$(@D:github-src/%=%) $@

# github tags, e.g. releases, which don't have updates to pull
#
github-src/%/gcc-7_2_0-release: github-repo/%
	cd github-repo/$(@D:github-src/%=%) && git checkout -f $(@F)
	rm -rf $(@D)/*
	mkdir -p $(@D)
	ln -sf $(PWD)/github-repo/$(@D:github-src/%=%) $@


# Clone github-repo/<account>/<repository> from github.com

.PRECIOUS: github-repo/%
github-repo/%:
	rm -rf $@
	mkdir -p $(@D)
	cd $(@D) && git clone https://github.com/$(@:github-repo/%=%).git
	touch $@

#
# * - S R C
#
##############################################################
#
# P A T C H E S
#

#
# E N D   P A T C H E S
#
##############################################################
#
# * - B U I L D / I N S T A L L
#

%-build: %-src
	mkdir -p $@
	rsync -a --delete $</ $@

.PHONY: %-install
%-install: %-build
	$(sudo) make -C $< prefix=$(prefix) install

#####

gcc-build: gcc-src
	mkdir -p $@

.PHONY: gcc-boot
gcc-boot: gcc-build gcc-src gcc-depends
	rm -rf $</*
	cd $< && ../gcc-src/configure \
	--host=$(host) --build=$(build) --target=$(target) \
	--prefix=$(prefix) --enable-languages=c,c++,ada \
	-disable-shared --disable-multilib
	cd $<  && make -j$(gcc-jobs)

.PHONY: gcc
gcc: gcc-build gcc-src gcc-depends
	rm -rf $</*
	cd $< && ../gcc-src/configure \
	--host=$(host) --build=$(build) --target=$(target) \
	--prefix=$(prefix) --enable-languages=c,c++,ada \
	cd $<  && make -j$(gcc-jobs)

#####

.PHONY: gprbuild-boot
gprbuild-boot: gprbuild-bootstrap-build xmlada-bootstrap-build gprbuild-depends
	cd $<  && $(sudo) ./bootstrap.sh \
	--with-xmlada=../xmlada-bootstrap-build --prefix=$(prefix)

.PHONY: xmlada
xmlada: xmlada-build xmlada-depends
	cd $< && ./configure --prefix=$(prefix)
	make -C $< all

.PHONY: gprbuild
gprbuild: gprbuild-build gprbuild-depends
	make -C $< prefix=$(prefix) setup
	make -C $< all
	make -C $< libgpr.build

.PHONY: gprbuild-install
gprbuild-install: gprbuild-build
	$(sudo) make -C $< install
	$(sudo) make -C $< libgpr.install

#####

.PHONY: gnatcoll-core
gnatcoll-core: gnatcoll-core-build gnatcoll-core-depends
	make -C $< setup
	make -C $<

.PHONY: gnatcoll-core-install
gnatcoll-core-install: gnatcoll-core-build
	$(sudo) make -C $< prefix=$(prefix) install

#####

.PHONY: gnatcoll-bindings
gnatcoll-bindings: gnatcoll-bindings-build gnatcoll-bindings-depends
	cd $</gmp && ./setup.py build
	cd $</iconv && export GNATCOLL_ICONV_OPT=$(iconv-opt) && ./setup.py build
	cd $</python && ./setup.py build
	cd $</readline && ./setup.py build --accept-gpl
	cd $</syslog && ./setup.py build

.PHONY: gnatcoll-bindings-install
gnatcoll-bindings-install: gnatcoll-bindings-build
	cd $</gmp && $(sudo) ./setup.py install
	cd $</iconv && export GNATCOLL_ICONV_OPT=$(iconv-opt) && $(sudo) ./setup.py install
	cd $</python && $(sudo) ./setup.py install
	cd $</readline && $(sudo) ./setup.py install
	cd $</syslog && $(sudo) ./setup.py install

#####

.PHONY: gnatcoll-db
gnatcoll-db: |                \
gnatcoll-sql                  \
gnatcoll-gnatcoll_db2ada      \
gnatcoll-sqlite               \
gnatcoll-xref                 \
gnatcoll-gnatinspect

.PHONY: gnatcoll-db-install
gnatcoll-db-install: |           \
gnatcoll-sql-install             \
gnatcoll-gnatcoll_db2ada-install \
gnatcoll-sqlite-install          \
gnatcoll-xref-install            \
gnatcoll-gnatinspect-install

.PHONY: gnatcoll-sql
gnatcoll-sql: gnatcoll-db-build gnatcoll-db-depends
	make -C $</sql setup
	make -C $</sql

.PHONY: gnatcoll-sql-install
gnatcoll-sql-install: gnatcoll-db-build
	$(sudo) make -C $</sql install

.PHONY: gnatcoll-gnatcoll_db2ada
gnatcoll-gnatcoll_db2ada: gnatcoll-db-build gnatcoll-db-depends
	make -C $</gnatcoll_db2ada setup
	make -C $</gnatcoll_db2ada

.PHONY: gnatcoll-gnatcoll_db2ada-install
gnatcoll-gnatcoll_db2ada-install: gnatcoll-db-build
	$(sudo) make -C $</gnatcoll_db2ada install

.PHONY: gnatcoll-sqlite
gnatcoll-sqlite: gnatcoll-db-build gnatcoll-db-depends
	make -C $</sqlite setup
	make -C $</sqlite

.PHONY: gnatcoll-sqlite-install
gnatcoll-sqlite-install: gnatcoll-db-build
	$(sudo) make -C $</sqlite install

.PHONY: gnatcoll-xref
gnatcoll-xref: gnatcoll-db-build gnatcoll-db-depends
	make -C $</xref setup
	make -C $</xref

.PHONY: gnatcoll-xref-install
gnatcoll-xref-install: gnatcoll-db-build
	$(sudo) make -C $</xref install

.PHONY: gnatcoll-gnatinspect
gnatcoll-gnatinspect: gnatcoll-db-build gnatcoll-db-depends
	make -C $</gnatinspect setup
	make -C $</gnatinspect

.PHONY: gnatcoll-gnatinspect-install
gnatcoll-gnatinspect-install: gnatcoll-db-build
	$(sudo) make -C $</gnatinspect install

#####

.PHONY: libadalang
libadalang: libadalang-build langkit-build quex-src libadalang-depends
	cd $< && virtualenv lal-venv
	cd $< && . lal-venv/bin/activate \
	&& pip install -r REQUIREMENTS.dev \
	&& mkdir -p lal-venv/src/langkit \
	&& rm -rf lal-venv/src/langkit/* \
	&& cp -a ../langkit-build/* lal-venv/src/langkit \
	&& export QUEX_PATH=$(PWD)/quex-src \
	&& ada/manage.py make \
	&& deactivate

.PHONY: libadalang-install
libadalang-install: libadalang-build clean-libadalang-prefix
	cd $< && $(sudo) sh -c ". lal-venv/bin/activate \
	&& export QUEX_PATH=$(PWD)/quex-src \
	&& ada/manage.py install $(prefix) \
	&& deactivate"


.PHONY: clean-libadalang-prefix
clean-libadalang-prefix:
	# clean up old langkit install if there
	$(sudo) rm -rf $(prefix)/include/langkit*
	$(sudo) rm -rf $(prefix)/lib/langkit*
	$(sudo) rm -rf $(prefix)/share/gpr/langkit*
	$(sudo) rm -rf $(prefix)/share/gpr/manifests/langkit*
	# clean up old libadalang install if there
	$(sudo) rm -rf $(prefix)/include/libadalang*
	$(sudo) rm -rf $(prefix)/lib/libadalang*
	$(sudo) rm -rf $(prefix)/share/gpr/libadalang*
	$(sudo) rm -rf $(prefix)/share/gpr/manifests/libadalang*
	$(sudo) rm -rf $(prefix)/python/libadalang*
	# clean up old Mains project if there
	$(sudo) rm -rf $(prefix)/share/gpr/manifests/mains
	$(sudo) rm -rf $(prefix)/bin/parse
	$(sudo) rm -rf $(prefix)/bin/navigate
	$(sudo) rm -rf $(prefix)/bin/gnat_compare
	$(sudo) rm -rf $(prefix)/bin/nameres

#####

.PHONY: gtkada
gtkada: gtkada-build gtkada-depends
	cd $< && ./configure --prefix=$(prefix)
	make -C $< PROCESSORS=0

#####

.PHONY: gps
gps: gps-build gps-depends
	cd $< && ./configure \
	--prefix=$(prefix) \
	--with-clang=/usr/lib/llvm-$(llvm-version)/lib/ 
	make -C $< PROCESSORS=0

gps-build: gps-src libadalang-tools-build
	mkdir -p $@  $@/laltools
	rsync -a --delete $</ $@
	rsync -aL libadalang-tools-build/ $@/laltools

.PHONY: gps-install
gps-install: gps-build
	$(sudo) make -C $< prefix=$(prefix) install

#
# E N D  * - B U I L D / I N S T A L L
#
##############################################################
#
#

.PHONY: gps-run
gps-run:
	export PYTHONPATH=/usr/lib/python2.7:/usr/lib/python2.7/plat-x86_64-linux-gnu:/usr/lib/python2.7/dist-packages \
	&& gps

#
#
##############################################################
