FROM ubuntu:24.04

ARG RAILWAY_CLI_VERSION=5.71.0
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 PORT=7681

# A shell for the project's private network: database clients, the Railway CLI and
# network tools, served in the browser by ttyd behind nginx.
# - postgresql-client from PGDG (newest major), so pg_dump works against any server version.
# - mongosh and the database tools from MongoDB's repo.
# - nginx `worker_processes auto` counts host cores, not the container quota, so pin it.
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
  && install -d /usr/share/keyrings \
  && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] https://apt.postgresql.org/pub/repos/apt noble-pgdg main" \
       > /etc/apt/sources.list.d/pgdg.list \
  && curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" \
       > /etc/apt/sources.list.d/mongodb.list \
  && apt-get update && apt-get install -y --no-install-recommends \
      postgresql-client-18 mysql-client redis-tools sqlite3 mongodb-mongosh mongodb-database-tools \
      ttyd nginx tmux vim nano less htop jq procps python3 \
      dnsutils iputils-ping netcat-openbsd iproute2 traceroute wget git unzip \
  && curl -fsSL "https://github.com/railwayapp/cli/releases/download/v${RAILWAY_CLI_VERSION}/railway-v${RAILWAY_CLI_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
       | tar -xz -C /usr/local/bin railway \
  && railway --version \
  && psql --version && mysql --version && redis-cli --version && mongosh --version \
  && sed -i 's/^worker_processes auto;/worker_processes 2;/' /etc/nginx/nginx.conf \
  && grep -q '^worker_processes 2;' /etc/nginx/nginx.conf \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Skeleton for the persistent home (the volume mounts empty at /root on first boot).
COPY skel/ /opt/skel/
COPY entrypoint.sh /entrypoint.sh
COPY drop-file-cache db /usr/local/bin/
RUN chmod +x /entrypoint.sh /usr/local/bin/db /usr/local/bin/drop-file-cache

EXPOSE 7681
ENTRYPOINT ["/entrypoint.sh"]
