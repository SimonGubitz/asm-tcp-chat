FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y \
        nasm \
        make \
        gcc \
        gdb && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

WORKDIR /app/server

RUN make clean-build

CMD ["./bin/chat-server"]
