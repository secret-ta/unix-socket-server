#! /bin/bash


main() {
printenv | sed 's/^\(.*\)$/\1/g' > /vol/.env

entrypoint=$(./entrypoint-client $IMAGE_NAME)

cat <<EOF | tee /vol/entrypoint.sh
#! /bin/sh

# Load .env file into a regular array
env_vars=""
while IFS='=' read -r key value
do
  env_vars="\$env_vars \$key=\$value"
done < /vol/.env 

# Check if each key is already set in the current shell
for var in \$env_vars
do
  key="\${var%=*}"
  value="\${var#*=}"

  eval "current_value=\\$\$key"
  if [ -z "\$current_value" ]; then
    # If the key is not already set, set it to the current shell
    set -a
    eval "\$key=\$value"
    set +a
  fi
done

# Container Entry-point original commands
exec $entrypoint "\$@"
EOF

chmod +x /vol/entrypoint.sh
}

main