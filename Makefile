.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs example temp prod

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make logstash       -  run logstash docker container

logstash: logstashTAG NAME logstashCID

elasticsearch: DATADIR elasticsearchTAG NAME elasticsearchCID

kibana: DATADIR kibanaTAG NAME kibanaCID

logstashCID:
	$(eval NAME := $(shell cat NAME))
	$(eval DATADIR := $(shell cat DATADIR))
	$(eval logstashTAG := $(shell cat logstashTAG))
	@docker run --name=$(NAME)-logstash \
	--cidfile="logstashCID" \
	--link $(NAME)-elasticsearch:elasticsearch \
	-d \
	-p 5000:5000 \
	--restart=always \
	-v "$(DATADIR)/logstash/conf":/config-dir \
	-t $(logstashTAG) logstash -f /config-dir/logstash.conf

elasticsearch: elasticsearchTAG NAME elasticsearchCID

elasticsearchCID:
	$(eval NAME := $(shell cat NAME))
	$(eval DATADIR := $(shell cat DATADIR))
	$(eval elasticsearchTAG := $(shell cat elasticsearchTAG))
	@docker run --name=$(NAME)-elasticsearch \
	--cidfile="elasticsearchCID" \
	-d \
	-p 9200:9200 \
	-p 9300:9300 \
	--restart=always \
	-v "$(DATADIR)/elasticsearch/config":/usr/share/elasticsearch/config \
	-v "$(DATADIR)/elasticsearch/esdata":/usr/share/elasticsearch/data \
	-t $(elasticsearchTAG) elasticsearch

kibana: kibanaTAG NAME kibanaCID

kibanaCID:
	$(eval NAME := $(shell cat NAME))
	$(eval kibanaTAG := $(shell cat kibanaTAG))
	@docker run --name=$(NAME)-kibana \
	--cidfile="kibanaCID" \
	--link $(NAME)-elasticsearch:elasticsearch \
	-d \
	-p 5601:5601 \
	--restart=always \
	-t $(kibanaTAG) kibana

kill:
	-@docker kill `cat logstashCID`
	-@docker kill `cat elasticsearchCID`
	-@docker kill `cat kibanaCID`

rm-image:
	-@docker rm `cat logstashCID`
	-@docker rm `cat elasticsearchCID`
	-@docker rm `cat kibanaCID`
	-@rm logstashCID
	-@rm elasticsearchCID
	-@rm kibanaCID

rm: kill rm-image

clean: rmall

enterlogstash:
	docker exec -i -t `cat logstashCID` /bin/bash

logslogstash:
	docker logs -f `cat logstashCID`

enterelasticsearch:
	docker exec -i -t `cat elasticsearchCID` /bin/bash

logselasticsearch:
	docker logs -f `cat elasticsearchCID`

enterkibana:
	docker exec -i -t `cat kibanaCID` /bin/bash

logskibana:
	docker logs -f `cat kibanaCID`

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

DATADIR:
	@while [ -z "$$DATADIR" ]; do \
		read -r -p "Enter the name you wish to associate with this container [DATADIR]: " DATADIR; echo "$$DATADIR">>DATADIR; cat DATADIR; \
	done ;

logstashTAG:
	@while [ -z "$$logstashTAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container, hint `make example` [logstashTAG]: " logstashTAG; echo "$$logstashTAG">>logstashTAG; cat logstashTAG; \
	done ;

elasticsearchTAG:
	@while [ -z "$$elasticsearchTAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container, hint `make example` [elasticsearchTAG]: " elasticsearchTAG; echo "$$elasticsearchTAG">>elasticsearchTAG; cat elasticsearchTAG; \
	done ;

kibanaTAG:
	@while [ -z "$$kibanaTAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container, hint `make example` [kibanaTAG]: " kibanaTAG; echo "$$kibanaTAG">>kibanaTAG; cat kibanaTAG; \
	done ;

rmall: rm

example:
	cp -i logstashTAG.example logstashTAG
	cp -i elasticsearchTAG.example elasticsearchTAG
	cp -i kibanaTAG.example kibanaTAG
	cp -i -a datadir.example datadir
	echo "$PWD/datadir">/tmp/my.example
	cp -i /tmp/my.example DATADIR
	rm /tmp/my.example
