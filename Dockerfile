FROM ubuntu:latest AS builder

ENV DEBIAN_FRONTEND=noninteractive
ARG VOSVERSION=7.2.5.1
WORKDIR /tmp
ENV CFLAGS "-O2 -m64"

RUN apt update

RUN apt install -y build-essential autotools-dev autoconf automake net-tools libtool flex bison gperf gawk m4 libreadline-dev openssl crudini libssl1.0-dev curl

RUN curl -L -o vos.tar.gz https://github.com/openlink/virtuoso-opensource/archive/v${VOSVERSION}.tar.gz

RUN tar xf vos.tar.gz --strip-components=1

RUN ./autogen.sh

RUN ./configure --prefix=/usr/local --disable-bpel-vad --enable-conductor-vad --enable-fct-vad --disable-dbpedia-vad --disable-demo-vad --disable-sparqldemo-vad --disable-tutorial-vad --with-readline --program-transform-name="s/isql/isql-v/"
RUN make -j
RUN make install 

FROM ubuntu:latest 

COPY --from=builder /usr/local/ /usr/local/

RUN apt update && apt install -y libssl1.0.0 && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/local/var/lib/virtuoso /var/lib/virtuoso

ADD virtuoso.ini /usr/local/etc/

CMD ["virtuoso-t", "+wait", "+foreground", "+configfile", "/usr/local/etc/virtuoso.ini" ]
