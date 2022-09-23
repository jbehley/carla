# Building Carla in a Docker

_These instructions have been tested in **Ubuntu 16.04**._

This file is intended to explain how to build a Docker image that uses **Ubuntu 18.04** to compile Carla.

Since this building process is based on [**ue4-docker**](https://github.com/adamrehn/ue4-docker) project, it is recommended to take a look at their [documentation](https://adamrehn.com/docs/ue4-docker/read-these-first/introduction-to-ue4-docker).

## Important information

**Building these Docker images can be high time and disk space consuming (~4 hours and up to 300GB on Linux and 500GB on Windows in the build process).**

More information about large containers can be found [here](https://adamrehn.com/docs/ue4-docker/read-these-first/large-container-images-primer).

**The Docker images produced by the ue4-docker Python package contain the UE4 Engine Tools in both source code and object code form. As per Section 1A of the [Unreal Engine EULA](https://www.unrealengine.com/en-US/eula), Engine Licensees are prohibited from public distribution of the Engine Tools unless such distribution takes place via the Unreal Marketplace or a fork of the Epic Games UE4 GitHub repository. Public distribution of the built images via an openly accessible Docker Registry (e.g. Docker Hub) is a direct violation of the license terms. It is your responsibility to ensure that any private distribution to other Engine Licensees (such as via an organization's internal Docker Registry) complies with the terms of the Unreal Engine EULA.**  

For more details, see the [Unreal Engine EULA Restrictions](https://unrealcontainers.com/docs/obtaining-images/eula-restrictions) page on the [Unreal Containers community hub](https://unrealcontainers.com/).

## Requirements

```
- 64-bit version of Docker in Ubuntu 16.04+.
- Minimum 8GB of RAM
- Minimum 300GB available disk space for building container images
```

---

## Prerequisites

You need Docker installed and configured so your Docker images can access to the Internet during the build process.

Make sure you have installed **Python 3.6 or newer**, check that is in the path, and is callable using `python3` in your terminal. One possible way to achieve so is by using [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/).

## Dependencies

For authenticating with github, you need to have a working ssh authentication on your host systems, i.e., ssh keys in '~/.ssh' where the public key was added to your github repository. 
Currently, the docker image is tested and working with passphrase-less ssh keys, but such keys should be only used for building the docker image.

## Building the Docker images

Navigate to `carla/Util/Docker` and use the following commands, each one will take a long time.  
First, this will build the image with all the necessary requisites to build Carla in a **Ubuntu 18.04**

```
docker build -t carla-prerequisites --build-arg ssh_prv_key="$(cat ~/.ssh/id_ed25519)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_ed25519.pub)" -f Prerequisites.Dockerfile .
```

Finally create the actual Carla image, it will search for `carla-prerequisites:latest`:

```
docker build -t carla -f Carla.Dockerfile .
```

---

## Other useful information

You can use a specific repository **branch** or **tag** from our repository, using:

```
docker build -t carla -f Carla.Dockerfile . --build-arg GIT_BRANCH=branch_name
```

Clean up the intermediate images from the build (keep the ue4-source image so you can use it for full rebuilds)

```
ue4-docker clean
```

## Using the Docker tools

The `docker_tools.py` (in `/carla/Util/Docker`) is an example of how you can take advantages of these Docker images. It uses [docker-py](https://github.com/docker/docker-py) whose documentation can be found [here](https://docker-py.readthedocs.io/en/stable/).  
The code is really simple and can be easily expanded to interact with docker in other ways.

You can create a Carla package (distribution) from the Docker image using:

```
./docker_tools.py --output /output/path
```

Or you can use it to cook assets (like new maps and meshes), ready to be consumed by a Carla package (distribution):

```
./docker_tools.py --input /assets/to/import/path --output /output/path --packages PkgeName1,PkgeName2
```

The needed files and hierarchy to import assets is explained [here](https://carla.readthedocs.io/en/latest/export_import_dist/).
