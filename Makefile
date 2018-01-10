# version = master
# gcc-version = master, gcc-7-branch, gcc-7_2_0-release
# prefix = /usr/local/gnat, /usr/gnat, etc.

release ?= 0.1.0-20180109
release-loc ?= release

version ?= master
gcc-version ?= gcc-7-branch
prefix ?= /usr/local/gnat

# Debian stable configuration
#
llvm-version ?= 3.8
iconv-opt ?= "-lc"

.PHONY: default
default: all

.PHONY: install
install: all-install

##############################################################
#
# P A T C H E S
#

.PHONY: gnatcoll-fix-gpr-links
gnatcoll-fix-gpr-links:
	cd $(prefix)/share/gpr && ln -sf gnatcoll-gmp.gpr gnatcoll_gmp.gpr
	cd $(prefix)/share/gpr && ln -sf gnatcoll-iconv.gpr gnatcoll_iconv.gpr
	cd $(prefix)/share/gpr && ln -sf gnatcoll-python.gpr gnatcoll_python.gpr
	cd $(prefix)/share/gpr && ln -sf gnatcoll-readline.gpr gnatcoll_readline.gpr
	cd $(prefix)/share/gpr && ln -sf gnatcoll-syslog.gpr gnatcoll_syslog.gpr
	cd $(prefix)/share/gpr && ln -sf gnatcoll-sqlite.gpr gnatcoll_sqlite.gpr
	cd $(prefix)/share/gpr && ln -sf gnatcoll-xref.gpr gnatcoll_xref.gpr

