# Caliboat: Dockerized Calibre

Recent versions of Debian no longer package stable versions of Calibre that run atop Python 2. Unfortunately, many Calibre plugins have not kept pace, including DeDRM. This simple Dockerfile starts with Ubuntu 18.04, installs Calibre, and retrieves DeDRM 6.8.0.

## Overview

The build by default creates:

* A Docker container image configured with a user/group combination configured with a UID/GID matching that of the user running the build on your host OS, with everything from the app subdirectory copied into /app in the container image.
* A script called `caliboat` that will start containerized Calibre with volume mappings for your host user's:
    * X11 socket
    * Calibre library
    * Calibre config parent directory (by default `~/.config`)
    * Kindle content (by default `~/My\ Kindle\ Content`)

Calibre state will thus persist across executions. If you wish, you can then add an item to your desktop environment launcher to run `caliboat` more or less transparently.

## Build

First, make sure you have a working Docker installation. Please do not ask me for help with this.

Second, add any files you might need inside the container (such as your Kindle for PC encryption key) to the app/ subdirectory.

Then, if you are able to run docker as your non-root user, simply run:

```
make
```

Otherwise, run:

```
make sudo
```

## Run Calibre

If all is successful, you should have a script called `caliboat` that will instantiate the `caliboat` container and by default run `Calibre` inside the container. You may override this default by providing arguments to caliboat: for example, to start a shell in the container, run `./caliboat bash`.

Once you have a running Dockerized Calibre, you will then need to configure DeDRM appropriately. Please refer to DeDRM's documentation for more information.
