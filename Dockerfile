FROM alpine

RUN apk add --update --no-cache curl bash

COPY entrypoint-init.sh .

ENTRYPOINT ["bash", "entrypoint-init.sh"] 
