#!/bin/bash
cd $(dirname $0)

. ./env.rc

# inject $USER into docker-compose.yml
sed -i .bak "s/{{USER}}/$USER/" docker-compose.yml

# report the docker version
echo "*****************************************"
echo "* Create application Docker image       *"
echo "*****************************************"

docker --version

# build the image and push it to Docker Hub
docker build --tag getting-started .
docker tag getting-started $USER/getting-started:latest
docker push $USER/getting-started:latest

# set up Docker machines if needed, or simply start them.
echo "*****************************************"
echo "* Create or start Docker Machines       *"
echo "*****************************************"

for MACHINE in $MACHINES
do
  STATE=$(docker-machine status $MACHINE 2>/dev/null)
  if [ -z "$STATE" ]
  then
    echo "Creating $MACHINE"
    docker-machine create --driver virtualbox $MACHINE
  fi

  if [ "$STATE" == "Stopped" ]
  then
    echo "Starting $MACHINE"
    docker-machine start $MACHINE
  fi
done

# find the IP address of the first machine in the list, and make it the swarm manager.
echo "*****************************************"
echo "* Setup swarm manager                   *"
echo "*****************************************"

MANAGER=${MACHINES%% *}
MANAGER_IP=$(docker-machine inspect --format='{{.Driver.IPAddress}}' $MANAGER)
docker-machine ssh $MANAGER "docker swarm init --advertise-addr $MANAGER_IP"

# we need to create a data directory for redis
docker-machine ssh $MANAGER "mkdir -p ./data"

# we don't try to capture the first token, but reset the token and capture that
TOKEN=$(docker-machine ssh $MANAGER "docker swarm join-token manager --quiet")

# enlist each of the other machines in the swarm
echo "*****************************************"
echo "* Enlist machines in the swarm          *"
echo "*****************************************"

for MACHINE in $MACHINES
do
  if [ "$MACHINE" != "$MANAGER" ]
  then
    docker-machine ssh $MACHINE "docker swarm join --token $TOKEN $MANAGER_IP:2377"
  fi
done

echo "*****************************************"
echo "* Swarm configuration                   *"
echo "*****************************************"

echo "Manager = $MANAGER_IP"
echo "Token = $TOKEN"
docker-machine ls
docker-machine ssh $MANAGER "docker node ls"

# now deploy the application
echo "*****************************************"
echo "* Deploy application stack              *"
echo "*****************************************"

eval $(docker-machine env $MANAGER)
docker stack deploy -c docker-compose.yml $STACK
eval $(docker-machine env -u)

echo "*****************************************"
echo "* Application Configuration             *"
echo "*****************************************"

docker-machine ssh $MANAGER "docker service ls"
echo "Service at    : http://$MANAGER_IP:4000"
echo "Visualizer at : http://$MANAGER_IP:8080"
