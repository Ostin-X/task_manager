FROM elixir:1.17.3

RUN apt-get update && apt-get install --yes inotify-tools
RUN apt-get update && apt-get install --yes postgresql-client
RUN apt-get update && apt-get install -y npm
RUN mix local.hex --force
RUN mix archive.install hex phx_new --force

WORKDIR /app
COPY ../. /app

EXPOSE 4000
CMD ["./docker/run.sh"]
