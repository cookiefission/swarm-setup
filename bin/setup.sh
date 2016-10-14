#!/usr/bin/env bash

set -e

machine-env() {
    eval $(docker-machine env $1)
}

# Create machines
docker-machine create -d virtualbox manager1
docker-machine create -d virtualbox worker1
docker-machine create -d virtualbox worker2

# Get manager node IP
SWARM_MANAGER_IP=$(docker-machine ip manager1)

echo
echo
echo Swarm Manager IP:          $SWARM_MANAGER_IP
echo
echo

# Create the swarm
docker-machine ssh manager1 "docker swarm init --advertise-addr $SWARM_MANAGER_IP"

# Get the swarm worker join-token
SWARM_WORKER_JOIN_TOKEN=$(docker-machine ssh manager1 "docker swarm join-token worker -q")

echo
echo
echo Swarm Worker Join Token:           $SWARM_WORKER_JOIN_TOKEN
echo
echo

# Join Swarm from worker nodes
machine-env worker1
docker swarm join --token $SWARM_WORKER_JOIN_TOKEN $SWARM_MANAGER_IP:2377

machine-env worker2
docker swarm join --token $SWARM_WORKER_JOIN_TOKEN $SWARM_MANAGER_IP:2377

# Create networks
machine-env manager1

docker network create --driver overlay proxy
docker network create --driver overlay application

# Start proxy service
docker service create --name proxy \
    -p 80:80 \
    -p 443:443 \
    -p 8080:8080 \
    --network proxy \
    -e MODE=swarm \
    vfarcic/docker-flow-proxy

docker service create --name hello-bob \
    --network proxy \
    --network application \
    -e HELLO_TO=Bob \
    seankenny/hello-env

docker service create --name hello-bill \
    --network proxy \
    --network application \
    -e HELLO_TO=Bill \
    seankenny/hello-env

until curl -s -o /dev/null "http://$SWARM_MANAGER_IP:8080/v2/test"; do
    echo "Waiting for proxy service"
    sleep 5
done

curl "$(docker-machine ip manager1):8080/v1/docker-flow-proxy/reconfigure?serviceName=hello-bob&servicePath=/&serviceDomain=bob.docker.dev&port=8000"
curl "$(docker-machine ip manager1):8080/v1/docker-flow-proxy/reconfigure?serviceName=hello-bill&servicePath=/&serviceDomain=bill.docker.dev&port=8000"

echo
echo "Add these lines to /etc/hosts"
echo
echo "           $SWARM_MANAGER_IP bob.docker.dev"
echo "           $SWARM_MANAGER_IP bill.docker.dev"
echo
