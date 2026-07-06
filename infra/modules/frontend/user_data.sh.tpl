#!/bin/bash
set -euo pipefail

dnf install -y docker awscli
systemctl enable --now docker

aws ecr get-login-password --region "${aws_region}" \
  | docker login --username AWS --password-stdin "$(echo "${container_image}" | cut -d/ -f1)"

docker pull "${container_image}"

docker run -d \
  --name notes-frontend \
  --restart unless-stopped \
  -p 80:80 \
  -e API_UPSTREAM="${api_upstream}" \
  "${container_image}"
