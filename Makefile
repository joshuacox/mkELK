.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs example temp prod

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make elk       -  run elk stack docker containers 
	@echo ""   Or you can call them individually
	@echo ""   2. make logstash       -  run logstash docker container
	@echo ""   3. make elasticsearch       -  run elasticsearch docker container
	@echo ""   4. make kibana       -  run kibana docker container
	@echo ""   5. make redis       -  run redis docker container
	@echo ""   6. make ssh       -  run ssh docker container

elk: elasticsearch logstash kibana redis ssh

# Logstash
logstash: logstashTAG NAME logstashCID

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

logstashTAG:
	@while [ -z "$$logstashTAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container, hint 'make example' [logstashTAG]: " logstashTAG; echo "$$logstashTAG">>logstashTAG; cat logstashTAG; \
	done ;

enterlogstash:
	docker exec -i -t `cat logstashCID` /bin/bash

logslogstash:
	docker logs -f `cat logstashCID`

# Elastic Search
elasticsearch: DATADIR elasticsearchTAG NAME elasticsearchCID

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

enterelasticsearch:
	docker exec -i -t `cat elasticsearchCID` /bin/bash

logselasticsearch:
	docker logs -f `cat elasticsearchCID`

elasticsearchTAG:
	@while [ -z "$$elasticsearchTAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container, hint `make example` [elasticsearchTAG]: " elasticsearchTAG; echo "$$elasticsearchTAG">>elasticsearchTAG; cat elasticsearchTAG; \
	done ;

# Kibana
kibana: DATADIR kibanaTAG NAME kibanaCID

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

enterkibana:
	docker exec -i -t `cat kibanaCID` /bin/bash

logskibana:
	docker logs -f `cat kibanaCID`

kibanaTAG:
	@while [ -z "$$kibanaTAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container, hint `make example` [kibanaTAG]: " kibanaTAG; echo "$$kibanaTAG">>kibanaTAG; cat kibanaTAG; \
	done ;

# redis
redis: redisTAG NAME redisCID

redisCID:
	$(eval NAME := $(shell cat NAME))
	$(eval DATADIR := $(shell cat DATADIR))
	$(eval redisTAG := $(shell cat redisTAG))
	@docker run --name=$(NAME)-redis \
	--cidfile="redisCID" \
	--link $(NAME)-logstash:logstash \
	-d \
	--restart=always \
	-v "$(DATADIR)/redis/data":/data \
	-t $(redisTAG) redis-server --appendonly yes

redisTAG:
	@while [ -z "$$redisTAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container, hint `make example` [redisTAG]: " redisTAG; echo "$$redisTAG">>redisTAG; cat redisTAG; \
	done ;

enterredis:
	docker exec -i -t `cat redisCID` /bin/bash

logsredis:
	docker logs -f `cat redisCID`

# ssh
ssh: sshTAG NAME sshCID

sshCID:
	$(eval NAME := $(shell cat NAME))
	$(eval SSH_PORT := $(shell cat SSH_PORT))
	$(eval DATADIR := $(shell cat DATADIR))
	$(eval KEY_URL := $(shell cat KEY_URL))
	$(eval sshTAG := $(shell cat sshTAG))
	@docker run --name=$(NAME)-ssh \
	--cidfile="sshCID" \
	--link $(NAME)-logstash:logstash \
	--link $(NAME)-redis:redis \
	-d \
	-p $(SSH_PORT):22 \
	-e KEY_URL=$(KEY_URL) \
	--restart=always \
	-t $(sshTAG)

sshTAG:
	@while [ -z "$$sshTAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container, hint `make example` [sshTAG]: " sshTAG; echo "$$sshTAG">>sshTAG; cat sshTAG; \
	done ;

enterssh:
	docker exec -i -t `cat sshCID` /bin/bash

logsssh:
	docker logs -f `cat sshCID`

# Meta commands
kill:
	-@docker kill `cat logstashCID`
	-@docker kill `cat elasticsearchCID`
	-@docker kill `cat kibanaCID`
	-@docker kill `cat redisCID`
	-@docker kill `cat sshCID`

rm-image:
	-@docker rm `cat logstashCID`
	-@docker rm `cat elasticsearchCID`
	-@docker rm `cat kibanaCID`
	-@docker rm `cat redisCID`
	-@docker rm `cat sshCID`
	-@rm logstashCID
	-@rm elasticsearchCID
	-@rm kibanaCID
	-@rm redisCID
	-@rm sshCID

rm: kill rm-image

clean: rmall

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

DATADIR:
	@while [ -z "$$DATADIR" ]; do \
		read -r -p "Enter the datadir you wish to associate with this container [DATADIR]: " DATADIR; echo "$$DATADIR">>DATADIR; cat DATADIR; \
	done ;

rmall: rm

example:
	$(eval PWD := $(shell pwd))
	cp -i logstashTAG.example logstashTAG
	cp -i elasticsearchTAG.example elasticsearchTAG
	cp -i kibanaTAG.example kibanaTAG
	cp -i redisTAG.example redisTAG
	cp -i sshTAG.example sshTAG
	cp -i -a datadir.example datadir
	cp -i SSH_PORT.example SSH_PORT
	cp -i KEY_URL.example KEY_URL
	echo "$(PWD)/datadir">/tmp/my.example
	cp -i /tmp/my.example DATADIR
	rm /tmp/my.example
