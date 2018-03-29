NDNFS_LOG_PATH = $(DESTDIR)/opt/nedge/var/log
NDNFS_PID_PATH = $(DESTDIR)/opt/nedge/var/run
NEDGE_DEST = $(DESTDIR)/opt/nedge/sbin
NEDGE_ETC = $(DESTDIR)/opt/nedge/etc/ccow
NDNFS_EXE = ndnfs

ifeq ($(GOPATH),)
GOPATH = $(shell pwd)
endif

build:
	GOPATH=$(GOPATH) go get -d -v github.com/opencontainers/runc
	cd $(GOPATH)/src/github.com/opencontainers/runc; git checkout aada2af
	GOPATH=$(GOPATH) go get -v github.com/docker/go-plugins-helpers/volume
	cd $(GOPATH)/src/github.com/docker/go-plugins-helpers/volume; git checkout d7fc7d0
	cd $(GOPATH)/src/github.com/docker/go-connections; git checkout acbe915
	GOPATH=$(GOPATH) go get -d github.com/Nexenta/nedge-docker-nfs/...
	cd $(GOPATH)/src/github.com/Nexenta/nedge-docker-nfs; git checkout stable/v13
	GOPATH=$(GOPATH) go get github.com/Nexenta/nedge-docker-nfs/...

lint:
	go get -v github.com/golang/lint/golint
	for file in $$(find $(GOPATH)/src/github.com/Nexenta/nedge-docker-nfs -name '*.go' | grep -v vendor | grep -v '\.pb\.go' | grep -v '\.pb\.gw\.go'); do \
		$(GOPATH)/bin/golint $${file}; \
		if [ -n "$$($(GOPATH)/bin/golint $${file})" ]; then \
			exit 1; \
		fi; \
	done

install:
	mkdir -p $(NEDGE_DEST)
	mkdir -p $(NEDGE_ETC)
	mkdir -p $(NDNFS_LOG_PATH)
	mkdir -p $(NDNFS_PID_PATH)
	touch $(NDNFS_LOG_PATH)/ndnfs.log
	touch $(NDNFS_PID_PATH)/ndnfs.pid
	cp -n $(GOPATH)/src/github.com/Nexenta/nedge-docker-nfs/ndnfs/daemon/ndnfs.json $(NEDGE_ETC)/ndnfs.json
	cp -f $(GOPATH)/bin/$(NDNFS_EXE) $(NEDGE_DEST)/$(NDNFS_EXE)

uninstall:
	rm -f $(NEDGE_ETC)/ndnfs.json
	rm -f $(NEDGE_DEST)/$(NDNFS_EXE)
	rm -f $(NDNFS_LOG_PATH)/ndnfs.log
	rm -f $(NDNFS_PID_PATH)/ndnfs.pid

clean:
	go clean github.com/Nexenta/nedge-docker-nfs
