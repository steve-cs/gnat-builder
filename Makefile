##############################################################
# 
# C O N F I G
#

release ?= cs-20201021
gcc-version ?= master
adacore-repos ?= adacore
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
release-url = https://github.com/steve-cs/gnat-builder/releases/download/$(release)
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
all: all-all

.PHONY: install
install: all-install

.PHONY: bootstrap
bootstrap: all-depends all-bootstrap

.PHONY: release
release: bootstrap all-release

.PHONY: release-install
release-install: all-release-install all-depends

.PHONY: clean
clean: all-clean

#
# E N D   T O P   L E V E L
#
##############################################################
#
# D E P E N D S
#

.PHONY: all-depends
all-depends: base-depends-$(os)
all-depends: gcc-depends-$(os)
all-depends: xmlada-depends-$(os)
all-depends: gprbuild-depends-$(os)
all-depends: gnatcoll-core-depends-$(os)
all-depends: gnatcoll-bindings-depends-$(os)
all-depends: gnatcoll-db-depends-$(os)
all-depends: libadalang-depends-$(os)
all-depends: gtkada-depends-$(os)
all-depends: gps-depends-$(os)
all-depends: spark2014-depends-$(os)

#### default additional dependencies for each component is empty

%-depends-$(os): ;

##### os=debian dependency support

.PHONY: base-depends-debian
base-depends-debian:
	if [ ! -f /usr/bin/sudo ]; then \
	   apt-get -qq -y install sudo; \
	fi
	$(sudo) apt-get -qq -y install \
	    make git wget build-essential

.PHONY: gcc-depends-debian
gcc-depends-debian:
	$(sudo) apt-get -qq -y install \
	    gnat gawk flex bison libc6-dev libc6-dev-i386 libzstd-dev

.PHONY: gnatcoll-bindings-depends-debian
gnatcoll-bindings-depends-debian:
	$(sudo) apt-get -qq -y install \
	    python-dev libgmp-dev zlib1g-dev libreadline-dev

.PHONY: libadalang-depends-debian
libadalang-depends-debian:
	$(sudo) apt-get -qq -y install \
	    virtualenv python-dev libgmp-dev \
	    python3.8 python3.8-venv python3.8-dev 

.PHONY: gtkada-depends-debian
gtkada-depends-debian:
	$(sudo) apt-get -qq -y install \
	    pkg-config libgtk-3-dev

