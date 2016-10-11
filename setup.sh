#!/usr/bin/env bash

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
docker-machine ssh worker1 "docker swarm join --token $SWARM_WORKER_JOIN_TOKEN $SWARM_MANAGER_IP:2377"
docker-machine ssh worker2 "docker swarm join --token $SWARM_WORKER_JOIN_TOKEN $SWARM_MANAGER_IP:2377"
