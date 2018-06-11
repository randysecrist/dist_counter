FROM erlang:20.3.7-alpine
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
ENV ELIXIR_VERSION="v1.6.4" \
	LANG=C.UTF-8 \
	MIX_ENV=dev

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="c12a4931a5383a8a9e9eb006566af698e617b57a1f645a6cb132a321b671292d" \
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
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix do deps.get, deps.compile, compile
RUN mix release

# Hookup Release to Entrypoint and Command
ENTRYPOINT ["docker/entrypoint.sh"]
CMD _build/dev/rel/dist_counter/bin/dist_counter foreground
