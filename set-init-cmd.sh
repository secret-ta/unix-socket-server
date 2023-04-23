#! /bin/bash

get_init_commands() {
  image_name="$1"
  config=$(skopeo inspect --config "docker://$image_name")
  if [ $? -ne 0 ]; then
    echo "Error: Failed to inspect image $image_name"
    exit 1
  fi
  entrypoint=$(echo "$config" | jq -r '.config.Entrypoint[]' | while read -r e; do echo -n "\"$e\" "; done | tr '\n' ' ')
  cmd=$(echo "$config" | jq -r '.config.Cmd[]' | while read -r c; do echo -n "\"$c\" "; done | tr '\n' ' ')
  commands="$entrypoint $cmd"
  echo "$commands"
}

main() {
printenv | sed 's/^\(.*\)$/\1/g' > /vol/.env

init_commands=$(get_init_commands $IMAGE_NAME)
if [ $? -ne 0 ]; then
    exit 1
fi

cat <<EOF | tee /vol/init.sh
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
exec $init_commands "\$@"
EOF

chmod +x /vol/init.sh
}

main
