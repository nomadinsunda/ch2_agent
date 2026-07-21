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
- `watcher.sh` — the entire runtime logic. In a loop, it sends a raw HTTP GET to `$INSIDEWEB_PORT_80_TCP_ADDR:$INSIDEWEB_PORT_80_TCP_PORT` via `nc` and checks the response for `200 OK`. On success it logs and loops (sleeping 1s between checks). On failure it sends a plaintext alert to `$INSIDEMAILER_PORT_33333_TCP_ADDR:$INSIDEMAILER_PORT_33333_TCP_PORT` via `nc` and exits the loop (container ends).
- Environment variables `INSIDEWEB_PORT_80_TCP_ADDR`/`_PORT` and `INSIDEMAILER_PORT_33333_TCP_ADDR`/`_PORT` are expected to be injected by the container orchestration (classic Docker `--link` style linked-container env vars), not set explicitly in this repo.
- No web/mailer service code lives in this repo — this container only assumes those two linked services exist at runtime.
