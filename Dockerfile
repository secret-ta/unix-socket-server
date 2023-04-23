FROM alpine

RUN apk add --update --no-cache bash libc6-compat skopeo jq

COPY set-init-cmd.sh .

ENTRYPOINT ["bash", "set-init-cmd.sh"] 
