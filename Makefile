JSLINT=jshint

SASS_OPTIONS=--style=compressed


all: build lint

build:
	sass $(SASS_OPTIONS) scss/style.scss > html/style.css
	cat thirdParty/promise-7.0.4.min.js thirdParty/jquery-1.11.3.min.js > html/thirdParty.js
	cp thirdParty/jquery-1.11.3.min.map html/

test: unitTests integrationTests

unitTests: t/*.t
	@echo -e "\nUnit Tests\n----------"
	@prove -I./lib -I./blib -It $^
	# prove -I./lib -I./blib -It t/*.t

integrationTests: t/integration/*.t
	@echo -e "\nIntegration Tests\n-----------------"
	@prove -I./lib -I./blib -It/integration -It $^

lint:
	$(JSLINT) html/twitterBot.js
