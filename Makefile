.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs example temp prod

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make logstash       -  run logstash docker container

logstash: logstashTAG NAME logstashCID

logstashCID:
	$(eval NAME := $(shell cat NAME))
	$(eval logstashTAG := $(shell cat logstashTAG))
	@docker run --name=$(NAME)-logstash \
	--cidfile="logstashCID" \
	-d \
	-p 5000:5000 \
	--restart=always \
	-v "$PWD":/config-dir \
	-t $(logstashTAG) logstash -f /config-dir/logstash.conf

kill:
	-@docker kill `cat logstashCID`

rm-image:
	-@docker rm `cat logstashCID`
	-@rm logstashCID

rm: kill rm-image

clean: rmall

enterlogstash:
	docker exec -i -t `cat logstashCID` /bin/bash

logslogstash:
	docker logs -f `cat logstashCID`

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

logstashTAG:
	@while [ -z "$$logstashTAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container, hint `make example` [logstashTAG]: " logstashTAG; echo "$$logstashTAG">>logstashTAG; cat logstashTAG; \
	done ;

rmall: rm

example:
	cp -i logstashTAG.example logstashTAG
