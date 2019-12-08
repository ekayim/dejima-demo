REPO ?= ekayim/dejima-proxy
GITTAG ?= v0.0.0
TAG  ?= $(GITTAG)

all: build push

clean:
	docker rmi $(shell docker images -q $(REPO))

build:
	docker build --rm -t $(REPO):latest .
push:
	docker push $(REPO):$(TAG)
	docker push $(REPO):latest
