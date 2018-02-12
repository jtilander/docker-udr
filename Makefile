IMAGENAME=jtilander/docker-udr
TAG?=latest
REMOTE?=remotehost:2222

image:
	@docker build -t $(IMAGENAME):$(TAG) .
	@docker images $(IMAGENAME):$(TAG)

run:
	docker run --rm -v $(PWD)/tmp/0:/workspace -p 2222:22 -p 9000:9000/udp $(IMAGENAME):$(TAG)

copy:
	docker run --rm \
	-v $(PWD)/tmp/1:/workspace \
	-v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro \
	-v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub:ro \
	-p 8000:9000/udp \
	$(IMAGENAME):$(TAG) udr $(REMOTE)
