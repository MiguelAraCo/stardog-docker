# stardog-docker

Dockerfile for [Stardog](http://stardog.com)

Due to Stardog licensing scheme the image can't be published publicly.

## Build

- Download Stardog: [http://stardog.com/#download](http://stardog.com/#download )
- Run:

  ```bash
  docker build --tag stardog --build-arg file=/directory/to/stardog/zip/file.zip .
  ```

  **Note:** Replace `/directory/to/stardog/zip/file.zip` with the path to the zip you downloaded in the previous step

## Usage

The image is designed to be very flexible. Any command you can normally execute on a Stardog server is available on the image.

### Running a Stardog server

- Obtain a license file for the Stardog instance. This is normally provided on the email received while requesting the binary file. You should end up having a file with a name similar to `stardog-license-key.bin`
- **Recommended:** Although not needed, it is recommended to create a Docker volume or a local directory so Stardog's data can survive container restarts or re-creations
- Run:

  ```bash
  docker run -dit \
    --name stardog \
    -p 5820:5820 \
    -v /path/to/directory/created/or/docker/volume:/data \
    -v /path/to/stardog-license-key.bin:/data/stardog-license-key.bin \
    stardog \
    stardog-admin server start --foreground
  ```

  **Note:** The parameters provided to the container are the actual command used to run a Stardog server `stardog-admin server start --foreground`

### Running other commands

Any parameter sent to the image will be executed as if it was executed inside of the `STARDOG_INSTALLATION/bin` directory. This allows [Stardog CLI](http://www.stardog.com/docs/#_command_line_interface) tools with the image.

The CLI tools normally behave as clients to a Stardog server so a running server will need to be created before using the tools.

After a container is running a server other containers can be used to communicate with it. This is achieved by linking the server container to the client containers through the `--link` parameter and specifying the server to the Stardog CLI tool.

Examples:

#### Creating a database

```bash
docker run -it --rm \
    --link stardog:stardog \
    stardog \
    stardog-admin \
        --server http://stardog:5820 \
        db create -n myDB -v -o versioning.enabled=true preserve.bnode.ids=true strict.parsing=false --
```

#### Changing the default admin password

```bash
docker run -it --rm \
    --link stardog:stardog \
    stardog \
    stardog-admin \
        --server http://stardog:5820 \
        user passwd -u admin -p admin --new-password $@#$%234fSDF admin
```

