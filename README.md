# OwnTone Server - Alpine Linux Docker Image

A lightweight Docker image that builds [OwnTone](https://github.com/owntone/owntone-server) (formerly forked-daapd) from source on Alpine Linux. OwnTone is a media server that shares music libraries over your local network using the DAAP protocol.

The image is built as a multi-arch manifest for **linux/amd64**, **linux/arm64**, and **linux/arm/v7**, and published to Docker Hub as [`rohmilkaese/owntone`](https://hub.docker.com/r/rohmilkaese/owntone). Docker will automatically pull the correct image for your platform.

## Quick Start

```bash
docker run -d \
  --network host \
  -v /path/to/config:/config \
  -v /path/to/music:/music \
  -v /etc/localtime:/etc/localtime:ro \
  --restart unless-stopped \
  rohmilkaese/owntone:master
```

Or with Docker Compose:

```yaml
version: "3"
services:
  owntone:
    image: rohmilkaese/owntone:master
    container_name: owntone
    network_mode: host
    volumes:
      - ./config:/config
      - /path/to/music:/music
      - /etc/localtime:/etc/localtime:ro
    restart: unless-stopped
```

## Ports

| Port | Description |
|------|-------------|
| 3689 | DAAP protocol (music sharing) |
| 3688 | Web interface |

## Volumes

| Path | Description |
|------|-------------|
| `/config` | Persistent configuration and database cache |
| `/music` | Music library directory |

On first start, the default `owntone.conf` is copied to `/config/owntone.conf`. Edit this file to customize the server.

## Building

```bash
docker build -t owntone .
```

To build a specific OwnTone version:

```bash
docker build --build-arg OWNTONE_BRANCH=28.9 -t owntone .
```

## Build Configuration

The Dockerfile compiles OwnTone with the following options:

- iTunes support: **enabled**
- Chromecast: disabled
- MPD: disabled
- Spotify: disabled
- IPv6: disabled
- Runs as: root
- Logs to: stdout (for `docker logs`)

## GitHub Actions

CI is split into two workflows:

1. **Test** (`test.yml`) — Runs on every push to `master`. Builds the Docker image for all platforms (no push). On success, parses `OWNTONE_BRANCH` from the Dockerfile and creates a `v<version>` git tag if it doesn't already exist.
2. **Publish** (`publish.yml`) — Triggered when a `v*` tag is pushed. Builds and pushes the multi-arch image to Docker Hub with semver and `latest` tags.