gnatcoll-db-build: gnatcoll-db-src
	mkdir -p $@
	cp -r $</* $@
	# patch to enable gnatcoll-gnatinspect build
	cd $@ && patch -p1 < ../patches/gnatcoll-db-src-patch-1

gps-build: gps-src libadalang-tools-build gcc-src
	mkdir -p $@
	cp -r $</* $@
	ln -sf $(PWD)/libadalang-tools-build $</laltools
	# patch so that gnat_switches.py
	cp gcc-src/gcc/ada/doc/gnat_ugn/building_executable_programs_with_gnat.rst gps-build/gnat/
	# patch to disable libadalang from the build
	cd $@ && patch -p1 < ../patches/gps-src-patch-1

.PHONY: gps-install
gps-install: gps-build
	make -C $< prefix=$(prefix) install
	# patch to disable lal support at runtime
	cd $(prefix)/share/gps/support/core/                \
	&& rm -rf lal.py-disable                            \
	&& mv lal.py lal.py-disable
	# patch to disable clang support at runtime
	cd $(prefix)/share/gps/support/languages/           \
	&& rm -rf clang_support.py-disable                  \
	&& mv clang_support.py clang_support.py-disable

#
# E N D   P A T C H E S
#
##############################################################

.PHONY: install-prerequisites
install-prerequisites:
	apt-get -y install \
	build-essential gnat gawk git flex bison \
	libgmp-dev libmpfr-dev libmpc-dev libisl-dev zlib1g-dev \
	libreadline-dev \
	postgresql libpq-dev \
	virtualenv \
	pkg-config libglib2.0-dev libpango1.0-dev libatk1.0-dev libgtk-3-dev \
	python-dev python-pip python-gobject-dev python-cairo-dev \
	libclang-dev

.PHONY: clean
clean: 
	rm -rf *-src *-build

.PHONY: dist-clean
dist-clean : clean
	rm -rf *-cache

%-clean:
	rm -rf $(@:%-clean=%)-src $(@:%-clean=%)-build

.PHONY: bootstrap-clean
bootstrap-clean: clean
	rm -rf $(prefix)/*

.PHONY: bootstrap-install
bootstrap-install: |                                      \
gcc-bootstrap gcc-install                                 \
gprbuild-bootstrap-install                                \
xmlada xmlada-install                                     \
gprbuild gprbuild-install                                 \
gnatcoll-core gnatcoll-core-install                       \
gnatcoll-bindings gnatcoll-bindings-install               \
gnatcoll-gnatcoll_db2ada gnatcoll-gnatcoll_db2ada-install \
gnatcoll-sqlite gnatcoll-sqlite-install                   \
gnatcoll-xref gnatcoll-xref-install                       \
gnatcoll-gnatinspect gnatcoll-gnatinspect-install         \
gnatcoll-fix-gpr-links                                    \
libadalang libadalang-install                             \
gtkada gtkada-install                                     \
gps gps-install

.PHONY: all
all: \
xmlada                   \
gprbuild                 \
gnatcoll-core            \
gnatcoll-bindings        \
gnatcoll-gnatcoll_db2ada \
gnatcoll-sqlite          \
gnatcoll-xref            \
gnatcoll-gnatinspect     \
libadalang               \
gtkada                   \
gps

.PHONY: all-install
all-install: \
xmlada-install                   \
gprbuild-install                 \
gnatcoll-core-install            \
gnatcoll-bindings-install        \
gnatcoll-gnatcoll_db2ada-install \
gnatcoll-sqlite-install          \
gnatcoll-xref-install            \
gnatcoll-gnatinspect             \
libadalang-install               \
gtkada-install                   \
gps-install

.PHONY: release
release: $(release-loc)/gnat-build_tools-$(release)

.PHONY: $(release-loc)/gnat-build_tools-$(release)
$(release-loc)/gnat-build_tools-$(release):
	rm -rf $@ $@.tar.gz
	mkdir -p $@
	cp -r $(prefix)/* $@/
	cd $(@D) && tar czf $(@F).tar.gz $(@F)

##############################################################
#
# * - S R C
#

# most %-src are just symbolic links to their dependents

%-src:
	if [ "x$<" = "x" ]; then false; fi
	ln -s $< $@

# from github

gcc-src: github-src/gcc-mirror/gcc/$(gcc-version)

xmlada-src: github-src/adacore/xmlada/$(version)
gprbuild-src: github-src/adacore/gprbuild/$(version)
gtkada-src: github-src/adacore/gtkada/$(version)
gnatcoll-core-src: github-src/adacore/gnatcoll-core/$(version)
gnatcoll-bindings-src: github-src/adacore/gnatcoll-bindings/$(version)
gnatcoll-db-src: github-src/adacore/gnatcoll-db/$(version)
langkit-src: github-src/adacore/langkit/$(version)
libadalang-src: github-src/adacore/libadalang/$(version)
libadalang-tools-src: github-src/adacore/libadalang-tools/$(version)
gps-src: github-src/adacore/gps/$(version)

quex-src: github-src/steve-cs/quex/0.65.4

# aliases to other %-src

xmlada-bootstrap-src: xmlada-src
gprbuild-bootstrap-src: gprbuild-src

# linking github-src/<account>/<repository>/<branch> from github
# get the repository, update it, and checkout the requested branch

# github branches where we want to pull updates if available
#
github-src/%/0.65.4            \
github-src/%/gcc-7-branch      \
github-src/%/master: github-cache/%
	cd github-cache/$(@D:github-src/%=%) && git checkout -f $(@F)
	cd github-cache/$(@D:github-src/%=%) && git pull
	rm -rf $(@D)/*
	mkdir -p $(@D)
	ln -sf $(PWD)/github-cache/$(@D:github-src/%=%) $@

# github tags, e.g. releases, which don't have updates to pull
#
github-src/%/gcc-7_2_0-release: github-cache/%
	cd github-cache/$(@D:github-src/%=%) && git checkout -f $(@F)
	rm -rf $(@D)/*
	mkdir -p $(@D)
	ln -sf $(PWD)/github-cache/$(@D:github-src/%=%) $@


# Clone github-cache/<account>/<repository> from github.com

.PRECIOUS: github-cache/%
github-cache/%:
	rm -rf $@
	mkdir -p $(@D)
	cd $(@D) && git clone https://github.com/$(@:github-cache/%=%).git
	touch $@

#
# * - S R C
#
##############################################################
#
# * - B U I L D
#

%-build: %-src
	mkdir -p $@
	cp -r $</* $@

gcc-build:
	mkdir -p $@

gnatcoll-gnatcoll_db2ada-build \
gnatcoll-sqlite-build \
gnatcoll-xref-build \
gnatcoll-gnatinspect-build \
: gnatcoll-db-build
	ln -sf $< $@

#
# * - B U I L D
#
##############################################################
#
#

.PHONY: %-install
%-install: %-build
	make -C $< prefix=$(prefix) install

.PHONY: gcc-bootstrap
gcc-bootstrap: gcc-build gcc-src
	cd $< && ../gcc-src/configure \
	--prefix=$(prefix) --enable-languages=c,c++,ada \
	--enable-bootstrap --disable-multilib \
	--enable-shared --enable-shared-host
	cd $<  && make -j4

.PHONY: gcc
gcc: gcc-build gcc-src
	cd $< && ../gcc-src/configure \
	--prefix=$(prefix) --enable-languages=c,c++,ada \
	--disable-bootstrap --disable-multilib \
	--enable-shared --enable-shared-host
	cd $<  && make -j4

.PHONY: gprbuild-bootstrap-install        
gprbuild-bootstrap-install: gprbuild-bootstrap-build xmlada-bootstrap-build
	cd $<  && ./bootstrap.sh \
	--with-xmlada=../xmlada-bootstrap-build --prefix=$(prefix)

.PHONY: xmlada
xmlada: xmlada-build
	cd $< && ./configure --prefix=$(prefix)
	make -C $< all

.PHONY: gprbuild
gprbuild: gprbuild-build
	make -C $< prefix=$(prefix) setup
	make -C $< all
	make -C $< libgpr.build

.PHONY: gprbuild-install
gprbuild-install: gprbuild-build
	make -C $< install
	make -C $< libgpr.install

.PHONY: gtkada
gtkada: gtkada-build
	cd $< && ./configure --prefix=$(prefix)
	make -C $< PROCESSORS=0

.PHONY: gnatcoll-core
gnatcoll-core: gnatcoll-core-build
	make -C $< setup
	make -C $<

.PHONY: gnatcoll-core-install
gnatcoll-core-install: gnatcoll-core-build
	make -C $< prefix=$(prefix) install

.PHONY: gnatcoll-bindings
gnatcoll-bindings: gnatcoll-bindings-build
	cd $</gmp && ./setup.py build
	cd $</iconv && export GNATCOLL_ICONV_OPT=$(iconv-opt) && ./setup.py build
	cd $</python && ./setup.py build
	cd $</readline && ./setup.py build --accept-gpl
	cd $</syslog && ./setup.py build

.PHONY: gnatcoll-bindings-install
gnatcoll-bindings-install: gnatcoll-bindings-build
	cd $</gmp && ./setup.py install
	cd $</iconv && export GNATCOLL_ICONV_OPT=$(iconv-opt) && ./setup.py install
	cd $</python && ./setup.py install
	cd $</readline && ./setup.py install
	cd $</syslog && ./setup.py install

.PHONY:
gnatcoll-%: gnatcoll-%-build
	# % = $(<:gnatcoll-%-build=%)
	make -C $</$(<:gnatcoll-%-build=%) setup
	make -C $</$(<:gnatcoll-%-build=%)

.PHONY: gnatcoll-%-install
gnatcoll-%-install: gnatcoll-%-build
	make -C $</$(<:gnatcoll-%-build=%) install

.PHONY: libadalang
libadalang: libadalang-build langkit-src quex-src
	cd $< && virtualenv lal-venv
	cd $< && . lal-venv/bin/activate \
	&& pip install -r REQUIREMENTS.dev \
	&& mkdir -p lal-venv/src/langkit \
	&& rm -rf lal-venv/src/langkit/* \
	&& cp -r ../langkit-src/* lal-venv/src/langkit \
	&& export QUEX_PATH=$(PWD)/quex-src \
	&& ada/manage.py make \
	&& deactivate

.PHONY: libadalang-install
libadalang-install: libadalang-build clean-libadalang-prefix
	cd $< && . lal-venv/bin/activate \
	&& export QUEX_PATH=$(PWD)/quex-src \
	&& ada/manage.py install $(prefix) \
	&& deactivate


.PHONY: clean-libadalang-prefix
clean-libadalang-prefix:
	# clean up old langkit install if there
	rm -rf $(prefix)/include/langkit*
	rm -rf $(prefix)/lib/langkit*
	rm -rf $(prefix)/share/gpr/langkit*
	rm -rf $(prefix)/share/gpr/manifests/langkit*
	# clean up old libadalang install if there
	rm -rf $(prefix)/include/libadalang*
	rm -rf $(prefix)/lib/libadalang*
	rm -rf $(prefix)/share/gpr/libadalang*
	rm -rf $(prefix)/share/gpr/manifests/libadalang*
	rm -rf $(prefix)/python/libadalang*
	# clean up old Mains project if there
	rm -rf $(prefix)/share/gpr/manifests/mains
	rm -rf $(prefix)/bin/parse
	rm -rf $(prefix)/bin/navigate
	rm -rf $(prefix)/bin/gnat_compare
	rm -rf $(prefix)/bin/nameres

.PHONY: gps
gps: gps-build
	cd $< && ./configure \
	--prefix=$(prefix) \
	--with-clang=/usr/lib/llvm-$(llvm-version)/lib/ 
	make -C $< PROCESSORS=0
#
# gps (master) currently doesn't run
# it's missing a number of run time dependencies
# below is the hack that allowed the gpl-2017 branch to run on Debian
#
.PHONY: gps-run
gps-run:
	export PYTHONPATH=/usr/lib/python2.7:/usr/lib/python2.7/plat-x86_64-linux-gnu:/usr/lib/python2.7/dist-packages \
	&& gps

#
# * - C L E A N ,  * ,  * - I N S T A L L
#
##############################################################
