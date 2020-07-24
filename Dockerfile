FROM ubuntu:18.04

ARG UNAME=calibre
ARG UID=1000
ARG GID=1000
ARG ADD_PACKAGES=

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip calibre
RUN if [ -n "$ADD_PACKAGES" ]; then DEBIAN_FRONTEND=noninteractive apt-get install -y $ADD_PACKAGES; fi
RUN mkdir -p /app && chown $UID:$GID /app
RUN addgroup --gid $GID $UNAME
RUN adduser --uid $UID --gid $GID --no-create-home --disabled-password --shell /bin/bash --gecos '' --home /app $UNAME
COPY app /app
USER $UNAME
RUN curl -Lf https://github.com/apprenticeharper/DeDRM_tools/releases/download/v6.8.0/DeDRM_tools_6.8.0.zip -o /tmp/DeDRM_tools.zip && \
    unzip -d /app /tmp/DeDRM_tools.zip
CMD /usr/bin/calibre
