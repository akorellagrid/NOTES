# Serves the already-built static assets (frontend/public, produced by
# `npm run build`) behind nginx, reverse-proxying /api/* to the backend
# ALB. Built to run on the AWS frontend ASG (infra/modules/frontend) —
# not used by docker-compose, which mounts public/ + nginx.conf directly.
FROM nginx:1.27-alpine

COPY public/ /usr/share/nginx/html/
COPY nginx.aws.conf.template /etc/nginx/templates/default.conf.template

EXPOSE 80
