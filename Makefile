##############################################################
# 
# C O N F I G
#

release ?= cs-20210208
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

host  ?= x86_64-pc-linux-gnu
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
langkit-options ?=
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

.PHONY: all

.PHONY: install

.PHONY: bootstrap

.PHONY: release
release: clean prefix-clean depends bootstrap release-cut

.PHONY: release-install

.PHONY: clean

.PHONY: bisect-test-clean
bisect-test-clean: prefix-clean
	rm -rf *-build

.PHONY: bisect-test
bisect-test: bisect-test-clean
bisect-test: gcc gcc-install
bisect-test: gprbuild-bootstrap-install
bisect-test: xmlada

#
# E N D   T O P   L E V E L
#
##############################################################
#
# D E P E N D S
#

depends: base-depends-$(os)
depends: gcc-depends-$(os)
depends: xmlada-depends-$(os)
depends: gprbuild-depends-$(os)
depends: gnatcoll-core-depends-$(os)
depends: gnatcoll-bindings-depends-$(os)
depends: gnatcoll-db-depends-$(os)
depends: langkit-depends-$(os)
depends: libadalang-depends-$(os)
depends: gtkada-depends-$(os)
depends: gps-depends-$(os)
depends: spark2014-depends-$(os)

#### default additional dependencies for each component is empty

%-depends-$(os): ;

##### os=debian dependency support

.PHONY: base-depends-debian
base-depends-debian:
	if [ ! -f /usr/bin/sudo ]; then \
	   apt-get -qq -y install sudo; \
	fi
	$(sudo) apt-get -qq -y install \
	    make git wget build-essential \
	    python-is-python3 \
	    python3-dev python3-venv \
	    libgmp-dev

.PHONY: gcc-depends-debian
gcc-depends-debian:
	$(sudo) apt-get -qq -y install \
	    gnat gawk flex bison libc6-dev libc6-dev-i386 libzstd-dev \
	    libmpfr-dev libmpc-dev libisl-dev

.PHONY: gnatcoll-bindings-depends-debian
gnatcoll-bindings-depends-debian:
	$(sudo) apt-get -qq -y install \
	    zlib1g-dev libreadline-dev

.PHONY: gtkada-depends-debian
gtkada-depends-debian:
	$(sudo) apt-get -qq -y install \
	    pkg-config libgtk-3-dev

.PHONY: gps-depends-debian
gps-depends-debian:
	$(sudo) apt-get -qq -y install \
	    pkg-config libglib2.0-dev libpango1.0-dev \
	    libatk1.0-dev libgtk-3-dev \
	    python-gi-dev python3-cairo-dev \
	    libclang1

.PHONY: spark2014-depends-debian
spark2014-depends-debian:
	$(sudo) apt-get -qq -y install \
	    libnum-ocaml-dev \
	    ocaml libocamlgraph-ocaml-dev \
	    menhir libmenhir-ocaml-dev libzarith-ocaml-dev \
	    libzip-ocaml-dev ocplib-simplex-ocaml-dev \
	    libyojson-ocaml-dev \
	    ocaml-findlib \
	    cvc4 z3 alt-ergo

#
# E N D   D E P E N D S
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
	cd $@ && patch -f -p1 -i ../$@-patch.diff

gprconfig_kb-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/gprconfig_kb -b $(adacore-version) $@

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

spawn-src:
	git clone --depth=1 \
	https://github.com/$(adacore-repos)/spawn -b $(adacore-version) $@

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

all: gcc
install: gcc-install
bootstrap: gcc gcc-install

gcc-build: gcc-src
	mkdir -p $@
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

bootstrap: gprbuild-bootstrap
bootstrap: gprbuild-bootstrap-install

