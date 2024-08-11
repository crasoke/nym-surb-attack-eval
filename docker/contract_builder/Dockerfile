# This one is an alternative and does the same as https://github.com/CosmWasm/optimizer does
# FROM rust:1.75.0-alpine

# ADD https://github.com/WebAssembly/binaryen/archive/refs/tags/version_116.tar.gz /tmp/binaryen.tar.gz

# RUN apk update && apk add build-base cmake git python3 clang ninja musl-dev
# RUN tar -xf /tmp/binaryen.tar.gz
# RUN cd binaryen-version_*/ \
#   && git clone --depth 1 https://github.com/google/googletest.git ./third_party/googletest \
#   && cmake . -G Ninja -DCMAKE_CXX_FLAGS="-static" -DCMAKE_C_FLAGS="-static" -DCMAKE_BUILD_TYPE=Release -DBUILD_STATIC_LIB=ON \
#   && ninja wasm-opt

# RUN strip binaryen-version_*/bin/wasm-opt
# RUN mv binaryen-version_*/bin/wasm-opt /usr/local/bin

# WORKDIR /app
# RUN git clone https://github.com/nymtech/nym.git \
#     && cd nym \
#     && git checkout master
# ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


# for some reason we need rust 1.75 ¯\_(ツ)_/¯
FROM rust:1.75.0

RUN apt-get update \
    && apt-get -y install git

WORKDIR /app
RUN git clone https://github.com/nymtech/nym.git \
    && cd nym \
    && git checkout master

RUN apt-get -y install npm

RUN npm i wasm-opt -g

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]