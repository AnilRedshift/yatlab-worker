# Yatlab-Worker

This contains the worker that runs the slack-bots for yatlab. It polls the database which contains the team tokens as well as the acronyms. For each team, it creates a slack bot that listens for messages. When the slack bot gets a message, it compares it to the acronyms and sends a response accordingly.

## Installation
Prerequisites: Elixir

1. `git clone git@github.com:AnilRedshift/yatlab-worker.git`
1. `mix deps.get`
1. Add the following secrets to your environment:
    * REPLACE_OS_VARS=true
    * DB_HOST (The hostname of your postgres server)
    * DB_USER (The username for postgres)
    * DB_PASS (The password for postgres)
    * DB_PATH (The database to connect to)
    * ERLANG_COOKIE (A cookie used to secure? the release)

1. `mix test` (make sure the tests pass)
1. `mix release`
1. `_build/dev/rel/worker/bin/worker console`

There is also a docker-compose file, which defaults to building the prod environment

## Development
The biggest thing to note is that the codebase uses [distillery](https://github.com/bitwalker/distillery) to generate the app. This way, environment variables can be substituted at runtime. The application starts up a monitor which polls the database for new teams to watch. Each team gets it's own process, and that connects to slack. This codebase is completely independent of the yatlab web component.


## Tests
The code uses Mox to stub out external dependencies (slack & the database). I followed the pattern [here](https://blog.carbonfive.com/2018/01/16/functional-mocks-with-mox-in-elixir/)

## Deploying
There's a Dockerfile that gets built and the same environment variables are passed into it. The production environment uses `yarn build` and `yarn server`


## Yatlab architecture overview
Yatlab is made out of 3 github repositories and 4 services

1. [yatlab-nginx](https://github.com/AnilRedshift/yatlab-nginx) handles traffic to https://yatlab.terminal.space and reverse-proxy's it to the web service
2. [yatlab](https://github.com/AnilRedshift/yatlab) Handles the website, and stores the data it receives in a database. The website is independent of the slack bot itself.
3. There is a postgres database which contains the data about the teams and acronyms
4. [yatlab-worker](https://github.com/AnilRedshift/yatlab-worker) polls the database for changes and connects to each slack team using the slack api
