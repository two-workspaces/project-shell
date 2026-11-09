#!/bin/bash
set -e

# /root is a Railway volume: empty on first boot. Seed dotfiles once.
if [ ! -f /root/.terminal-seeded ]; then
  cp -af /opt/skel/. /root/ && touch /root/.terminal-seeded
fi
mkdir -p /root/dumps

# Without a password the shell would be open to anyone with the URL. Don't serve it,
# and don't crash either (a crash loop reads as a failed deploy): explain and wait.
if [ -z "${WEB_PASSWORD:-}" ]; then
  mkdir -p /var/www/notice
  cat > /var/www/notice/index.html <<'HTML'
<!doctype html><meta charset="utf-8"><title>Terminal</title>
<body style="font:16px/1.5 system-ui;max-width:36em;margin:4em auto;padding:0 1em">
<h1>Set WEB_PASSWORD</h1>
<p>This terminal has no password, so it isn't served. Add a <code>WEB_PASSWORD</code>
variable to this service in Railway; the service redeploys and the terminal opens here.</p>
HTML
  cat > /etc/nginx/sites-enabled/default <<CFG
server {
  listen ${PORT} default_server;
  listen [::]:${PORT} default_server;
  location = /healthcheck { return 200 "ok"; }
  location / { root /var/www/notice; try_files /index.html =404; }
}
CFG
  echo "== WEB_PASSWORD is empty: serving a notice instead of the terminal"
  exec nginx -g 'daemon off;'
fi

# nginx on $PORT: unauthenticated /healthcheck for Railway, everything else to ttyd.
cat > /etc/nginx/sites-enabled/default <<CFG
server {
  listen ${PORT} default_server;
  listen [::]:${PORT} default_server;
  location = /healthcheck { return 200 "ok"; }
  location / {
    proxy_pass http://127.0.0.1:7682;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
    proxy_read_timeout 1d;
  }
}
CFG
nginx

# Railway counts the kernel's cache of files this container has touched as the
# service's memory, and it's never freed without pressure: one large dump shows as
# hundreds of MB. Drop it for the home volume every 15 min.
( while sleep 900; do nice -n 19 drop-file-cache /root /tmp || true; done ) &

TITLE="${RAILWAY_PROJECT_NAME:-terminal}${RAILWAY_ENVIRONMENT_NAME:+ / $RAILWAY_ENVIRONMENT_NAME}"
echo "== terminal ready on :${PORT}"
# Each browser tab attaches to the same tmux session, so work survives a closed tab.
exec ttyd -i 127.0.0.1 -p 7682 -W -c "${WEB_USER:-admin}:${WEB_PASSWORD}" \
  -t titleFixed="$TITLE" -t fontSize=14 \
  bash -lc 'exec tmux new -A -s main'
