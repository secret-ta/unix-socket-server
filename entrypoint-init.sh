#! /bin/bash


main() {
SECRETS=(${SECRETS//,/ })

for SECRET in "${SECRETS[@]}"; do
    SECRET_VAL=${!SECRET}
    echo "$SECRET=$SECRET_VAL" >> /vol/.env
done

entrypoint=$(./entrypoint-client $IMAGE_NAME)

cat <<EOF | tee /vol/entrypoint.sh
#! /bin/sh
set -a
. /vol/.env
set +a

# Container Entry-point original commands
exec $entrypoint "$@"
EOF

chmod +x /vol/entrypoint.sh
}

main