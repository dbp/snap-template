PROJECT=project
USER=host
SERVER=production.com

all:
	cabal install -j -fdevelopment --reorder-goals && ./.cabal-sandbox/bin/${PROJECT}

run:
	./.cabal-sandbox/bin/${PROJECT}

test:
	cabal exec runghc -- -isrc src/TestRunner.hs

test-once:
	cabal exec runghc -- -isrc src/Test.hs


migrate:
	rsync --checksum -ave 'ssh '  migrations/* ${USER}@${SERVER}:migrations
	ssh ${USER}@${SERVER} "/var/www/moo.sh upgrade"
	ssh ${USER}@${SERVER} "migrate up"


keter-build:
	cabal install -j --reorder-goals
	cp .cabal-sandbox/bin/${PROJECT} ${PROJECT}
	tar czfv ${PROJECT}.keter ${PROJECT} config prod.cfg static snaplets log/_blank

keter-deploy:
	scp ${PROJECT}.keter ${SERVER}:/opt/keter/incoming

deploy: keter-build keter-deploy

clean:
	find . -iname \*.hi | xargs rm
	find . -iname \*.o | xargs rm
