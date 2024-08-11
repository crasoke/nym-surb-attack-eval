FROM debian:latest

RUN apt-get update \
    && apt-get -y install nginx

COPY nym-api.conf /etc/nginx/conf.d/nym-api.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]