##############################################################
#
# C O N F I G
#

release ?= cs-19.2.0-beta1
gcc-version ?= gcc-8-branch
adacore-version ?= 19.2
libadalang-version ?= 19.2
spark2014-version ?= 19.2
gnat-src-version ?= master

os ?= debian

prefix ?= /usr/local
sudo ?= sudo

# gcc configuration

host  ?= x86_64-linux-gnu
build ?= $(host)
target ?= $(build)
gcc-jobs ?= 8

# release location and naming details

release-loc = release
release-url = https://github.com/steve-cs/gnat-builder/releases/download
release-name = gnat-$(release)-$(host)

# 19.2 patch summary (already fixed in development)
#
# *-src  - libadalang needs quex-src
# xmlada - configure missing execute bits
# gnatcoll-bindings - needs -lc instead of -liconv as default for iconv_opt
# libadalang - needs quex-src support
# gps - force Build=Production as default fails


#
# E N D   C O N F I G
#
##############################################################
#
# T O P   L E V E L
#

.PHONY: default
default: all

.PHONY: depends
depends: all-depends

.PHONY: all
all: all-gnat

.PHONY: install
install: all-gnat-install

.PHONY: bootstrap
bootstrap: depends all-bootstrap

.PHONY: release
release: bootstrap-clean bootstrap all-release

.PHONY: release-install
release-install: all-release-install depends

.PHONY: clean
clean: all-clean

#
# E N D   T O P   L E V E L
#
##############################################################
#
# D E P E N D S
#

# all-* depends are os independent

.PHONY: all-depends
all-depends: base-depends gcc-depends all-gnat-depends

.PHONY: all-gnat-depends
all-gnat-depends: base-depends
all-gnat-depends: xmlada-depends
all-gnat-depends: gprbuild-depends
all-gnat-depends: gnatcoll-core-depends
all-gnat-depends: gnatcoll-bindings-depends
all-gnat-depends: gnatcoll-db-depends
all-gnat-depends: libadalang-depends
all-gnat-depends: gtkada-depends
all-gnat-depends: gps-depends
all-gnat-depends: spark2014-depends

#  *-depends dispatch to os specific dependencies

.PHONY: base-depends
base-depends: base-depends-$(os)

.PHONY: gcc-depends
gcc-depends: gcc-depends-$(os)

.PHONY: xmlada-depends
xmlada-depends: xmlada-depends-$(os)

.PHONY: gprbuild-depend
gprbuild-depends: gprbuild-depends-$(os)

.PHONY: gnatcoll-core-depends
gnatcoll-core-depends: gnatcoll-core-depends-$(os)

.PHONY: gnatcoll-bindings-depends
gnatcoll-bindings-depends: gnatcoll-bindings-depends-$(os)

.PHONY: gnatcoll-db-depends
gnatcoll-db-depends: gnatcoll-db-depends-$(os)

.PHONY: libadalang-depends
libadalang-depends: libadalang-depends-$(os)

.PHONY: gtkada-depends
gtkada-depends: gtkada-depends-$(os)

.PHONY: gps-depends
gps-depends: gps-depends-$(os)

.PHONY: spark2014-depends
spark2014-depends: spark2014-depends-$(os)

##### os=debian dependency support

.PHONY: sudo-debian
sudo-debian:
	if [ ! -f /usr/bin/sudo ]; then \
	   apt-get -qq -y install sudo; \
	fi

.PHONY: base-depends-debian
base-depends-debian: sudo-debian
	$(sudo) apt-get -qq -y install \
	    make git wget build-essential

.PHONY: gcc-depends-debian
gcc-depends-debian: base-depends-debian
	$(sudo) apt-get -qq -y install \
	    gnat gawk flex bison libc6-dev libc6-dev-i386

.PHONY: xmlada-depends-debian
xmlada-depend-debians: base-depends-debian

.PHONY: gprbuild-depends-debian
gprbuild-depends-debian: base-depends-debian

.PHONY: gnatcoll-core-depends-debian
gnatcoll-core-depends-debian: base-depends-debian

.PHONY: gnatcoll-bindings-depends-debian
gnatcoll-bindings-depends-debian: base-depends-debian
	$(sudo) apt-get -qq -y install \
	    python-dev libgmp-dev zlib1g-dev libreadline-dev

.PHONY: gnatcoll-db-depends-debian
gnatcoll-db-depends-debian: base-depends-debian

.PHONY: libadalang-depends-debian
libadalang-depends-debian: base-depends-debian
	$(sudo) apt-get -qq -y install \
	    virtualenv python-dev libgmp-dev

