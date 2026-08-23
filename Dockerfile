FROM ubuntu:26.10

RUN apt-get update && \
    apt-get install -y nasm gdb build-essential file bsdmainutils

WORKDIR /app

CMD ["/bin/bash"]
