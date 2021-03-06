PROJECT=PROJECT_NAME

EXECUTABLE=$(BINDIR)/$(PROJECT)
DEPS=
TESTMAIN=src/Test.hs
INSTALLFLAGS=-j -fdevelopment --reorder-goals
MOODEVEL=-c devel.cfg
MOOTEST=-c test.cfg

EXEC=cabal exec --
RUN=$(EXEC) runghc -isrc
BINDIR=.cabal-sandbox/bin
BUILDDIR=dist
SOURCES=$(shell find src -type f -iname '*.hs')
DEPDIR=deps
SHELL=/bin/bash

.PHONY: all install clean superclean test init deps sandbox tags confirm \
	dbup dbtest dbnew dbrevert customize setup-vm build-vm

all: init install test tags

customize:
	./customize.sh

setup-vm:
	vagrant up
	vagrant provision
	vagrant ssh -c 'PATH=$$PATH:/home/vagrant/.cabal/bin:/home/vagrant/ghc/bin cabal install alex'
	vagrant ssh -c 'PATH=$$PATH:/home/vagrant/.cabal/bin:/home/vagrant/ghc/bin ghc-pkg hide resource-pool'
	vagrant ssh -c 'export PATH=$$PATH:$$HOME/.cabal/bin:$$HOME/ghc/bin; cd /vagrant; cabal install -j -fdevelopment --allow-newer --force-reinstalls'

build-vm:
	vagrant ssh -c 'export PATH=$$PATH:$$HOME/.cabal/bin:$$HOME/ghc/bin; cd /vagrant; cabal install -j -fdevelopment --allow-newer --force-reinstalls && ./dist/build/${PROJECT}/${PROJECT}'

install: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES)
	cabal install $(INSTALLFLAGS)

test:
	$(RUN) $(TESTMAIN)

run: $(EXECUTABLE)
	$(EXECUTABLE)

clean:
	rm -rf $(BUILDDIR) $(EXECUTABLE)

superclean: confirm clean
	rm -rf $(DEPDIR) .cabal-sandbox/ cabal.sandbox.config TAGS

confirm:
	@read -r -p "Are you sure? [y/N] " CONTINUE; \
	[[ ! $$CONTINUE =~ ^[Yy]$$ ]] && exit 1; echo "Continuing...";

init: sandbox deps


deps: $(patsubst %, $(DEPDIR)/%.d, $(DEPS)) $(DEPDIR)/digestive-functors

$(DEPDIR)/digestive-functors:
	git clone -b snap-upload-fix git@github.com:positioncoop/digestive-functors.git $@
	cabal sandbox add-source $(DEPDIR)/digestive-functors/digestive-functors-snap


$(DEPDIR)/%.d:
	git clone git@github.com:$*.git $@
	cabal sandbox add-source $@


sandbox: cabal.sandbox.config

cabal.sandbox.config:
	cabal sandbox init


tags: TAGS

TAGS: $(SOURCES)
	$(EXEC) haskdogs -e

dbsetup:
	sudo -u postgres psql -U postgres -d template1 -c "create user PROJECT_NAME_user with password 'DEVELOPMENT_PASSWORD';"
	sudo -u postgres psql -U postgres -d template1 -c "create database PROJECT_NAME_devel;"
	sudo -u postgres psql -U postgres -d template1 -c "create database PROJECT_NAME_test;"
	sudo -u postgres psql -U postgres -d template1 -c "grant all on database PROJECT_NAME_devel to PROJECT_NAME_user;"
	sudo -u postgres psql -U postgres -d template1 -c "grant all on database PROJECT_NAME_test to PROJECT_NAME_user;"

db:
	PGPASSWORD=DEVELOPMENT_PASSWORD psql PROJECT_NAME_devel -UPROJECT_NAME_user -hlocalhost

dbup:
	moo upgrade $(MOODEVEL)
	moo upgrade $(MOOTEST)

dbtest:
	moo test $(MOODEVEL) $(MIGRATION)
	moo test $(MOOTEST) $(MIGRATION)

dbnew:
	moo new $(MOODEVEL) $(MIGRATION)

dbrevert:
	moo revert $(MOODEVEL) $(MIGRATION)
	moo revert $(MOOTEST) $(MIGRATION)
