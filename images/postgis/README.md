Using This Image
================
M. Edward (Ed) Borasky

1.  Create a file named `.env` for your environment variables. This name appears in the top-level `.gitignore` file and thus will not be checked into Git!
2.  In `.env`, define the environment variables:

    -   `HOST_POSTGRES_PORT`: the host port you want to use to connect to the PostgreSQL server
    -   `CONTAINER_POSTGRES_PORT`: the port you want the PostgreSQL server to listen on inside the Docker network. If you have multiple containers running PostgreSQL in the network, each one will need to listen on a unique port.
    -   `POSTGRES_PASSWORD`: the password for the `postgres` database user. This string is interpreted as-is; if it contains quotes they'll be part of the password you have to type when connecting!

    Example:

        HOST_POSTGRES_PORT=5439
        CONTAINER_POSTGRES_PORT=5432
        POSTGRES_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess

3.  Type `docker-compose up -d`. Docker-compose will create the network "postgis\_default". Then it will build the `postgis` image if it doesn't exist. Finally it will start the image in container `postgis_postgis_1`
4.  Testing / troubleshooting: If everything worked, you should be able to connect to `HOST_POSTGRES_PORT` on `localhost` as user `postgres` with the `POSTGRES_PASSWORD`. If not, type `docker logs postgis_postgis_1` to see what happened.