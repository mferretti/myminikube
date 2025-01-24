# Internal Docker Registry Setup

## Files Overview

- `setup-certs.sh`: Certificate generation and trust setup script
- `registry.yaml`: Kubernetes configuration for registry deployment
- `test.yaml`: Test pod configuration

## Setup Sequence

### Prerequisites
- Minikube installed and configured as per [Minikube development environment](../README.md) setup
- `kubectl` configured
- `docker` installed
- Here I use `registry.test` as my registry domain. If you have setup dns resolution to point to a different space than `*.test` then adjust accordingly
### Steps
1. Make sure minikube is not running (will need to restart docker)
   ```bash 
   minikube stop
   ```
2. Generate Certificates
   ```bash
   bash setup-certs.sh
   ```
   - Creates CA and TLS certificates
   - Updates Docker trust store
   - Creates Kubernetes TLS secret

3. Configure Docker Client
   - Add to `/etc/docker/daemon.json`:
     ```json
     {
       "insecure-registries": ["registry.test"]
     }
     ```
   - Restart Docker daemon

4. Add CA Certificate
   ```bash
   sudo cp ca.crt /etc/docker/certs.d/registry.test/ca.crt
   ```

5. Start minikube
   ```bash
   minikube start
   ```
6. Apply Kubernetes Resources
   ```bash
   kubectl create namespace registry
   kubectl apply -f registry.yaml
   ```
7. Create secrets for ingress tls
   ```bash
   kubectl delete secret registry-tls -n registry || true
   kubectl create secret tls registry-tls \
      --cert=tls.crt \
      --key=tls.key \
      -n registry
   ```

8. Verify Registry
   ```bash
   kubectl apply -f test.yaml -n registry
   kubectl logs -n registry po/registry-test
   ```



## Post-Installation
- Registry accessible at `registry.test`
- No authentication configured
- Suitable for local/development use