.PHONY: gtkada-depends-debian
gtkada-depends-debian: base-depends-debian
	$(sudo) apt-get -qq -y install \
	    pkg-config libgtk-3-dev

.PHONY: gps-depends-debian
gps-depends-debian: base-depends-debian
	$(sudo) apt-get -qq -y install \
	    pkg-config libglib2.0-dev libpango1.0-dev \
	    libatk1.0-dev libgtk-3-dev \
	    python-dev python-gi-dev python-cairo-dev \
	    libclang-dev libgmp-dev
	#
	# patch
	# copy gps dependencies from /usr/lib to $(prefix)/lib
	# so that gps can find them.
	#
	$(sudo) mkdir -p $(prefix)/lib
	$(sudo) cp /usr/lib/llvm-*/lib/libclang.so $(prefix)/lib
	$(sudo) mkdir -p $(prefix)/lib/python2.7
	$(sudo) cp -a /usr/lib/python2.7/* $(prefix)/lib/python2.7

.PHONY: spark2014-depends-debian
spark2014-depends-debian: base-depends-debian
	$(sudo) apt-get -qq -y install \
	    ocaml libocamlgraph-ocaml-dev \
	    menhir libmenhir-ocaml-dev libzarith-ocaml-dev \
	    libzip-ocaml-dev ocplib-simplex-ocaml-dev \
	    cvc4 z3 alt-ergo

#####  os=unknown dependency support (empty template)

.PHONY: sudo-unknown
sudo-unknown:

.PHONY: base-depends-unknown
base-depends-unknown: sudo-unknown

.PHONY: gcc-depends-unknown
gcc-depends-unknown: base-depends-unknown

.PHONY: xmlada-depends-unknown
xmlada-depend-unknowns: base-depends-unknown

.PHONY: gprbuild-depends-unknown
gprbuild-depends-unknown: base-depends-unknown

.PHONY: gnatcoll-core-depends-unknown
gnatcoll-core-depends-unknown: base-depends-unknown

.PHONY: gnatcoll-bindings-depends-unknown
gnatcoll-bindings-depends-unknown: base-depends-unknown

.PHONY: gnatcoll-db-depends-unknown
gnatcoll-db-depends-unknown: base-depends-unknown

.PHONY: libadalang-depends-unknown
libadalang-depends-unknown: base-depends-unknown

.PHONY: gtkada-depends-unknown
gtkada-depends-unknown: base-depends-unknown

.PHONY: gps-depends-unknown
gps-depends-unknown: base-depends-unknown

.PHONY: spark2014-depends-unknown
spark2014-depends-unknown: base-depends-unknown

#
# E N D   D E P E N D S
#
##############################################################
#
# A L L
#

.PHONY: all-src
all-src: gcc-src all-gnat-src

.PHONY: all-gnat-src
all-gnat-src: xmlada-src
all-gnat-src: gprbuild-src
all-gnat-src: gnatcoll-core-src
all-gnat-src: gnatcoll-bindings-src
all-gnat-src: gnatcoll-db-src
all-gnat-src: libadalang-src
all-gnat-src: langkit-src
all-gnat-src: gtkada-src
all-gnat-src: gps-src
all-gnat-src: libadalang-tools-src
all-gnat-src: ada_language_server-src
all-gnat-src: spark2014-src
all-gnat-src: gnat-src

.PHONY: all-gnat
all-gnat: xmlada
all-gnat: gprbuild
all-gnat: gnatcoll-core
all-gnat: gnatcoll-bindings
all-gnat: gnatcoll-db
all-gnat: libadalang
all-gnat: gtkada
all-gnat: gps
all-gnat: spark2014

.PHONY: all-install
all-install: gcc-install all-gnat-install

.PHONY: all-gnat-install
all-gnat-install: xmlada-install
all-gnat-install: gprbuild-install
all-gnat-install: gnatcoll-core-install
all-gnat-install: gnatcoll-bindings-install
all-gnat-install: gnatcoll-db-install
all-gnat-install: libadalang-install
all-gnat-install: gtkada-install
all-gnat-install: gps-install
all-gnat-install: spark2014-install

.PHONY: all-bootstrap
all-bootstrap: gcc-bootstrap
all-bootstrap: gprbuild-bootstrap-install
all-bootstrap: all-gnat-bootstrap

.PHONY: all-gnat-bootstrap
all-gnat-bootstrap: xmlada xmlada-install
all-gnat-bootstrap: gprbuild gprbuild-install
all-gnat-bootstrap: gnatcoll-core gnatcoll-core-install
all-gnat-bootstrap: gnatcoll-bindings gnatcoll-bindings-install
all-gnat-bootstrap: gnatcoll-sql gnatcoll-sql-install
all-gnat-bootstrap: gnatcoll-db-build
all-gnat-bootstrap: gnatcoll-gnatcoll_db2ada gnatcoll-gnatcoll_db2ada-install
all-gnat-bootstrap: gnatcoll-sqlite gnatcoll-sqlite-install
all-gnat-bootstrap: gnatcoll-xref gnatcoll-xref-install
all-gnat-bootstrap: gnatcoll-gnatinspect gnatcoll-gnatinspect-install
all-gnat-bootstrap: libadalang libadalang-install
all-gnat-bootstrap: gtkada gtkada-install
all-gnat-bootstrap: gps gps-install
all-gnat-bootstrap: spark2014 spark2014-install

.PHONY: all-release
all-release: $(release-name)

.PHONY: all-clean
all-clean: gcc-clean all-gnat-clean github-clean

.PHONY: all-gnat-clean
all-gnat-clean: gprbuild-bootstrap-clean
all-gnat-clean: xmlada-clean
all-gnat-clean: gprbuild-clean
all-gnat-clean: gnatcoll-core-clean
all-gnat-clean: gnatcoll-bindings-clean
all-gnat-clean: gnatcoll-db-clean
all-gnat-clean: libadalang-clean
all-gnat-clean: langkit-clean
all-gnat-clean: gtkada-clean
all-gnat-clean: gps-clean
all-gnat-clean: libadalang-tools-clean
all-gnat-clean: ada_language_server-clean
all-gnat-clean: spark2014-clean
all-gnat-clean: gnat-clean
all-gnat-clean: quex-clean

#
# A L L
#
##############################################################
#
# * - S R C
#

%-src:
	if [ "x$<" = "x" ]; then false; fi
	ln -s $< $@

gcc-src: github-src/gcc-mirror/gcc/$(gcc-version)
xmlada-src: github-src/adacore/xmlada/$(adacore-version)
gprbuild-src: github-src/adacore/gprbuild/$(adacore-version)
gtkada-src: github-src/adacore/gtkada/$(adacore-version)
gnatcoll-core-src: github-src/adacore/gnatcoll-core/$(adacore-version)
gnatcoll-bindings-src: github-src/adacore/gnatcoll-bindings/$(adacore-version)
gnatcoll-db-src: github-src/adacore/gnatcoll-db/$(adacore-version)
langkit-src: github-src/adacore/langkit/$(libadalang-version)
libadalang-src: github-src/adacore/libadalang/$(libadalang-version)
libadalang-tools-src: github-src/adacore/libadalang-tools/$(adacore-version)
ada_language_server-src: github-src/adacore/ada_language_server/master
gps-src: github-src/adacore/gps/$(adacore-version)
spark2014-src: github-src/adacore/spark2014/$(spark2014-version)
gnat-src: github-src/steve-cs/gnat/$(gnat-src-version)
#
# patch 19.2 - libadalang build needs quex-src support
quex-src: github-src/steve-cs/quex/master

# linking github-src/<account>/<repository>/<branch> from github

github-src/%/master                \
github-src/%/$(gcc-version)        \
github-src/%/$(gnat-src-version)   \
github-src/%/$(adacore-version)    \
github-src/%/$(libadalang-version) \
github-src/%/$(spark2014-version)  \
    : github-repo/%
	cd github-repo/$(@D:github-src/%=%) \
	&& git checkout $(@F) \
	&& git pull
	rm -rf $(@D)/*
	mkdir -p $(@D)
	ln -sf $(PWD)/github-repo/$(@D:github-src/%=%) $@

# clone github-repo/<account>/<repository> from github.com

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
# * - B U I L D / I N S T A L L
#

.PHONY: gcc-bootstrap
gcc-bootstrap: gcc gcc-install

gcc-build: gcc-src
	mkdir -p $@
	rm -rf $@/*
	cd $< && ./contrib/download_prerequisites
	cd $@ && ../$</configure \
	    --prefix=$(prefix) \
	    --host=$(host) --build=$(build) --target=$(target) \
	    --enable-languages=c,c++,ada

.PHONY: gcc
gcc: gcc-build gcc-src
	make -C $< -j$(gcc-jobs)

.PHONY: gcc-install
gcc-install:
	$(sudo) make -C gcc-build install

####

.PHONY: gprbuild-bootstrap-install
gprbuild-bootstrap-install: gprbuild-src xmlada-src
	mkdir -p gprbuild-bootstrap-build
	cp -a gprbuild-src/* gprbuild-bootstrap-build
	cd gprbuild-bootstrap-build && $(sudo) ./bootstrap.sh \
	    --with-xmlada=../xmlada-src --prefix=$(prefix)

####

xmlada-build: xmlada-src
	mkdir -p $@
	cp -a $</* $@
	#
	# patch 19.2 - configure missing execute bits
	chmod 755 $@/configure
	#
	cd $@ && ./configure --prefix=$(prefix)

.PHONY: xmlada
xmlada: xmlada-build
	make -C $< all

.PHONY: xmlada-install
xmlada-install:
	$(sudo) make -C xmlada-build install

####

gprbuild-build: gprbuild-src
	mkdir -p $@
	cp -a $</* $@
	make -C $@ prefix=$(prefix) setup

.PHONY: gprbuild
gprbuild: gprbuild-build
	make -C $< all
	make -C $< libgpr.build

.PHONY: gprbuild-install
gprbuild-install:
	$(sudo) make -C gprbuild-build install
	$(sudo) make -C gprbuild-build libgpr.install

#####

gnatcoll-core-build: gnatcoll-core-src
	mkdir -p $@
	cp -a $</* $@
	make -C $@ setup

.PHONY: gnatcoll-core
gnatcoll-core: gnatcoll-core-build
	make -C $<

.PHONY: gnatcoll-core-install
gnatcoll-core-install:
	$(sudo) make -C gnatcoll-core-build install

#####

gnatcoll-bindings-build: gnatcoll-bindings-src
	mkdir -p $@
	cp -a $</* $@
	#
	# 19.2 patch - use libc instead of libiconv for default iconv_opt
	sed -i 's/-liconv/-lc/g' $@/iconv/gnatcoll_iconv.gpr

.PHONY: gnatcoll-bindings
gnatcoll-bindings: gnatcoll-bindings-build
	cd $</gmp && ./setup.py build
	cd $</iconv && ./setup.py build
	cd $</python && ./setup.py build
	cd $</readline && ./setup.py build --accept-gpl
	cd $</syslog && ./setup.py build

.PHONY: gnatcoll-bindings-install
gnatcoll-bindings-install:
	cd gnatcoll-bindings-build/gmp && $(sudo) ./setup.py install --prefix=$(prefix)
	cd gnatcoll-bindings-build/iconv && $(sudo) ./setup.py install --prefix=$(prefix)
	cd gnatcoll-bindings-build/python && $(sudo) ./setup.py install --prefix=$(prefix)
	cd gnatcoll-bindings-build/readline && $(sudo) ./setup.py install --prefix=$(prefix)
	cd gnatcoll-bindings-build/syslog && $(sudo) ./setup.py install --prefix=$(prefix)

#####

gnatcoll-db-build: gnatcoll-db-src
	mkdir -p $@
	cp -a $</* $@
	make -C $</sql prefix=$(prefix) setup
	make -C $</gnatcoll_db2ada prefix=$(prefix) setup
	make -C $</sqlite prefix=$(prefix) setup
	make -C $</xref prefix=$(prefix) setup
	make -C $</gnatinspect prefix=$(prefix) setup

.PHONY: gnatcoll-db
gnatcoll-db: gnatcoll-sql
gnatcoll-db: gnatcoll-gnatcoll_db2ada
gnatcoll-db: gnatcoll-sqlite
gnatcoll-db: gnatcoll-xref
gnatcoll-db: gnatcoll-gnatinspect

.PHONY: gnatcoll-db-install
gnatcoll-db-install: gnatcoll-sql-install
gnatcoll-db-install: gnatcoll-gnatcoll_db2ada-install
gnatcoll-db-install: gnatcoll-sqlite-install
gnatcoll-db-install: gnatcoll-xref-install
gnatcoll-db-install: gnatcoll-gnatinspect-install

.PHONY: gnatcoll-sql
gnatcoll-sql: gnatcoll-db-build
	make -C $</sql

.PHONY: gnatcoll-sql-install
gnatcoll-sql-install:
	$(sudo) make -C gnatcoll-db-build/sql install

.PHONY: gnatcoll-gnatcoll_db2ada
gnatcoll-gnatcoll_db2ada: gnatcoll-db-build
	make -C $</gnatcoll_db2ada

.PHONY: gnatcoll-gnatcoll_db2ada-install
gnatcoll-gnatcoll_db2ada-install:
	$(sudo) make -C gnatcoll-db-build/gnatcoll_db2ada install

.PHONY: gnatcoll-sqlite
gnatcoll-sqlite: gnatcoll-db-build
	make -C $</sqlite

.PHONY: gnatcoll-sqlite-install
gnatcoll-sqlite-install:
	$(sudo) make -C gnatcoll-db-build/sqlite install

.PHONY: gnatcoll-xref
gnatcoll-xref: gnatcoll-db-build
	make -C $</xref

.PHONY: gnatcoll-xref-install
gnatcoll-xref-install:
	$(sudo) make -C gnatcoll-db-build/xref install

.PHONY: gnatcoll-gnatinspect
gnatcoll-gnatinspect: gnatcoll-db-build
	make -C $</gnatinspect

.PHONY: gnatcoll-gnatinspect-install
gnatcoll-gnatinspect-install:
	$(sudo) make -C gnatcoll-db-build/gnatinspect install

#####

# patch 19.2 - libadalang build needs quex-src support

libadalang-build: libadalang-src langkit-src quex-src
	mkdir -p $@
	cp -a $</* $@
	cd $@ && virtualenv lal-venv
	cd $@ && . lal-venv/bin/activate \
	    && pip install -r REQUIREMENTS.dev \
	    && mkdir -p lal-venv/src/langkit \
	    && rm -rf lal-venv/src/langkit/* \
	    && cp -a ../langkit-src/* lal-venv/src/langkit \
	    && deactivate

.PHONY: libadalang
libadalang: libadalang-build quex-src
	cd $< && . lal-venv/bin/activate \
	    && export QUEX_PATH=$(PWD)/quex-src \
	    && ada/manage.py make \
	    && deactivate

.PHONY: libadalang-install
libadalang-install: clean-libadalang-prefix
	cd libadalang-build && $(sudo) sh -c ". lal-venv/bin/activate \
	    && export QUEX_PATH=$(PWD)/quex-src \
	    && ada/manage.py install $(prefix) \
	    && deactivate"
	#
	# patch
	# libadalang install is leaving some bits in $(prefix)/python/
	# put them in $(prefix)/lib/python2.7/ where they will be found
	# by gps at run (or build?) time
	#
	$(sudo) mkdir -p $(prefix)/lib/python2.7
	$(sudo) cp -a $(prefix)/python/libadalang $(prefix)/lib/python2.7
	$(sudo) cp -a $(prefix)/python/setup.py $(prefix)/lib/python2.7/libadalang

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

gtkada-build: gtkada-src
	mkdir -p $@
	cp -a $</* $@
	cd $@ && ./configure --prefix=$(prefix)

.PHONY: gtkada
gtkada: gtkada-build
	make -C $< PROCESSORS=0

.PHONY: gtkada-install
gtkada-install:
	$(sudo) make -C gtkada-build install

#####

gps-build: gps-src libadalang-tools-src ada_language_server-src
	mkdir -p $@  $@/laltools
	cp -a $</* $@
	cp -a libadalang-tools-src/* $@/laltools
	mkdir -p $@/ada_language_server
	cp -a ada_language_server-src/* $@/ada_language_server
	cd $@ && ./configure --prefix=$(prefix)

.PHONY: gps
gps: gps-build
	#
	# patch 19.2 - force Build=Production as default fails
	export Build=Production && \
	#                       && \
	make -C $< PROCESSORS=0


.PHONY: gps-install
gps-install:
	$(sudo) make -C gps-build install

#####

spark2014-build: spark2014-src gnat-src
	cd $< && git submodule init
	cd $< && git submodule update
	mkdir -p $@
	cp -a $</* $@
	rm -rf $@/gnat2why/gnat_src
	ln -s ../../gnat-src/gcc/ada $@/gnat2why/gnat_src
	make -C $@ setup


.PHONY: spark2014
spark2014: spark2014-build
	make -C $<


.PHONY: spark2014-install
spark2014-install:
	make -C spark2014-build install-all
	$(sudo) cp -a spark2014-build/install/* $(prefix)

#
# * - B U I L D / I N S T A L L
#
##############################################################
#
# R E L E A S E
#

.PHONY: $(release-name)
$(release-name):
	rm -rf $(release-loc)/$@
	rm -rf $(release-loc)/$@.tar.gz
	mkdir -p $(release-loc)
	mkdir -p $(release-loc)/$@
	cp -r $(prefix)/* $(release-loc)/$@
	cd $(release-loc) && tar czf $@.tar.gz $@

.PHONY: all-release-install
all-release-install: $(release-loc)/$(release-name)
	$(sudo) cp -a $(release-loc)/$(release-name)/* $(prefix)/

$(release-loc)/$(release-name):
	rm -rf $@ $@.tar.gz
	mkdir -p $(@D)
	cd $(@D) && wget -q $(release-url)/$(release)/$(@F).tar.gz
	cd $(@D) && tar xf $(@F).tar.gz

#
# R E L E A S E
#
##############################################################
#
# C L E A N
#

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
# C L E A N
#
##############################################################

