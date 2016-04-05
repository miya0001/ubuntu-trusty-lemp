#!/usr/bin/env bash

#set -ex

json=$(cat vhosts.json)
len=$(echo $json | jq length)
for i in $( seq 0 $(($len - 1)) ); do
  echo $($json | jq .[$i]);
done
