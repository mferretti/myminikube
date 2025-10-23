# Gitea Git Server on Minikube

This directory contains Kubernetes manifests to deploy a lightweight Gitea Git server in a dedicated `git` namespace on Minikube, with persistent storage and Ingress routing for easy access.

## Files
- `namespace.yaml`: Creates the `git` namespace.
- `pvc.yaml`: PersistentVolumeClaim for Gitea data (5Gi).
- `deployment.yaml`: Deploys Gitea with persistent storage.
- `service.yaml`: Exposes Gitea via HTTP (port 3000) and SSH (port 22).
- `ingress.yaml`: Routes `git.test` to the Gitea HTTP service.

## Installation Steps
1. Apply the manifests in order:
   ```bash
   kubectl apply -f git/namespace.yaml
   kubectl apply -f git/pvc.yaml
   kubectl apply -f git/deployment.yaml
   kubectl apply -f git/service.yaml
   kubectl apply -f git/ingress.yaml
   ```
2. Access Gitea at [http://git.test](http://git.test) in your browser.
3. Complete the initial setup in the web UI. The first registered user will be the admin.

## Notes
- Persistent storage is provided via a 2Gi PVC. Adjust as needed in `pvc.yaml`.
- Ingress assumes your system resolves `git.test` to Minikube.
- For test purposes, default settings are used. Adjust manifests for production use.

---
For questions or improvements, open an issue or PR in this repository.