FROM python:3.14.5-slim-trixie@sha256:c845af9399020c7e562969a13689e929074a10fd057acd1b1fad06a2fb068e97

ARG BUILD_DATE
ARG BUILD_REVISION
ARG IMAGE_VERSION
ARG SOURCE_URL

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.description="SEC Filing RAG Stage 1.6 delivery probe" \
      org.opencontainers.image.licenses="PolyForm-Noncommercial-1.0.0" \
      org.opencontainers.image.revision="${BUILD_REVISION}" \
      org.opencontainers.image.source="${SOURCE_URL}" \
      org.opencontainers.image.title="sec-filing-rag-probe" \
      org.opencontainers.image.version="${IMAGE_VERSION}"

RUN groupadd --gid 10001 probe \
    && useradd --uid 10001 --gid 10001 --no-create-home \
        --home-dir /nonexistent --shell /usr/sbin/nologin probe

WORKDIR /app
COPY --chown=10001:10001 probe.py /app/probe.py

ENV BUILD_REVISION="${BUILD_REVISION}" \
    IMAGE_VERSION="${IMAGE_VERSION}" \
    PORT=8080 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER 10001:10001
EXPOSE 8080

HEALTHCHECK --interval=5s --timeout=3s --start-period=2s --retries=10 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/healthz', timeout=2).read()"]

ENTRYPOINT ["python", "/app/probe.py"]
