#!/bin/bash

set -ue

DIR="$(cd "$(dirname "$0")" && pwd)"

YOUR_OPTION=${1:-apply}
YOUR_PUBLIC_DIR=${2:-$PWD/public/}
YOUR_DOMAIN=${3:-my-static-site.com}

: "$YOUR_OPTION"
: "$YOUR_PUBLIC_DIR"
: "$YOUR_DOMAIN"

S3_BUCKET="s3://$YOUR_DOMAIN"

cd "$DIR"

aws s3api create-bucket --bucket "$YOUR_DOMAIN-terraform" | jq

case "$YOUR_OPTION" in
apply)
  terraform init -backend-config=terraform-backend.conf
  terraform "$YOUR_OPTION" -auto-approve
  aws --no-progress --delete s3 sync "$YOUR_PUBLIC_DIR" "$S3_BUCKET"
  aws cloudfront create-invalidation --distribution-id $(cat z_cf_distribution_id.log) --paths '/*' | jq '.'
  ;;
destroy)
  aws s3 rm "$S3_BUCKET" --recursive
  terraform init -backend-config=terraform-backend.conf
  terraform "$YOUR_OPTION" -auto-approve
  ;;
*)
  echo "$(basename "${0}"):available options: [ apply | destroy ]"
  exit 1
  ;;
esac

cd "$DIR"
