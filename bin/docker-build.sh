#!/bin/bash
set -e

IMG_REPO="reg.lan.terhaak.de/jojo"
IMG_NAME="tt-rss"
REV="1" # revision for multiple releases per day

IMG_TAG="`date +%Y%m%d`-$REV"
IMG_FULL_NAME="$IMG_REPO/$IMG_NAME:$IMG_TAG"

sudo docker build -t "$IMG_FULL_NAME" .

