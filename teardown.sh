#!/bin/bash
cd $(dirname $0)

. ./env.rc

eval $(docker-machine env ${MACHINES%% *})
docker stack rm $STACK
eval $(docker-machine env -u)

# remove each docker machine from the swarm, and stop it.
for MACHINE in $MACHINES
do
  echo "Stopping $MACHINE"
  docker-machine ssh $MACHINE "docker swarm leave --force"
  docker-machine stop $MACHINE
  docker-machine rm --force $MACHINE
done

docker rmi getting-started:latest

mv docker-compose.yml.bak docker-compose.yml
