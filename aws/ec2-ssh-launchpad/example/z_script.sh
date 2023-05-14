#!/bin/bash

set -ue

DIR="$(cd "$(dirname "$0")" && pwd)"

YOUR_OPTION=${1:-apply}

: "$YOUR_OPTION"

cd "$DIR"

case "$YOUR_OPTION" in
apply)
  terraform init
  terraform "$YOUR_OPTION" -auto-approve
  ;;
destroy)
  terraform init
  terraform "$YOUR_OPTION" -auto-approve
  ;;
*)
  echo "$(basename "${0}"):available options: [ apply | destroy ]"
  exit 1
  ;;
esac

cd "$DIR"
