all: build run

build:
	docker build --platform linux/amd64 -t assorted-asm-x86 .

run:
	docker run --platform linux/amd64 -it -v $(PWD):/src assorted-asm-x86

prune:
	docker container prune

delete:
	docker rmi -f assorted-asm-x86