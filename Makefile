PROJECT=PROJECT_NAME
USER=REMOTE_USER
SERVER=PRODUCTION_DOMAIN

.PHONY: setup-dev build-dev

setup-dev:
	vagrant up
	vagrant provision
	vagrant ssh -c 'PATH=$$PATH:/home/vagrant/.cabal/bin:/home/vagrant/ghc/bin cabal install alex'
	vagrant ssh -c 'PATH=$$PATH:/home/vagrant/.cabal/bin:/home/vagrant/ghc/bin ghc-pkg hide resource-pool'
build-dev:
	vagrant ssh -c 'export PATH=$$PATH:$$HOME/.cabal/bin:$$HOME/ghc/bin; cd /vagrant; cabal install -j -fdevelopment --allow-newer --force-reinstalls && ./dist/build/${PROJECT}/${PROJECT}'



# NOTE(dbp 2014-07-20): Need to figure out how to do desktop notifications.
# test-runner:
#	vagrant ssh -c 'export PATH=$$PATH:$$HOME/.cabal/bin:$$HOME/ghc/bin; cd /vagrant; cabal exec runghc -- -isrc src/TestRunner.hs'

#test-once:
#	vagrant ssh -c 'export PATH=$$PATH:$$HOME/.cabal/bin:$$HOME/ghc/bin; cd /vagrant; cabal exec runghc -- -isrc src/Test.hs'


# NOTE(dbp 2014-07-20): deployment is more complicated - need to setup production
# machine, then to deploy, build inside vagrant box, then push out to production.
# Migrations have a similar path - build them within vagrant, then push, then migrate.

# migrate:
# 	rsync --checksum -ave 'ssh '  migrations/* ${USER}@${SERVER}:migrations
# 	ssh ${USER}@${SERVER} "/var/www/moo.sh upgrade"
# 	ssh ${USER}@${SERVER} "migrate up"


# keter-build:
# 	cabal install -j --reorder-goals
# 	cp .cabal-sandbox/bin/${PROJECT} ${PROJECT}
# 	tar czfv ${PROJECT}.keter ${PROJECT} config prod.cfg static snaplets log/_blank

# keter-deploy:
# 	scp ${PROJECT}.keter ${SERVER}:/opt/keter/incoming

# deploy: keter-build keter-deploy

clean:
	find . -iname \*.hi | xargs rm
	find . -iname \*.o | xargs rm
