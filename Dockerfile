FROM erlang:20

ADD . /root
WORKDIR /root
EXPOSE 6000-6999

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.5.1" \
	LANG=C.UTF-8 \
	MIX_ENV=dev

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="9a903dc71800c6ce8f4f4b84a1e4849e3433e68243958fd6413a144857b61f6a" \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix do deps.get, deps.compile, compile

CMD ["iex", "--name", "counter1@counter1", "--cookie", "monster", "-S", "mix"]
