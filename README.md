# Swarm Setup

Scripts for setting up a local virtualbox 3 node swarm

## Setup

    ./setup.sh

This will setup 3 docker-machines and attach them to the same Swarm

You can check this has worked by running:

    eval $(docker-machine env manager1)
    docker node ls
