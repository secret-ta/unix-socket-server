#! /bin/bash

imageName="$1"

main() {
    configSha256=$(ctr --namespace k8s.io images pull $imageName | grep -s config-sha256 | tail -n 1  | awk '{print $1}' | sed 's/^config-sha256://; s/:$//')
    while [[ -z "${configSha256}" ]]; do
        configSha256=$(ctr --namespace k8s.io images pull $imageName | grep -s config-sha256 | tail -n 1  | awk '{print $1}' | sed 's/^config-sha256://; s/:$//')
    done

    ctrdDir="/var/lib/containerd/io.containerd.content.v1.content/blobs/sha256/"
    
    entryPoint=$(cat "$ctrdDir/$configSha256" | jq -r '.config.Entrypoint // empty | join(" ")')
    cmd=$(cat "$ctrdDir/$configSha256" | jq -r '.config.Cmd // empty | join(" ")')

    finalEntryPoint="$entryPoint $cmd"
    echo $finalEntryPoint
}
main