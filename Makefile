# adacore-version = master
# gcc-version = master, trunk, gcc-8-branch gcc-7-branch, gcc-7_2_0-release
# prefix = /usr/local, /usr/local/gnat, /usr/gnat, etc.

release ?= 0.1.0-20190318
gcc-version ?= master
adacore-version ?= master
libadalang-version ?= stable
spark2014-version ?= fsf
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

.PHONY: default
default: all

.PHONY: install
install: all-install

.PHONY: depends
depends: base-depends

##############################################################
#
# A L L
#

.PHONY: all-src
all-src: xmlada-src
all-src: gprbuild-src
all-src: gnatcoll-core-src
all-src: gnatcoll-bindings-src
all-src: gnatcoll-db-src
all-src: libadalang-src
all-src: langkit-src
all-src: quex-src
all-src: gtkada-src
all-src: gps-src
all-src:libadalang-tools-src
all-src: spark2014-src
all-src: gnat-src
all-src: CVC4-src
all-src: Z3-src
all-src: Alt-Ergo-src

.PHONY: all-depends
all-depends: base-depends
all-depends: xmlada-depends
all-depends: gprbuild-depends
all-depends: gnatcoll-core-depends
all-depends: gnatcoll-bindings-depends
all-depends: gnatcoll-db-depends
all-depends: libadalang-depends
all-depends: gtkada-depends
all-depends: gps-depends
all-depends: spark2014-depends

.PHONY: all
all: xmlada
all: gprbuild
all: gnatcoll-core
all: gnatcoll-bindings
all: gnatcoll-db
all: libadalang
all: gtkada
all: gps
all: spark2014

.PHONY: all-install
all-install: xmlada-install
all-install: gprbuild-install
all-install: gnatcoll-core-install
all-install: gnatcoll-bindings-install
all-install: gnatcoll-db-install
all-install: libadalang-install
all-install: gtkada-install
all-install: gps-install
all-install: spark2014-install

#
# A L L
#
##############################################################
#
# B O O T S T R A P
#

.PHONY: bootstrap-depends
bootstrap-depends: gcc-depends all-depends

.PHONY: bootstrap
bootstrap: gcc gcc-install
bootstrap: gprbuild-bootstrap-install
bootstrap: xmlada xmlada-install
bootstrap: gprbuild gprbuild-install
bootstrap: gnatcoll-core gnatcoll-core-install
bootstrap: gnatcoll-bindings gnatcoll-bindings-install
bootstrap: gnatcoll-sql gnatcoll-sql-install
bootstrap: gnatcoll-db-build
bootstrap: gnatcoll-gnatcoll_db2ada gnatcoll-gnatcoll_db2ada-install
bootstrap: gnatcoll-sqlite gnatcoll-sqlite-install
bootstrap: gnatcoll-xref gnatcoll-xref-install
bootstrap: gnatcoll-gnatinspect gnatcoll-gnatinspect-install
bootstrap: libadalang libadalang-install
bootstrap: gtkada gtkada-install
bootstrap: gps gps-install
bootstrap: spark2014 spark2014-install

#
# B O O T S T R A P
#
##############################################################
#
# R E L E A S E
#

.PHONY: release
release: $(release-name)

