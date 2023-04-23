#!/bin/sh

echo "The arguments passed to this script are: $@"

FILE_SECRET_1=$(cat "$FILE_SECRET_1_PATH")
FILE_SECRET_2=$(cat "$FILE_SECRET_2_PATH")

while true; do
  echo "file_secret_1: $FILE_SECRET_1"
  echo "file_secret_2: $FILE_SECRET_2"
  echo "env_secret_1: $ENV_SECRET_1"
  echo "env_secret_2: $ENV_SECRET_2"
  sleep 5
done
