# ExpertAdvice

## Development

### Prepare your environment
1. install [Docker and docker-compose](https://docs.docker.com/v17.12/install/)
2. in the project root directory run `docker-compose -f ./docker-compose-dev.yml up -d` to run the Postgres DBMS in a Docker container
3. run `mix ecto.create` and `MIX_ENV=test mix ecto.create` to create the databases.
4. run `mix ecto.migrate` to run migrations
