# Docker Getting Started

This repository is a simple implementation of a Flask-based application following the tutorials in <https://docs.docker.com/get-started/>. You may also like to read this for a nice introduction to Dockerizing a Flask application: <https://medium.com/@angellom/build-a-docker-image-out-of-a-flask-project-6b22122ff0f0>.

Please note that these materials were created and tested using MacOS Sierra. Your mileage may vary considerably on Windows.

## Prerequisites

  - [Docker installed](https://docs.docker.com/engine/installation/) - this was tested with 18.09.1
  - [docker-compose available](https://docs.docker.com/get-started/part3/#prerequisites) - this was tested with 1.23.2
  - [docker-machine available](https://docs.docker.com/get-started/part4/#prerequisites) - this was tested with 0.16.1
  - The scripts are executed under a Bash environment, with all the Docker tools available in the path.
  - A [Docker Hub account](https://hub.docker.com/) is available for use.

## Building

Assuming the pre-prerequisites are met, then running the application is simple. First update `env.rc` to change relevant values. The only thing you will definitely need to configure is `USER`, as this is used as part of the Docker Hub repository tag. This example builds an image and pushes it to Docker Hub so that the deployed swarm can pull it down (at a later point I hope to investigate whether the Docker Machine can pull from the local docker repository).

Second thing is to ensure you are logged into docker hub, substituting the appropriate `username` which we assume to be the same as the `USER` setting.

```
docker login -u username
```

Next execute the setup script to build the image, construct some docker machines, setup the swarm, and deploy the application:

```
./setup.sh
```

At the end of the execution, the script will report URLs at which you can reach the Visualizer application, and our deployed Flask application. Note that it may take 30 seconds or more for the application stack to stabilise, and Redis to be available. Repeatedly visiting the application should see the count of visits counting up, and the hostname of the actual application instance that is responding changing.

e.g.:
```
Service at    : http://192.168.99.117:4000
Visualizer at : http://192.168.99.117:8080
```

## Cleaning up

Cleaning up when finished is straightforward:

```
./teardown.sh
```

This should halt the application and Docker Stack, and the docker machines created for the demonstration.
