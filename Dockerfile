FROM debian:10 as build

ARG ZLIB_VERSION=1.2.11
ARG PCRE_VERSION=8.44
ARG NGINX_VERSION=1.20.0
ARG CLEAN_BUILD=1

WORKDIR /src

RUN apt-get update && apt-get install -y curl gnupg build-essential libssl-dev

WORKDIR /src

WORKDIR /src
RUN curl -q -o zlib-${ZLIB_VERSION}.tar.gz     https://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz && \
    curl -q -o zlib-${ZLIB_VERSION}.tar.gz.asc https://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz.asc && \
    curl -q https://madler.net/madler/pgp.html | gpg --import - && \
    gpg --verify zlib-${ZLIB_VERSION}.tar.gz.asc && \
    tar xzf zlib-${ZLIB_VERSION}.tar.gz && \
    cd zlib-${ZLIB_VERSION} && \
    ./configure \
      --prefix=/usr/local && \
    make install
    
WORKDIR /src
RUN curl -q -o pcre-${PCRE_VERSION}.tar.gz     https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz && \
    curl -q -o pcre-${PCRE_VERSION}.tar.gz.sig https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz.sig && \
    curl -q https://ftp.pcre.org/pub/pcre/Public-Key | gpg --import - && \
    tar xzf pcre-${PCRE_VERSION}.tar.gz && \
    cd pcre-${PCRE_VERSION} && \
    ./configure \
      --prefix=/usr/local \
      --enable-unicode-properties \
      --enable-pcre16 \
      --enable-pcre32 \
      --enable-pcregrep-libz \
      --disable-static && \
    make install

WORKDIR /src
RUN curl -q -o nginx-${NGINX_VERSION}.tar.gz     https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    curl -q -o nginx-${NGINX_VERSION}.tar.gz.asc https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc && \
    for k in mdounin maxim sb nginx_signing; do curl -q https://nginx.org/keys/${k}.key | gpg --import -; done && \
    gpg --verify nginx-${NGINX_VERSION}.tar.gz.asc && \
    tar xzf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    ./configure --prefix=/usr/local \
      --with-http_ssl_module \
      --with-pcre=../pcre-${PCRE_VERSION} \
      --with-zlib=../zlib-${ZLIB_VERSION} && \
    make install

RUN rm -rf /usr/local/share/man \
      /usr/local/share/doc

RUN test "${CLEAN_BUILD}" = "1" && rm -rf /usr/local/include \
      /usr/local/bin/pcre* \
      /usr/local/lib/pkgconfig \
      /usr/local/include || true

FROM gcr.io/distroless/base-debian10
COPY --from=build /usr/local /usr/local

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off; user nobody nobody;"]
