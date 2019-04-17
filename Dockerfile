FROM erlang:21.2.7-alpine
MAINTAINER randy.secrist@gmail.com

# OS Setup
WORKDIR /root

# Install OS Packages
RUN set -xe \
  && apk --no-cache --update upgrade \
  && apk --no-cache add curl make git bash g++ jq \
  && rm -rf /var/cache/apk/*

# setup os user
COPY docker/setup.sh /
RUN /setup.sh && rm /setup.sh

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.8.1" \
	LANG=C.UTF-8 \
	MIX_ENV=dev

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="de8c636ea999392496ccd9a204ccccbc8cb7f417d948fd12692cda2bd02d9822" \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean

USER root
ADD . /home/elixir
WORKDIR /home/elixir
RUN chown -R elixir:elixir .

USER elixir
RUN MIX_ENV=dev mix do local.hex --force, local.rebar --force
RUN MIX_ENV=dev mix do deps.get, deps.compile, compile
RUN MIX_ENV=dev mix release --env=dev

# Hookup Release to Entrypoint and Command
ENV REPLACE_OS_VARS true
ENTRYPOINT ["docker/entrypoint.sh"]
CMD _build/dev/rel/dist_counter/bin/dist_counter foreground
