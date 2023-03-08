#! /bin/bash

imageName="$1"
PATHC="/var/lib/containerd/io.containerd.content.v1.content/blobs/sha256"

getEntryPoint() {
    digest=$1

    isConfigExist=$(cat "$PATHC/$digest" | jq -r '.config // empty')
    nextDigest=$(cat "$PATHC/$digest" | jq -r '.manifests[0].digest // empty' | sed -e 's/^sha256://')

    if [[ -z "${isConfigExist}" ]]; then
        getEntryPoint $nextDigest
    else
        nextDigest=$(cat "$PATHC/$digest" | jq -r '.config.digest // empty' | sed -e 's/^sha256://')
        entryPoint=$(cat "$PATHC/$nextDigest" | jq -r '.config.Entrypoint // empty | join(" ")')
        cmd=$(cat "$PATHC/$nextDigest" | jq -r '.config.Cmd // empty | join(" ")')

        finalEntryPoint="$entryPoint $cmd"

        echo $finalEntryPoint
    fi
}

main() {
    firstDigest=$(ctr --namespace k8s.io images ls | grep $imageName | awk '{ print $3 }' | sed -e 's/^sha256://')
    entryPoint=$(getEntryPoint $firstDigest)
    echo $entryPoint
}

main