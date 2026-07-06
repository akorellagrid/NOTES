#!/bin/bash
set -euo pipefail

dnf install -y docker awscli
systemctl enable --now docker

aws ecr get-login-password --region "${aws_region}" \
  | docker login --username AWS --password-stdin "$(echo "${container_image}" | cut -d/ -f1)"

DATABASE_URL=$(aws secretsmanager get-secret-value \
  --region "${aws_region}" \
  --secret-id "${db_secret_arn}" \
  --query SecretString --output text | python3 -c 'import json,sys; print(json.load(sys.stdin)["database_url"])')

docker pull "${container_image}"

docker run -d \
  --name notes-api \
  --restart unless-stopped \
  -p ${app_port}:${app_port} \
  -e DATABASE_URL="$DATABASE_URL" \
  "${container_image}"
