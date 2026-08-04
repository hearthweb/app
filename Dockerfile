FROM alpine:latest AS frontend

# Set the working directory
WORKDIR /app

# Install Node.js and pnpm
RUN apk add --no-cache \
    nodejs \
    pnpm

# Install project dependencies
RUN --mount=type=cache,target=/pnpm/store \
    --mount=type=bind,source=frontend/package.json,target=package.json \
    --mount=type=bind,source=frontend/pnpm-lock.yaml,target=pnpm-lock.yaml \
    pnpm install --frozen-lockfile

# Copy the rest of the source files
COPY frontend/ .

# Generate .nuxt and OpenAPI files
RUN pnpm nuxi prepare
RUN pnpm openapi:generate

# Build the application
RUN pnpm generate


FROM alpine:latest AS backend

# Set the working directory
WORKDIR /app

# Install Python and uv
RUN apk add --no-cache \
    python3 \
    uv

# Install project dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=backend/pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=backend/uv.lock,target=uv.lock \
    uv sync --locked --no-install-project

# Copy the rest of the source files
COPY backend/ .

# Sync the project
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked


FROM alpine:latest

# Set the working directory
WORKDIR /app

# Install Python and Nginx
RUN apk add --no-cache \
    python3 \
    nginx

# Copy the Nginx and s6-overlay service files
COPY rootfs /

# Copy the files from the frontend and backend stages
COPY --from=frontend /app/.output/public /usr/share/nginx/html
COPY --from=backend /app /app

# Install s6-overlay
ARG S6_OVERLAY_VERSION=3.2.3.2
RUN apk add --no-cache xz \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" | tar -C / -Jxpf - \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz" | tar -C / -Jxpf - \
    && apk del xz

# Use s6-overlay as the entrypoint 
ENTRYPOINT ["/init"]
