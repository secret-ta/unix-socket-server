FROM alpine

RUN apk add --update --no-cache curl bash libc6-compat

COPY worker-node-unix-socket-client/entrypoint-client .
COPY entrypoint-init.sh .

ENTRYPOINT ["bash", "entrypoint-init.sh"] 