.PHONY: gprbuild-bootstrap-build
gprbuild-bootstrap-build: gprbuild-src
	mkdir -p $@
	cp -a $</* $@

.PHONY: gprbuild-bootstrap
gprbuild-bootstrap: gprbuild-bootstrap-build xmlada-src gprconfig_kb-src
	cd $< && bash bootstrap.sh \
	    --build \
	    --with-xmlada=../xmlada-src \
	    --with-kb=../gprconfig_kb-src \
	    --prefix=$(prefix)

.PHONY: gprbuild-bootstrap-install
gprbuild-bootstrap-install:
	cd gprbuild-bootstrap-build && $(sudo) bash bootstrap.sh \
	    --install \
	    --with-kb=../gprconfig_kb-src \
	    --prefix=$(prefix)
	#$(sudo) rm -rf gprbuild-bootstrap-build/share/gprconfig
####

all: xmlada
install: xmlada-install
bootstrap: xmlada xmlada-install

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

all: gprbuild
install: gprbuild-install
bootstrap: gprbuild gprbuild-install

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

all: gnatcoll-core
install: gnatcoll-core-install
bootstrap: gnatcoll-core gnatcoll-core-install

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

all: gnatcoll-bindings
install: gnatcoll-bindings-install
bootstrap: gnatcoll-bindings gnatcoll-bindings-install

gnatcoll-bindings-build: gnatcoll-bindings-src
	mkdir -p $@
	cp -a $</* $@

.PHONY: gnatcoll-bindings
gnatcoll-bindings: gnatcoll-bindings-build
	cd $</gmp && ./setup.py build $(gnatcoll-bindings-options)
	cd $</iconv && ./setup.py build $(gnatcoll-bindings-options)
	cd $</python3 && ./setup.py build $(gnatcoll-bindings-options)
	cd $</readline && ./setup.py build --accept-gpl $(gnatcoll-bindings-options)
	cd $</syslog && ./setup.py build $(gnatcoll-bindings-options)

.PHONY: gnatcoll-bindings-install
gnatcoll-bindings-install:
	cd gnatcoll-bindings-build/gmp && $(sudo) ./setup.py install --prefix=$(prefix)
	cd gnatcoll-bindings-build/iconv && $(sudo) ./setup.py install --prefix=$(prefix)
	cd gnatcoll-bindings-build/python3 && $(sudo) ./setup.py install --prefix=$(prefix)
	cd gnatcoll-bindings-build/readline && $(sudo) ./setup.py install --prefix=$(prefix)
	cd gnatcoll-bindings-build/syslog && $(sudo) ./setup.py install --prefix=$(prefix)

#####

all: gnatcoll-db
install: gnatcoll-db-install
bootstrap: gnatcoll-sql gnatcoll-sql-install
bootstrap: gnatcoll-gnatcoll_db2ada gnatcoll-gnatcoll_db2ada-install
bootstrap: gnatcoll-sqlite gnatcoll-sqlite-install
bootstrap: gnatcoll-xref gnatcoll-xref-install
bootstrap: gnatcoll-gnatinspect gnatcoll-gnatinspect-install

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

all: langkit
install: langkit-install
bootstrap: langkit langkit-install

langkit-build: langkit-src
	mkdir -p $@
	cp -a $</* $@
	cd $@ \
	    && python -mvenv env \
	    && . env/bin/activate \
	    && pip install wheel \
	    && pip install -r REQUIREMENTS.dev \
	    && pip install . \
	    && deactivate

.PHONY: langkit
langkit: langkit-build
	cd $< \
	    && . env/bin/activate \
	    && python manage.py build-langkit-support $(langkit-options) \
	    && deactivate

.PHONY: langkit-install
langkit-install: clean-langkit-prefix
	cd langkit-build \
	    && $(sudo) sh -c ". env/bin/activate \
	    && python manage.py install-langkit-support $(prefix) \
	    && deactivate"

.PHONY: clean-langkit-prefix
clean-langkit-prefix:
	# clean up old langkit install if there
	$(sudo) rm -rf $(prefix)/include/langkit*
	$(sudo) rm -rf $(prefix)/lib/langkit*
	$(sudo) rm -rf $(prefix)/share/gpr/langkit*
	$(sudo) rm -rf $(prefix)/share/gpr/manifests/langkit*

#####

all: libadalang
install: libadalang-install
bootstrap: libadalang libadalang-install

libadalang-build: libadalang-src langkit-src
	mkdir -p $@
	cp -a $</* $@
	cd $@ \
	    && python -mvenv env \
	    && . env/bin/activate \
	    && pip install wheel \
	    && pip install -r REQUIREMENTS.dev \
	    && mkdir -p langkit \
	    && cp -a ../langkit-src/* langkit \
	    && deactivate

.PHONY: libadalang
libadalang: libadalang-build
	cd $< \
	    && . env/bin/activate \
	    && python manage.py make $(libadalang-options) \
	    && deactivate

.PHONY: libadalang-install
libadalang-install: clean-libadalang-prefix
	cd libadalang-build \
	    && $(sudo) sh -c ". env/bin/activate \
	    && python manage.py install $(prefix) \
	    && deactivate"

PHONY: clean-libadalang-prefix
clean-libadalang-prefix:
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

all: gtkada
install: gtkada-install
bootstrap: gtkada gtkada-install

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

all: gps
install: gps-install
bootstrap: gps gps-install

gps-build: gps-src libadalang-tools-src \
	ada_language_server-src vss-src spawn-src \
	gps-prefix-patch1 gps-prefix-patch2
	mkdir -p $@  $@/laltools
	cp -a $</* $@
	cp -a libadalang-tools-src/* $@/laltools
	mkdir -p $@/ada_language_server
	cp -a ada_language_server-src/* $@/ada_language_server
	mkdir -p $@/vss
	cp -a vss-src/* $@/vss
	mkdir -p $@/spawn
	cp -a spawn-src/* $@/spawn
	cd $@ && ./configure --prefix=$(prefix) $(gps-options)

# gps subprojects that need to be declared in GPR_PROJECT_PATH now
sub1 = ../laltools/src
sub2 = ../ada_language_server/gnat
sub3 = ../vss/gnat
sub4 = ../spawn/gnat

.PHONY: gps
gps: gps-build
	export GPR_PROJECT_PATH=$(sub1):$(sub2):$(sub3):$(sub4) \
	&& make -C $< PROCESSORS=0

.PHONY: gps-install
gps-install: gps-prefix-patch3
	$(sudo) make -C gps-build install

.PHONY: gps-prefix-patch1
gps-prefix-patch1:
	#
	# patch
	# copy gps dependencies from /usr/lib to $(prefix)/lib
	# so that gps can find them.
	#
	$(sudo) mkdir -p $(prefix)/lib
	$(sudo) rm -rf $(prefix)/lib/libclang*
	$(sudo) cp /usr/lib/*/libclang-*.so.1 $(prefix)/lib
	cd $(prefix)/lib && $(sudo) ln -sf libclang-*.so.1 libclang.so
	$(sudo) mkdir -p $(prefix)/lib/python3.8
	$(sudo) cp -a /usr/lib/python3.8/* $(prefix)/lib/python3.8

.PHONY: gps-prefix-patch2
gps-prefix-patch2:
	#
	# patch
	# libadalang install is leaving some bits in $(prefix)/python/
	# put them in $(prefix)/lib/python3.8/ where they will be found
	# by gps at run (or build?) time.
	#
	$(sudo) mkdir -p $(prefix)/lib/python3.8
	$(sudo) cp -a $(prefix)/python/libadalang $(prefix)/lib/python3.8
	$(sudo) cp -a $(prefix)/python/setup.py $(prefix)/lib/python3.8/libadalang

.PHONY: gps-prefix-patch3
gps-prefix-patch3:
	#
	# PATCH - copy shared libraries for ada_language_server and laltools
	#         so that gnatstudio will startup.  This will eventually be
	#         fixed when ada_language_server and laltools get built and
	#         installed separately as libraries.
	#
	$(sudo) mkdir -p $(prefix)/lib/
	cd gps-build/spawn/.libs/spawn_glib/relocatable \
	   && $(sudo) cp -a libspawn_glib.so $(prefix)/lib
	cd gps-build/laltools/lib \
	   && $(sudo) cp -a liblal_tools.so $(prefix)/lib

#####

all: spark2014
install: spark2014-install
bootstrap: spark2014 spark2014-install

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

.PHONY: release-cut
release-cut: $(release-name)

.PHONY: $(release-name)
$(release-name):
	rm -rf $(release-loc)/$@ $(release-loc)/$@.tar.gz
	mkdir -p $(release-loc)/$@
	cp -a $(prefix)/* $(release-loc)/$@
	cd $(release-loc) && tar czf $@.tar.gz $@
	rm -rf $(release-loc)/$@

.PHONY: release-install
release-install: $(release-loc)/$(release-name).tar.gz depends
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

clean:
	rm -rf *-src *-build

%-clean:
	rm -rf $(@:%-clean=%) $(@:%-clean=%)-src $(@:%-clean=%)-build

.PHONY: prefix-clean
prefix-clean:
	$(sudo) rm -rf $(prefix)/*
	$(sudo) mkdir -p $(prefix)

#
# C L E A N
#
##############################################################

