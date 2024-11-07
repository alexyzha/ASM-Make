##  Debian base image
FROM debian:latest
ENV DEBIAN_FRONTEND=noninteractive

##  Update packages, get NASM
RUN apt-get update && \
    apt-get install -y nasm build-essential gdb valgrind && \
    rm -rf /var/lib/apt/lists/*

##  Set working dir
WORKDIR /src/

##  Bash
CMD ["/bin/bash"]
