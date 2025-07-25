#!/bin/bash
set -e

RUN_USER="django"
echo $"Current working dir=${ODDSLINGERS_ROOT}"
CORE_DIR=${ODDSLINGERS_ROOT}/core
export PYTHONPATH="/opt/oddslingers.poker/core:$PYTHONPATH"

# --- Signal cleanup ---
cleanup() {
  echo "🛑 Caught termination signal. Cleaning up..."
  [[ -n "$WORKER_PID" ]] && kill "$WORKER_PID" && echo "🧹 Worker stopped"
  [[ -n "$DAPHNE_PID" ]] && kill "$DAPHNE_PID" && echo "🧹 Daphne stopped"
  [[ -n "$DRAMATIQ_PID" ]] && kill "$DRAMATIQ_PID" && echo "🧹 Dramatiq stopped"
  [[ -n "$YACRON_PID" ]] && kill "$YACRON_PID" && echo "🧹 Yacron stopped"

  # Stop nginx gracefully
  nginx -s quit || echo "Nginx stop failed"

  exit 0
}

trap cleanup SIGINT SIGTERM

echo "🔐 Starting Doppler secrets injection..."
# runuser -u $RUN_USER -- doppler run -- echo "✅ Doppler secrets loaded"
doppler secrets download -p oddslinger --no-check-version --no-file --format env --no-check-version --no-file --format env

echo "🔐 Checking redis Server is reachable" 
runuser -u $RUN_USER -- doppler run -- python /opt/oddslingers.poker/bin/check_redis.py

# Run DB migrations
echo "📦 Running Django migrations..."
runuser -u $RUN_USER -- doppler run -- python "${CORE_DIR}"/manage.py migrate --noinput

# Collect static files
echo "🧹 Collecting static files..."
runuser -u $RUN_USER -- doppler run -- python "${CORE_DIR}"/manage.py collectstatic --noinput

# Cleanup existing *.conf files if exists 
echo "🧹 Cleanup of config files" 
rm -f /opt/oddslingers.poker/etc/nginx/sb-nginx.conf /opt/oddslingers.poker/etc/supervisor/sb-supervisord.conf

# Create nginx.conf and supervisord.conf 
echo "🛠️ Generating nginx.conf"
doppler run  -- envsubst '$DAPHNE_PORT $NGINX_PORT' < /opt/oddslingers.poker/etc/nginx/sb-nginx.conf.template > /opt/oddslingers.poker/etc/nginx/sb-nginx.conf
echo "🛠️ Generating supervisord.conf " 
doppler run  -- envsubst '$DAPHNE_PORT $NGINX_PORT' < /opt/oddslingers.poker/etc/supervisor/sb-supervisord.conf.template > /opt/oddslingers.poker/etc/supervisor/sb-supervisord.conf 

# echo "🚀 Starting supervisord..."
# exec /usr/bin/supervisord -n -c /opt/oddslingers.poker/etc/supervisor/sb-supervisord.conf

echo "🚀 Starting Django runserver..."
cd /opt/oddslingers.poker/core
runuser -u $RUN_USER -- doppler run -- python manage.py runserver 0.0.0.0:8080 

# moved this logic to supervisor for process management 
# echo "🚀 Starting Django app via Daphne on port 8000..."
# runuser -u django -- doppler run -- daphne -b 0.0.0.0 -p 8000 core.oddslingers.asgi:channel_layer &
# DAPHNE_PID=$!

# echo "Daphne PID: $DAPHNE_PID"

# echo "🚀 Starting Django Channels worker process..."
# runuser -u django -- doppler run -- python "${CORE_DIR}"/manage.py runworker --verbosity=2 &
# WORKER_PID=$!


# echo "Worker PID: $WORKER_PID"

# # Optionally, wait a shorter time or check daphne health before continuing.
# sleep 10

# # Start Dramatiq in background
# echo "⚙️ Starting Dramatiq worker..."
# # runuser -u $RUN_USER -- doppler run -- python "${CORE_DIR}"/manage.py rundramatiq --processes 1 --threads 2 &
# runuser -u django -- doppler run -- dramatiq --path "${CORE_DIR}" --processes 1 --threads 2 django_dramatiq.setup django_dramatiq.tasks oddslingers.tasks &
# DRAMATIQ_PID=$!

# # # Start Yacron in background
# # echo "⏰ Starting Yacron scheduler..."
# # runuser -u django -- doppler run -- yacron -c /opt/oddslingers.poker/etc/yacron/oddslingers-dev.yaml &
# # YACRON_PID=$!

# # Start nginx in foreground (will block)
# echo "🌐 Starting nginx server..."
# nginx -g "daemon off;" -c /opt/oddslingers.poker/etc/nginx/sb-nginx.conf 


