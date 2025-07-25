FROM sb_ubuntu22.04:latest

# === Configuration Defaults ===
ENV ODDSLINGERS_ROOT="/opt/oddslingers.poker" \
    DATA_DIR="/opt/oddslingers.poker/data" \
    HTTP_PORT="8080" \
    DJANGO_USER="django" \
    NODE_MAJOR="18" \
    LC_ALL="C.UTF-8" \
    LANG="C.UTF-8" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# === Base dependencies ===
RUN apt-get update && \
    apt-get install -y --no-install-recommends nodejs sudo curl gnupg vim gettext-base && \
    apt-get install -y nginx && \
    mkdir -p /tmp/nginx_body_temp && \
    rm -rf /var/lib/apt/lists/*

# === Set working directory ===
WORKDIR $ODDSLINGERS_ROOT

RUN ln -s /usr/bin/python3.7 /usr/bin/python

# === Install Python dependencies ===
COPY ./core/requirements.txt ./core/requirements.txt
RUN pip3 install --no-cache-dir -r ./core/requirements.txt

# === Install Node/Yarn/Webpack ===
RUN npm install -g npm && \
    npm install -g yarn

# === Create a non-root user ===
RUN addgroup --system $DJANGO_USER && \
    adduser --system --ingroup $DJANGO_USER --shell /usr/sbin/nologin $DJANGO_USER

# === Copy project files ===
COPY . .

# === Prepare file system ===
RUN mkdir -p $DATA_DIR/logs $ODDSLINGERS_ROOT/core/js/node_modules && \
    chown -R $DJANGO_USER:$DJANGO_USER $DATA_DIR $ODDSLINGERS_ROOT/core && \
    chown -R $DJANGO_USER:$DJANGO_USER $ODDSLINGERS_ROOT/etc

# === Build Frontend Assets ===
WORKDIR $ODDSLINGERS_ROOT/core/js

# Install frontend dependencies and build assets
RUN yarn install && \
    yarn add --dev webpack webpack-cli node-sass && \
    npx webpack --mode production && \
    npx node-sass scss/ -o ../static/css

# RUN yarn install && \
#     yarn add --dev webpack webpack-cli node-sass && \
#     npx webpack --mode production && \
#     yarn run webpack --mode production && \
#     node-sass scss/ -o ../static/css

# === Final working directory ===
WORKDIR $ODDSLINGERS_ROOT

# === Make server script executable ===
RUN chmod +x /opt/oddslingers.poker/bin/_run_server.sh

# === Set and Expose port
ENV PORT=8080
EXPOSE 8080
# === Entrypoint ===
CMD ["/opt/oddslingers.poker/bin/_run_server.sh"]