.PHONY: gps-depends-debian
gps-depends-debian:
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
	$(sudo) rm -rf $(prefix)/lib/libclang*
	$(sudo) cp /usr/lib/*/libclang-*.so.1 $(prefix)/lib
	cd $(prefix)/lib && $(sudo) ln -sf libclang-*.so.1 libclang.so
	$(sudo) mkdir -p $(prefix)/lib/python2.7
	$(sudo) cp -a /usr/lib/python2.7/* $(prefix)/lib/python2.7

.PHONY: spark2014-depends-debian
spark2014-depends-debian:
	$(sudo) apt-get -qq -y install \
	    libnum-ocaml-dev \
	    ocaml libocamlgraph-ocaml-dev \
	    menhir libmenhir-ocaml-dev libzarith-ocaml-dev \
	    libzip-ocaml-dev ocplib-simplex-ocaml-dev \
	    libyojson-ocaml-dev \
	    cvc4 z3 alt-ergo

#
# E N D   D E P E N D S
#
##############################################################
#
# A L L
#

.PHONY: all-src
all-src: gcc-src
all-src: xmlada-src
all-src: gprbuild-src
all-src: gprconfig_kb-src
all-src: gnatcoll-core-src
all-src: gnatcoll-bindings-src
all-src: gnatcoll-db-src
all-src: libadalang-src
all-src: langkit-src
all-src: gtkada-src
all-src: gps-src
all-src: libadalang-tools-src
all-src: ada_language_server-src
all-src: vss-src
all-src: spark2014-src

.PHONY: all-all
all-all: gcc
all-all: xmlada
all-all: gprbuild
all-all: gnatcoll-core
all-all: gnatcoll-bindings
all-all: gnatcoll-db
all-all: libadalang
all-all: gtkada
all-all: gps
all-all: spark2014

.PHONY: all-install
all-install: gcc-install
all-install: xmlada-install
all-install: gprbuild-install
all-install: gnatcoll-core-install
all-install: gnatcoll-bindings-install
all-install: gnatcoll-db-install
all-install: libadalang-install
all-install: gtkada-install
all-install: gps-install
all-install: spark2014-install

.PHONY: all-bootstrap
all-bootstrap: gcc-bootstrap
all-bootstrap: gcc-build-clean
all-bootstrap: gprbuild-bootstrap-install
all-bootstrap: gprconfig_kb-clean
all-bootstrap: xmlada xmlada-install
all-bootstrap: xmlada-clean
all-bootstrap: gprbuild gprbuild-install
all-bootstrap: gprbuild-clean
all-bootstrap: gnatcoll-core gnatcoll-core-install
all-bootstrap: gnatcoll-core-clean
all-bootstrap: gnatcoll-bindings gnatcoll-bindings-install
all-bootstrap: gnatcoll-bindings-clean
all-bootstrap: gnatcoll-sql gnatcoll-sql-install
all-bootstrap: gnatcoll-gnatcoll_db2ada gnatcoll-gnatcoll_db2ada-install
all-bootstrap: gnatcoll-sqlite gnatcoll-sqlite-install
all-bootstrap: gnatcoll-xref gnatcoll-xref-install
all-bootstrap: gnatcoll-gnatinspect gnatcoll-gnatinspect-install
all-bootstrap: gnatcoll-db-clean
all-bootstrap: libadalang libadalang-install
all-bootstrap: libadalang-clean langkit-clean
all-bootstrap: gtkada gtkada-install
all-bootstrap: gtkada-clean
all-bootstrap: gps gps-install
all-bootstrap: gps-clean libadalang-tools-clean ada_language_server-clean vss-clean
all-bootstrap: spark2014 spark2014-install
all-bootstrap: spark2014-clean gcc-clean

.PHONY: all-release
all-release: $(release-name)

.PHONY: all-clean
all-clean: gcc-clean
all-clean: gprbuild-bootstrap-clean
all-clean: gprconfig_kb-clean
all-clean: xmlada-clean
all-clean: gprbuild-clean
all-clean: gnatcoll-core-clean
all-clean: gnatcoll-bindings-clean
all-clean: gnatcoll-db-clean
all-clean: libadalang-clean
all-clean: langkit-clean
all-clean: gtkada-clean
all-clean: gps-clean
all-clean: libadalang-tools-clean
all-clean: ada_language_server-clean
all-clean: vss-clean
all-clean: spark2014-clean
all-clean: gnat-clean
all-clean: quex-clean

#
# A L L
#
##############################################################
#
# * - S R C
#

gcc-src:
	git clone --depth=1 \
	https://github.com/gcc-mirror/gcc -b $(gcc-version) $@

xmlada-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/xmlada -b $(adacore-version) $@

gprbuild-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/gprbuild -b $(adacore-version) $@

gprconfig_kb-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/gprconfig_kb -b master $@

gtkada-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/gtkada -b $(adacore-version) $@

gnatcoll-core-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/gnatcoll-core -b $(adacore-version) $@

gnatcoll-bindings-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/gnatcoll-bindings -b $(adacore-version) $@

gnatcoll-db-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/gnatcoll-db -b $(adacore-version) $@

langkit-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/langkit -b $(libadalang-version) $@

libadalang-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/libadalang -b $(libadalang-version) $@

libadalang-tools-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/libadalang-tools -b $(adacore-version) $@

ada_language_server-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/ada_language_server -b $(adacore-version) $@

vss-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/vss -b $(adacore-version) $@

gps-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/gps -b $(adacore-version) $@

spark2014-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/spark2014 -b $(spark2014-version) $@
	cd $@ && git submodule init
	cd $@ && git submodule update

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
gprbuild-bootstrap-install: gprbuild-src xmlada-src gprconfig_kb-src
	mkdir -p gprbuild-bootstrap-build
	cp -a gprbuild-src/* gprbuild-bootstrap-build
	cd gprbuild-bootstrap-build && $(sudo) bash bootstrap.sh \
	    --with-xmlada=../xmlada-src \
            --with-kb=../gprconfig_kb-src \
            --prefix=$(prefix)
	$(sudo) rm -rf gprbuild-bootstrap-build

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
	make -C $@/sql prefix=$(prefix) $(gnatcoll-db-options) setup
	make -C $@/gnatcoll_db2ada prefix=$(prefix) $(gnatcoll-db-options) setup
	make -C $@/sqlite prefix=$(prefix) $(gnatcoll-db-options) setup
	make -C $@/xref prefix=$(prefix) $(gnatcoll-db-options) setup
	make -C $@/gnatinspect prefix=$(prefix) $(gnatcoll-db-options) setup

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
	cd $@ && python3.8 -m venv lal-venv
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
	$(sudo) rm -rf $(prefix)/bin/lal_parse
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

gps-build: gps-src libadalang-tools-src ada_language_server-src vss-src
	mkdir -p $@  $@/laltools
	cp -a $</* $@
	cp -a libadalang-tools-src/* $@/laltools
	mkdir -p $@/ada_language_server
	cp -a ada_language_server-src/* $@/ada_language_server
	mkdir -p $@/vss
	cp -a vss-src/* $@/vss
	cd $@ && ./configure --prefix=$(prefix) $(gps-options)

# gps subprojects that need to be declared in GPR_PROJECT_PATH now
sub1 = ../laltools/src
sub2 = ../ada_language_server/gnat
sub3 = ../vss/gnat

.PHONY: gps
gps: gps-build
	export GPR_PROJECT_PATH=$(sub1):$(sub2):$(sub3) \
	&& make -C $< PROCESSORS=0

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
	rm -rf $(release-loc)/$@ $(release-loc)/$@.tar.gz
	mkdir -p $(release-loc)/$@
	cp -a $(prefix)/* $(release-loc)/$@
	cd $(release-loc) && tar czf $@.tar.gz $@
	rm -rf $(release-loc)/$@

.PHONY: all-release-install
all-release-install: $(release-loc)/$(release-name).tar.gz
	mkdir -p $(prefix)
	cd $(prefix) && $(sudo) tar -x --strip-components 1 -f $(PWD)/$<

$(release-loc)/$(release-name).tar.gz: base-depends-$(os)
	if [ ! -f $@ ]; then \
	   mkdir -p $(@D); \
	   cd $(@D) && wget -q $(release-url)/$(@F); \
	fi

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

