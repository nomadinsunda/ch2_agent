# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A minimal Docker sidecar image ("agent" container) that watches a web service and alerts via a mailer service when it goes down. Built on `busybox`, running a single shell script (`watcher.sh`) as an unprivileged user (`example`).

## Build & publish

```shell
docker build -t docker.io/intheeast0305/ch2_agent:latest .
docker push docker.io/intheeast0305/ch2_agent:latest
```

There is no test suite or linter configured in this repo.

## Architecture

- `Dockerfile` — builds from `busybox`, copies the repo into `/watcher`, creates a non-root user `example`, and runs `watcher.sh` as the container entrypoint.
- `watcher.sh` — the entire runtime logic. In an infinite loop, it sends a raw HTTP GET to the `insideweb` host on port 80 via `nc` (wrapped in `timeout 2` to avoid hanging on a stalled connection) and checks the response for `200 OK`. On success it logs `System up.`. On failure it sends a plaintext alert to the `insidemailer` host on port 33333 via `nc` (also wrapped in `timeout 2`) and logs `Alert sent.`. Either way it sleeps 1s and loops again — it does **not** exit on failure, so the container keeps re-checking and re-alerting every second until the service recovers.
- The hostnames `insideweb` and `insidemailer` are expected to be resolvable at runtime (e.g. `--link` aliases or container names on a shared user-defined Docker network), not set explicitly in this repo.
- No web/mailer service code lives in this repo — this container only assumes those two services are reachable by those hostnames at runtime.
