FROM busybox:1.36

RUN adduser -DHs /bin/sh example

COPY watcher.sh /watcher/watcher.sh
WORKDIR /watcher

RUN chown example watcher.sh
RUN chmod a+x watcher.sh
USER example

CMD ["/watcher/watcher.sh"]
