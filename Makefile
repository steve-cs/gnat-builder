##############################################################
# 
# C O N F I G
#

release ?= cs-20200221
gcc-version ?= master
adacore-version ?= master
libadalang-version ?= stable
spark2014-version ?= fsf

os ?= debian

gnat-prefix ?= /usr/local
prefix ?= $(gnat-prefix)
sudo ?= sudo

# gcc configuration

host  ?= x86_64-linux-gnu
build ?= $(host)
target ?= $(build)
gcc-jobs ?= 4

# extra configure/setup build options

gcc-options ?=
xmlada-options ?=
gprbuild-options ?=
gnatcoll-core-options ?=
gnatcoll-bindings-options ?=
gnatcoll-db-options ?=
libadalang-options ?=
gtkada-options ?=
gps-options ?=
spark2014-options ?=

# release location and naming details

release-loc = release
release-url = https://github.com/steve-cs/gnat-builder/releases/download
release-name = gnat-$(release)-$(host)

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
bootstrap: all-depends all-bootstrap

.PHONY: release
release: base-depends all-depends all-bootstrap all-release

.PHONY: release-install
release-install: base-depends all-release-install all-depends

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
	    gnat gawk flex bison libc6-dev libc6-dev-i386 libzstd-dev

.PHONY: xmlada-depends-debian
xmlada-depends-debian: base-depends-debian

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
	    libgmp-dev libclang1
	#
	# patch
	# copy gps dependencies from /usr/lib to $(prefix)/lib
	# so that gps can find them.
	#
	$(sudo) mkdir -p $(prefix)/lib
	$(sudo) cp /usr/lib/*/libclang-*.so.1 $(prefix)/lib
	cd $(prefix)/lib && $(sudo) ln -sf libclang-*.so.1 libclang.so
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
all-bootstrap: gcc-build-clean
all-bootstrap: gprbuild-bootstrap-install
all-bootstrap: all-gnat-bootstrap

.PHONY: all-gnat-bootstrap
all-gnat-bootstrap: xmlada xmlada-install
all-gnat-bootstrap: xmlada-clean
all-gnat-bootstrap: gprbuild gprbuild-install
all-gnat-bootstrap: gprbuild-clean
all-gnat-bootstrap: gnatcoll-core gnatcoll-core-install
all-gnat-bootstrap: gnatcoll-core-clean
all-gnat-bootstrap: gnatcoll-bindings gnatcoll-bindings-install
all-gnat-bootstrap: gnatcoll-bindings-clean
all-gnat-bootstrap: gnatcoll-sql gnatcoll-sql-install
all-gnat-bootstrap: gnatcoll-gnatcoll_db2ada gnatcoll-gnatcoll_db2ada-install
all-gnat-bootstrap: gnatcoll-sqlite gnatcoll-sqlite-install
all-gnat-bootstrap: gnatcoll-xref gnatcoll-xref-install
all-gnat-bootstrap: gnatcoll-gnatinspect gnatcoll-gnatinspect-install
all-gnat-bootstrap: gnatcoll-db-clean
all-gnat-bootstrap: libadalang libadalang-install
all-gnat-bootstrap: libadalang-clean langkit-clean
all-gnat-bootstrap: gtkada gtkada-install
all-gnat-bootstrap: gtkada-clean
all-gnat-bootstrap: gps gps-install
all-gnat-bootstrap: gps-clean libadalang-tools-clean ada_language_server-clean
all-gnat-bootstrap: spark2014 spark2014-install
all-gnat-bootstrap: spark2014-clean

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

gcc-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/gcc-mirror/gcc -b $(gcc-version) $@
	rm -rf $@/.git

xmlada-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/xmlada -b $(adacore-version) $@
	rm -rf $@/.git

gprbuild-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/gprbuild -b $(adacore-version) $@
	rm -rf $@/.git

gtkada-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/gtkada -b $(adacore-version) $@
	rm -rf $@/.git

gnatcoll-core-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/gnatcoll-core -b $(adacore-version) $@
	rm -rf $@/.git

gnatcoll-bindings-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/gnatcoll-bindings -b $(adacore-version) $@
	rm -rf $@/.git

gnatcoll-db-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/gnatcoll-db -b $(adacore-version) $@
	rm -rf $@/.git

langkit-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/langkit -b $(adacore-version) $@
	rm -rf $@/.git

libadalang-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/libadalang -b $(libadalang-version) $@
	rm -rf $@/.git

libadalang-tools-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/libadalang-tools -b $(adacore-version) $@
	rm -rf $@/.git

ada_language_server-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/ada_language_server -b $(adacore-version) $@
	rm -rf $@/.git

gps-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/gps -b $(adacore-version) $@
	rm -rf $@/.git

spark2014-src:
	rm -rf $@
	git clone --depth=1 \
	https://github.com/adacore/spark2014 -b $(spark2014-version) $@
	cd $@ && git submodule init
	cd $@ && git submodule update
	rm -rf $@/.git

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
	    --enable-languages=c,c++,ada \
	    --disable-bootstrap \
	    $(gcc-options)

.PHONY: gcc
gcc: gcc-build
	make -C $< -j$(gcc-jobs)

.PHONY: gcc-install
gcc-install:
	$(sudo) make -C gcc-build install

####

.PHONY: gprbuild-bootstrap-install
gprbuild-bootstrap-install: gprbuild-src xmlada-src
	mkdir -p gprbuild-bootstrap-build
	cp -a gprbuild-src/* gprbuild-bootstrap-build
	cd gprbuild-bootstrap-build && $(sudo) bash bootstrap.sh \
	    --with-xmlada=../xmlada-src --prefix=$(prefix)
	rm -rf gprbuild-bootstrap-build

####

xmlada-build: xmlada-src
	mkdir -p $@
	cp -a $</* $@
	cd $@ && ./configure --prefix=$(prefix) $(xmlada-options)

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
	make -C $@ prefix=$(prefix) $(gprbuild-options) setup

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
	make -C $@ prefix=$(prefix) $(gnatcoll-core-options) setup

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

.PHONY: gnatcoll-bindings
gnatcoll-bindings: gnatcoll-bindings-build
	cd $</gmp && ./setup.py build $(gnatcoll-bindings-options)
	cd $</iconv && ./setup.py build $(gnatcoll-bindings-options)
	cd $</python && ./setup.py build $(gnatcoll-bindings-options)
	cd $</readline && ./setup.py build --accept-gpl $(gnatcoll-bindings-options)
	cd $</syslog && ./setup.py build $(gnatcoll-bindings-options)

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
	make -C $</sql prefix=$(prefix) $(gnatcoll-db-options) setup
	make -C $</gnatcoll_db2ada prefix=$(prefix) $(gnatcoll-db-options) setup
	make -C $</sqlite prefix=$(prefix) $(gnatcoll-db-options) setup
	make -C $</xref prefix=$(prefix) $(gnatcoll-db-options) setup
	make -C $</gnatinspect prefix=$(prefix) $(gnatcoll-db-options) setup

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

libadalang-build: libadalang-src langkit-src
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
libadalang: libadalang-build
	cd $< && . lal-venv/bin/activate \
	    && ada/manage.py make $(libadalang-options) \
	    && deactivate

.PHONY: libadalang-install
libadalang-install: clean-libadalang-prefix
	cd libadalang-build && $(sudo) sh -c ". lal-venv/bin/activate \
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
	cd $@ && ./configure --prefix=$(prefix) --with-GL=no $(gtkada-options)

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
	cd $@ && ./configure --prefix=$(prefix) $(gps-options)

.PHONY: gps
gps: gps-build
	make -C $< PROCESSORS=0

.PHONY: gps-install
gps-install:
	$(sudo) make -C gps-build install

#####

spark2014-build: spark2014-src gcc-src
	mkdir -p $@
	cp -a $</* $@
	rm -rf $@/gnat2why/gnat_src
	ln -s ../../gcc-src/gcc/ada $@/gnat2why/gnat_src
	make -C $@ $(spark2014-options) setup

.PHONY: spark2014
spark2014: spark2014-build
	unset prefix && make -C $<

.PHONY: spark2014-install
spark2014-install:
	make -C spark2014-build install-all
	$(sudo) cp -a spark2014-build/install/* $(prefix)

#####

# Keep all the stuff for spark2014 provers together until it basically works

.PHONY: spark2014-provers-depends
spark2014-provers-depends: spark2014-provers-depends-$(os)

.PHONY: spark2014-provers-depends-debian
spark2014-provers-depends-debian: spark2014-depends-debian
	$(sudo) apt-get -qq -y install \
	    dune cmake antlr3

.PHONY: spark2014-provers-depends-unknown
spark2014-provers-depends-unknown:

#####

.PHONY: spark2014-provers
spark2014-provers: alt-ergo cvc4 z3

.PHONY: spark2014-provers-install
spark2014-provers-install: alt-ergo-install cvc4-install z3-install

.PHONY: spark2014-provers-clean
spark2014-provers-clean: alt-ergo-clean cvc4-clean z3-clean

#####

alt-ergo-build: spark2014-src
	mkdir -p $@
	cp -a $</alt-ergo/sources/* $@
	cd $@ && ./configure alt-ergo --prefix=$(prefix)

.PHONY: alt-ergo
alt-ergo: alt-ergo-build
	make -C alt-ergo-build alt-ergo

.PHONY: alt-ergo-install
alt-ergo-install:
	make -C alt-ergo-build install-bin

#####

cvc4-build: spark2014-src
	mkdir -p $@
	cp -a $</cvc4/* $@
	cd $@ && ./configure.sh --prefix=$(prefix) --name=_build

.PHONY: cvc4
cvc4: cvc4-build
	make -C cvc4-build/_build

.PHONY: cvc4-install
cvc4-install:
	make -C cvc4-build/_build install

#####

z3-build: spark2014-src
	mkdir -p $@
	cp -a $</z3/* $@
	cd $@ && python scripts/mk_make.py --prefix=$(prefix)

.PHONY: z3
z3: z3-build
	make -C z3-build/build

.PHONY: z3-install
z3-install:
	make -C z3-build/build install

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
	rm -rf $(@:%-clean=%) $(@:%-clean=%)-src $(@:%-clean=%)-build

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

