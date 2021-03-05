FROM arm32v7/nginx 

LABEL maintainer="Jason Wilder mail@jasonwilder.com, Ondřej Záruba <info@zaruba-ondrej.cz> (https://zaruba-ondrej.cz)"

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
    git \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*


# Download all the configurations from nginx-ultimate-bad-bot-blocker
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/globalblacklist.conf -O /etc/nginx/conf.d/globalblacklist.conf
RUN mkdir /etc/nginx/bots.d
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/blockbots.conf -O /etc/nginx/bots.d/blockbots.conf
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/ddos.conf -O /etc/nginx/bots.d/ddos.conf
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/whitelist-ips.conf -O /etc/nginx/bots.d/whitelist-ips.conf
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/whitelist-domains.conf -O /etc/nginx/bots.d/whitelist-domains.conf
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/blacklist-user-agents.conf -O /etc/nginx/bots.d/blacklist-user-agents.conf
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/custom-bad-referrers.conf -O /etc/nginx/bots.d/custom-bad-referrers.conf
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/blacklist-ips.conf -O /etc/nginx/bots.d/blacklist-ips.conf
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/bad-referrer-words.conf -O /etc/nginx/bots.d/bad-referrer-words.conf
RUN wget --quiet https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/botblocker-nginx-settings.conf -O /etc/nginx/conf.d/botblocker-nginx-settings.conf


# Configure Nginx and apply config for using the blockbots and ddos conf files 
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/server_name .*;$/&\n        incliude \/etc\/nginx\/bots.d\/blockbots.conf;/' /etc/nginx/conf.d/default.conf \
 && sed -i 's/server_name .*;$/&\n        incliude \/etc\/nginx\/bots.d\/ddos.conf;/' /etc/nginx/conf.d/default.conf


# Install Forego
RUN wget --quiet https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-arm.tgz && \
	tar xvf forego-stable-linux-arm.tgz -C /usr/local/bin && \
	chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.7.4

RUN wget --quiet https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-alpine-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-alpine-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-alpine-linux-armhf-$DOCKER_GEN_VERSION.tar.gz


ENV NGINX_PROXY_VERSION "0.6.0"
RUN git clone --branch ${NGINX_PROXY_VERSION} https://github.com/jwilder/nginx-proxy.git /app

WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
