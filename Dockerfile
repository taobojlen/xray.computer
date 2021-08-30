FROM hexpm/elixir:1.12.2-erlang-24.0.1-alpine-3.13.3 AS build

# install build dependencies
RUN apk add --no-cache \
  build-base=0.5-r2 \
  npm=14.17.5-r0 \
  git=2.30.2-r0 \
  python3=3.8.10-r0

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

COPY lib lib

# build assets (depends on elixir source for PurgeCSS)
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN mix do assets.deploy, phx.digest

# compile and build release
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release

# prepare release image
FROM alpine:3.13.5 AS app
RUN apk add --no-cache \
  openssl=1.1.1l-r0 \
  ncurses-libs=6.2_p20210109-r0 \
  bash=5.1.0-r0 \
  libstdc++=10.2.1_pre1-r3 \
  git=2.30.2-r0 \
  curl=7.78.0-r0 \
  npm=14.17.5-r0 \
  && npm install -g prettier@2.3.2

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY CHECKS ./
COPY Procfile ./
COPY app.json ./
COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/xray ./

ENV HOME=/app

CMD ["bin/xray", "start"]
