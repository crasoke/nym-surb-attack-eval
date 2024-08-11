FROM --platform=linux/amd64 ubuntu:22.04
ARG RELEASE_URL=https://github.com/nymtech/nyxd/releases/download/v0.43.0/nyxd-ubuntu-22.04.tar.gz
ARG ARCHIVE_NAME=nyxd-ubuntu-22.04.tar.gz

RUN apt update \
  && apt -y install ca-certificates jq curl vim wget

WORKDIR /root

RUN wget ${RELEASE_URL} \
  && tar -zxvf ${ARCHIVE_NAME} \
  && chmod u+x nyxd \
  && chmod u+x libwasmvm.x86_64.so \
  && mv nyxd /usr/bin/nyxd \
  && mv libwasmvm*.so /lib/x86_64-linux-gnu/ \
  && rm ${ARCHIVE_NAME}

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]