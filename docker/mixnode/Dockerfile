FROM debian:latest

RUN apt-get update \
    && apt-get -y install iproute2 curl tcpdump vim tmux sqlite3

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]