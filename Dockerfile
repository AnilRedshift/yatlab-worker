FROM elixir:1.6.3

WORKDIR /usr/src/yatlab-worker

ENV REPLACE_OS_VARS true
ENV MIX_ENV prod
ENV ERLANG_COOKIE "$ERLANG_COOKIE"

RUN mix local.hex --force
RUN mix local.rebar --force

# Install just the dependencies first to cache layers better
COPY mix.exs ./
COPY mix.lock ./
RUN mix deps.get

# Copy over the remaining files
COPY . .
RUN mix release
CMD ["_build/prod/rel/worker/bin/worker", "foreground"]
