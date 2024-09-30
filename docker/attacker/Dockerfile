FROM rust:latest

RUN apt-get update \
    && apt-get -y install iproute2 tcpdump vim tmux sqlite3

COPY surb_attack/ /root/surb_attack

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]