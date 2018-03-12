FROM arm32v6/alpine 

LABEL maintainer="Jason Wilder mail@jasonwilder.com, Ondřej Záruba <info@zaruba-ondrej.cz> (https://zaruba-ondrej.cz)"

# Install wget and install/updates certificates
RUN apk add --no-cache --virtual .run-deps \
    ca-certificates bash wget openssl \
    && update-ca-certificates


# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Install Forego
RUN wget https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-arm.tgz && \
	tar xvf forego-stable-linux-arm.tgz -C /usr/local/bin && \
	chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.7.3

RUN wget --quiet https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-alpine-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-alpine-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-alpine-linux-armhf-$DOCKER_GEN_VERSION.tar.gz


ENV NGINX_PROXY_VERSION "0.6.0"
RUN git clone --branch ${CADVISOR_VERSION} https://github.com/jwilder/nginx-proxy.git /app

WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]