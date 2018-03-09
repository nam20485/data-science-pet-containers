-   [Data Science Pet Containers](#data-science-pet-containers)
    -   [Setting up](#setting-up)
    -   [Automatic database restores](#automatic-database-restores)
    -   [Starting the services](#starting-the-services)
    -   [Using the services](#using-the-services)
        -   [PostGIS](#postgis)
            -   [Connecting with pgAdmin on the
                host](#connecting-with-pgadmin-on-the-host)
            -   [Using the command line in the `postgis`
                server](#using-the-command-line-in-the-postgis-server)
        -   [Miniconda](#miniconda)
        -   [RStudio](#rstudio)
    -   [About the name](#about-the-name)

Data Science Pet Containers
===========================

M. Edward (Ed) Borasky <znmeb@znmeb.net>, 2018-03-08

Setting up
----------

1.  Clone this repository and
    `cd data-science-pet-containers/containers`.
2.  Define the environment variables.
    -   Copy the file `sample.env` to `.env`. For security reasons,
        `.env` is listed in `.gitignore`, so it ***won't*** be checked
        into version control.
    -   Edit `.env`. The variables you need to define are
        -   `HOST_POSTGRES_PORT`: If you have PostgreSQL installed on
            your host, it's probably listening on port 5432. The
            `postgis` service listens on port 5432 inside the Docker
            network, so you'll need to map its port 5432 to another
            port. Set `HOST_POSTGRES_PORT` to the value you want; 5439
            is what I use.
        -   `POSTGRES_PASSWORD`: To connect to the `postgis` service,
            you need a user name and a password. The user name is the
            default, the database superuser `postgres`. Docker will set
            the password for the `postgres` user in the `postgis`
            service to the value of `POSTGRES_PASSWORD`.

    Here's `sample.env`:

        # postgis container
        HOST_POSTGRES_PORT=5439
        POSTGRES_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess

Automatic database restores
---------------------------

When the `postgis` service first starts, it initializes the database.
After that, it looks in a directory called
`/docker-entrypoint-initdb.d/` and restores any `.sql` or `sql.gz` files
it finds. Then it looks for `.sh` scripts and runs them.

We use this to restore databases as follows:

-   For any database you want restored, create a file `<dbname>.backup`
    with either a pgAdmin `Backup` operation or with `pg_dump`. The file
    must be in [`pg_dump`
    format](https://www.postgresql.org/docs/current/static/app-pgdump.html).
-   Before running `docker-compose`, copy those backup files into
    `data-science-pet-containers/containers/Backups`. Note that
    `.gitignore` is set for `*.backup`, so these backup files won't be
    version-controlled.
-   At build time, Docker copies the backup files into
    `/home/postgres/Backups` on the `postgis` image. And it places a
    script `restore-all.sh` in `/docker-entrypoint-initdb.d/`. ***If you
    change any of the backups, you will need to rebuild the `postgis`
    image.***
-   The first time the image runs, `restore-all.sh` will restore all the
    `.backup` files it finds in `/home/postgres/Backups`.

    `restore-all.sh` creates a new database with the same name as the
    file. For example, `passenger_census.backup` will be restored to a
    freshly-created database called `passenger_census`. The new
    databases will have the owner `postgres`.

Starting the services
---------------------

1.  Choose your version:

    -   `postgis.yml`: PostGIS only. If you're doing all the analysis on
        the host and just want the PostGIS service and its restored
        databases, choose this.  
    -   `miniconda.yml`: PostGIS and Miniconda. Choose this if you want
        to run a Jupyter notebook server inside the Docker network.
    -   `rstudio.yml`: PostGIS and RStudio Server. Choose this if you
        want an RStudio Server inside the Docker network.

2.  Type `docker-compose -f <version> up -d --build`. Docker will
    build/rebuild the images and start the services.

Using the services
------------------

### PostGIS

The `postgis` service is based on the official PostgreSQL image from the
Docker Store: <https://store.docker.com/images/postgres>. It is running
PostgreSQL 10, PostGIS 2.4, pgRouting 2.5 and all of the foreign data
wrappers that are available in a Debian PostgreSQL server. All of these
images acquire PostgreSQL and its accomplices from the official
PostgreSQL Global Development Group (PGDG) Debian repositories:
<https://www.postgresql.org/download/linux/debian/>.

Connecting to the service:

-   From the host, connect to `localhost`, port `HOST_POSTGRES_PORT`.
-   Inside the Docker network, connect to `postgis`, port 5432.
-   In both cases, the username and maintenance database are `postgres`
    and the password is `POSTGRES_PASSWORD`.

#### Connecting with pgAdmin on the host

If you've installed the EnterpriseDB PostgreSQL distribution, you
probably already have pgAdmin, although it may not be the latest
version. Here are the links if you want to install it without
PostgreSQL:

-   macOS installer: <https://www.pgadmin.org/download/pgadmin-4-macos/>
-   Windows: <https://www.pgadmin.org/download/pgadmin-4-windows/>

To connect to the `postgis` service on `localhost:HOST_POSTGRES_PORT`
with pgAdmin:

1.  Right-click on `Servers` and create a server. Give it any name you
    want.
2.  On the `Connection` tab, set the host to `localhost`, the port to
    `HOST_POSTGRES_PORT`, the maintenance database to `postgres`, the
    user name to `postgres` and the password to the value you set for
    `POSTGRES_PASSWORD`.
3.  Check the `Save password` box and press the `Save` button. `pgAdmin`
    will add the tree for the `postgis` service.

#### Using the command line in the `postgis` server

There are two Linux accounts available, `root`, the Linux superuser, and
`postgres`, the database superuser. Type
`docker exec -it -u <account> containers_postgis_1 /bin/bash` and you'll
be logged in.

I've tried to provide a comprehensive command line experience. `Git` and
`vim` are there, as is most of the command-line GIS stack (`gdal`,
`proj`, `spatialite`, `rasterlite`, `geotiff`, `osm2pgsql` and
`osm2pgrouting`), and of course `psql`. I've also included
`python3-csvkit` for Excel, CSV and other text files, `unixodbc` for
ODBC connections and `mdbtools` for Microsoft Access files.

### Miniconda

This service is based on the Anaconda, Inc. (formerly Continuum)
`miniconda3` image: <https://hub.docker.com/r/continuumio/miniconda3/>.
I've added a non-root user `jupyter` to avoid the security issues
associated with running Jupyter notebooks as "root".

The `jupyter` user has a Conda environment, also called `jupyter`. To
keep the image size manageable, only the `jupyter` package is installed.

By default the Jupyter notebook server starts when Docker brings up the
service. Type `docker logs containers_miniconda_1`. You'll see something
like this:

    ```
    $ docker logs containers_miniconda_1 
    [I 02:40:47.554 NotebookApp] Writing notebook server cookie secret to /home/jupyter/.local/share/jupyter/runtime/notebook_cookie_secret
    [I 02:40:47.877 NotebookApp] Serving notebooks from local directory: /home/jupyter
    [I 02:40:47.877 NotebookApp] 0 active kernels
    [I 02:40:47.877 NotebookApp] The Jupyter Notebook is running at:
    [I 02:40:47.877 NotebookApp] http://0.0.0.0:8888/?token=865963175cdf86fd8fb6c98a6ef880803cb9f1ef6cf10960
    [I 02:40:47.877 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
    [C 02:40:47.877 NotebookApp] 

    Copy/paste this URL into your browser when you connect for the first time,
    to login with a token:
        http://0.0.0.0:8888/?token=865963175cdf86fd8fb6c98a6ef880803cb9f1ef6cf10960
    ```

Browse to `localhost:8888` and copy/paste the token when the server asks
for it.

The Jupyter "New Terminal" works, but the terminal comes up in `sh`
instead of `bash`. So if you use the terminal, type
`bash; source activate jupyter` to get a `bash` prompt. Once you have
the `jupyter` environment activated, you can install all the packages
you need via `conda install`.

### RStudio

This service is based on the `rocker/rstudio` image from Docker Hub:
<https://hub.docker.com/r/rocker/rstudio/>. All of the command line
tools from the `postgis` image are available.

Browse to `localhost:8787`. The user name and password are both
`rstudio`. ***Note that if you're using Firefox, you'll have to adjust a
setting to use the terminal feature.*** Go to
`Tools -> Global Options -> Terminal`. For Firefox, you need to uncheck
the `Connect with WebSockets` option. Other browsers I've tried,
Microsoft Edge and Chromium, don't need this.

About the name
--------------

This all started with an infamous "cattle, not pets" blog post. For some
history, see
<http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/>.
In the Red Hat / Kubernetes / OpenShift universe, it's common for people
to have a workstation that's essentially a Docker / Kubernetes host with
all the actual work being done in containers. See
<https://rhelblog.redhat.com/2016/06/08/in-defense-of-the-pet-container-part-1-prelude-the-only-constant-is-complexity/>
and
<https://www.projectatomic.io/blog/2018/02/fedora-atomic-workstation/>.

So - pet containers for data scientists.
