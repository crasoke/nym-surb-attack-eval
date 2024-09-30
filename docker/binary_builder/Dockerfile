FROM rust:latest

RUN apt-get update \
    && apt-get -y install git

WORKDIR /app
RUN git clone https://github.com/nymtech/nym.git \
    && cd nym \
    && git checkout release/2024.8-wispa

RUN apt-get -y install pkg-config build-essential libssl-dev curl jq wget libudev-dev squashfs-tools protobuf-compiler

COPY mod.rs /root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]