.PHONY: $(release-name)
$(release-name):
	mkdir -p $(release-loc)
	cd $(release-loc) && rm -rf $@ $@.tar.gz
	mkdir -p $(release-loc)/$@
	cp -r $(prefix)/* $(release-loc)/$@/
	cd $(release-loc) && tar czf $@.tar.gz $@

.PHONY: release-install
release-install: release-download
	$(sudo) cp -a $(release-loc)/$(release-name)/* $(prefix)/

.PHONY: release-download
release-download: $(release-loc)/$(release-name)

$(release-loc)/$(release-name):
	rm -rf $@ $@.tar.gz
	mkdir -p $(@D)
	cd $(@D) && wget -q $(release-url)/$(release-tag)/$(@F).tar.gz
	cd $(@D) && tar xf $(@F).tar.gz

#
# R E L E A S E
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
# C L E A N
#
##############################################################
#
# E X T E R N A L  B U I L D  D E P E N D E N C I E S
#

.PHONY: base-depends
base-depends: sudo
	$(sudo) apt-get -qq -y install \
	    make git wget build-essential

.PHONY: sudo
sudo: /usr/bin/sudo

/usr/bin/sudo:
	apt-get -qq -y install sudo

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
	    pkg-config libglib2.0-dev libpango1.0-dev \
	    libatk1.0-dev libgtk-3-dev \
	    python-dev python-gi-dev python-cairo-dev \
	    libclang-dev libgmp-dev

.PHONY: spark2014-depends
spark2014-depends: base-depends
	$(sudo) apt-get -qq -y install \
	    ocaml libocamlgraph-ocaml-dev \
	    menhir libmenhir-ocaml-dev libzarith-ocaml-dev \
	    libzip-ocaml-dev ocplib-simplex-ocaml-dev \
	    cvc4 z3 alt-ergo

.PHONY: CVC4-depends
CVC4-depends: base-depends
	$(sudo) apt-get -qq -y install \
	libgmp-dev libantlr3c-dev libboost-dev

.PHONY: Z3-depends
Z3-depends: base-depends
	$(sudo) apt-get -qq -y install \

.PHONY: Alt-Ergo-depends
Alt-Ergo-depends: base-depends
	$(sudo) apt-get -qq -y install \

#
# E X T E R N A L  B U I L D  D E P E N D E N C I E S
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
spark2014-src: github-src/adacore/spark2014/$(spark2014-version)
gnat-src: github-src/steve-cs/gnat/master
CVC4-src: github-src/adacore/CVC4/$(adacore-version)
Z3-src: github-src/adacore/Z3/$(adacore-version)
Alt-Ergo-src: github-src/adacore/Alt-Ergo/$(adacore-version)

quex-src: downloads/quex-0.65.4

# linking github-src/<account>/<repository>/<branch> from github

github-src/%/$(gcc-version)        \
github-src/%/$(adacore-version)    \
github-src/%/$(libadalang-version) \
github-src/%/$(spark2014-version)  \
    : github-repo/%
	cd github-repo/$(@D:github-src/%=%) && git reset --hard $(@F)
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
# * - B U I L D / I N S T A L L
#

gcc-build: gcc-src
	mkdir -p $@
	rm -rf $@/*
	cd $< && ./contrib/download_prerequisites
	cd $@ && ../$</configure \
	    --host=$(host) --build=$(build) --target=$(target) \
	    --prefix=$(prefix) --enable-languages=c,c++,ada \

.PHONY: gcc
gcc: gcc-build gcc-src
	make -C $< -j$(gcc-jobs)

.PHONY: gcc-install
gcc-install:
	$(sudo) make -C gcc-build install


#####

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

.PHONY: gnatcoll-bindings
gnatcoll-bindings: gnatcoll-bindings-build
	cd $</gmp && ./setup.py build
	cd $</iconv && export GNATCOLL_ICONV_OPT=$(iconv-opt) && ./setup.py build
	cd $</python && ./setup.py build
	cd $</readline && ./setup.py build --accept-gpl
	cd $</syslog && ./setup.py build

.PHONY: gnatcoll-bindings-install
gnatcoll-bindings-install:
	cd gnatcoll-bindings-build/gmp && $(sudo) ./setup.py install --prefix=$(prefix)
	cd gnatcoll-bindings-build/iconv && export GNATCOLL_ICONV_OPT=$(iconv-opt) && $(sudo) ./setup.py install --prefix=$(prefix)
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

gps-build: gps-src libadalang-tools-src
	mkdir -p $@  $@/laltools
	cp -a $</* $@
	cp -a libadalang-tools-src/* $@/laltools
	cd $@ && ./configure \
	    --prefix=$(prefix) \
	    --with-clang=/usr/lib/llvm-$(llvm-version)/lib/

.PHONY: gps
gps: gps-build
	make -C $< PROCESSORS=0


.PHONY: gps-install
gps-install: gps-python-fixup
	$(sudo) make -C gps-build install

.PHONY: gps-python-fixup
gps-python-fixup:
	$(sudo) mkdir -p $(prefix)/lib/python2.7
	#
	# gps is looking in $(prefix)/lib/python2.7/ to resolve dependencies
	# debian/ubuntu apt-get is installing them in /usr/lib/python2.7
	# copy the whole pile over so that we don't have to hack PYTHONPATH
	#
	$(sudo) cp -a /usr/lib/python2.7/* $(prefix)/lib/python2.7
	#
	# libadalang build is leaving some bits in $(prefix)/python/
	# put them in $(prefix)/lib/python2.7/ where they will be found
	#
	$(sudo) cp -a $(prefix)/python/libadalang $(prefix)/lib/python2.7
	$(sudo) cp -a $(prefix)/python/setup.py $(prefix)/lib/python2.7/libadalang

#####

spark2014-build: spark2014-src gnat-src
	cd $< && git submodule init
	cd $< && git submodule update
	mkdir -p $@
	cp -a $</* $@
	rm -rf $@/gnat2why/gnat_src
	ln -s ../../gnat-src $@/gnat2why/gnat_src
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

