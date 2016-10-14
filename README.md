# Swarm Setup

Scripts for setting up a local virtualbox 3 node swarm with a haproxy instance
to direct domains to the correct app instance. That is, set up a Swarm which
allows for multi-tenancy with the use of HAProxy.

The purpose of this is the prove the concept of using Docker Swarm for powering
a deployment pipeline for features. Something like:

    Development
        |
        v
    Code Review
        |
        v
    Automatically deploy feature branch to it's own environment
        |
        v
    Get it tested by the relevant people
        |
        v
    Once approved, automatically deploy to live
        |
        v
      ?????
        |
        v
    Profit

## Setup

    ./bin/setup.sh

This will setup 3 docker-machines and attach them to the same Swarm then
create [hello-env](https://github.com/cookiefission/hello-env) services for
Bill and Bob.

Once the script has finished running, add `/etc/hosts` entries pointing to
an IP of a node within the Swarm. For example:

    192.168.99.101 bill.docker.dev
    192.168.99.101 bob.docker.dev

Now try hitting the endpoint:

    $ curl bob.docker.dev
    #=> Hello Bob!
