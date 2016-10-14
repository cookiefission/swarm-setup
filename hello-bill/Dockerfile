FROM alpine
MAINTAINER Sean Kenny

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

EXPOSE 8000
CMD ["hello"]

COPY hello /usr/local/bin/hello
RUN chmod +x /usr/local/bin/hello
