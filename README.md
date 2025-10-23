# Minikube Development Environment

This repository contains scripts and Kubernetes configurations to set up a local development environment using Minikube with various services.

## Prerequisites

- For proper DNS resolution on Ubuntu systems, follow the [minikube-dns setup guide](https://github.com/kubernetes/minikube/issues/18727#issuecomment-2432626834)

## Quick Start

```sh
./create-cluster.sh [-l name] [-c cpus] [-m memory] [-n nodes]
```

### Cluster Creation Options

- `-l`: Name of the cluster (default: minikube)
- `-c`: Number of CPUs to allocate (default: 4)
- `-m`: Memory in MB to allocate (default: 8192)
- `-n`: Number of nodes to create (default: 1)

## Available Services

### Database Services

#### PostgreSQL ([`postgresql.yaml`](postgresql.yaml))
- Port: 30042
- Credentials: password="password"
- Includes 1GB persistent volume

#### MySQL ([`mysql.yaml`](mysql.yaml))
- Port: 30036
- Credentials: 
  - Username: mysql
  - Password: "password"
- Includes 1GB persistent volume

### Development Tools

#### Debug Pod ([`debug-pod.yaml`](debug-pod.yaml))
- Ubuntu-based debugging container
- For troubleshooting cluster issues

#### PubSub Emulator ([`pubsub-emulator.yaml`](pubsub-emulator.yaml))
- Google Cloud PubSub emulator
- Port: 31778
- Resource limits: 200m CPU, 200Mi memory

#### Kubernetes Dashboard ([`minikube-dashboard-ingress.yaml`](minikube-dashboard-ingress.yaml))
- Access via `minikube.test` hostname

### Optional Components


#### Gitea Git Server
Follow the [Gitea Git Server Setup](./git/README.md) guide to add a lightweight, persistent Git server to your cluster.

#### SonarQube
Follow the [sonar-minikube installation guide](https://github.com/mferretti/sonar-minikube) to add SonarQube to your cluster

#### Internal docker registry
Follow the [Internal Docker Registry Setup](./registry/README.md) guide to add an accessible docker registry to your cluster 

#### Observability
Follow the [Loki + Grafana Stack Deployment](./loki/README.md) guide to add loki + promtail + grafana to your cluster

## Utility Scripts
- disable-ingress-dns.sh : Disables ingress-dns addon
- create-cluster.sh: Main cluster setup script

## Requirements

- Minikube
- kubectl
- Minimum 4 CPUs, 8GB RAM recommended
