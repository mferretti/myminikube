# Loki + Grafana Stack Deployment

## Introduction
This guide will help you deploy and configure a logging stack using Loki, Grafana, and Promtail on a Kubernetes cluster.

- **Grafana**: An open-source platform for monitoring and observability. It allows you to visualize data and set up alerts.
- **Loki**: A log aggregation system designed to store and query logs efficiently. It’s designed to work well with Grafana.
- **Promtail**: An agent that ships the contents of local log files to a Loki instance.

### Prerequisites
- Minikube installed and configured as per [Minikube development environment](../README.md) setup
- `kubectl` configured
- `docker` installed
- `helm` installed
- Here I use `grafana.test` as my dashboard domain. If you have setup dns resolution to point to a different space than `*.test` then adjust accordingly

### Adding Helm Repositories
Add the Grafana Helm chart repository:

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## Deployment Commands
### Loki Configuration (`loki-values.yaml`)

- `loki.enabled`: Enable or disable Loki.  
- `loki.size`: Persistent volume size to store logs.  
- `promtail.enabled`: If true, Promtail is deployed to collect logs.  
- `grafana.enabled`: If true, Grafana is deployed.  
- `grafana.sidecar.datasources.enabled`: Enables the Datasource sidecar for automatic datasource management.  

### Deploy Loki Stack
Create a namespace and deploy Loki with the specified configuration:

```bash
helm upgrade --install loki --namespace=loki-stack grafana/loki-stack --values loki-values.yaml --create-namespace
```

### Grafana Agent Configuration (`grafana-agent-values.yaml`)

- Runs Grafana Agent in flow mode.
- Logs are captured in "logfmt" format at the "info" level.
- Collects Kubernetes events in JSON format and forwards them to Loki.
- Sends log data to the Loki endpoint via "http://loki.loki-stack:3100".

### Deploy Grafana Agent

```bash
helm upgrade --install grafana-agent --namespace=loki grafana/grafana-agent --values grafana-agent-values.yaml
```

### Get Admin Password for Grafana

```bash
kubectl get secret loki-grafana -n loki-stack -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

### Access Grafana Dashboard
Ensure you have the [grafana-ingress](./grafana-dashboard-ingress.yaml) resource deployed:

```bash
kubectl apply -f grafana-dashboard-ingress.yaml
```

Ensure [dnsmasq](https://github.com/kubernetes/minikube/issues/18727#issuecomment-2432626834) is configured properly if using `.test` domains. Access the Grafana UI at `http://grafana.test`.

## Example Deployment to Generate Logs
Create an example deployment that emits logs in JSON format; here's a simpe [log emitter](./log-emitter.yaml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-logger
  namespace: loki-stack
spec:
  replicas: 1
  selector:
    matchLabels:
      app: logger
  template:
    metadata:
      labels:
        app: logger
    spec:
      containers:
      - name: logger
        image: busybox
        command: ["sh", "-c", "while true; do echo '{\"message\": \"Hello from the logger\"}'; sleep 5; done;"]
```

Apply the deployment:

```bash
kubectl apply -f example-logger-deployment.yaml
```

## Creating a Simple Grafana Dashboard
Follow these steps to create a basic Grafana dashboard:

1. Open the Grafana UI at `http://grafana.test`.
2. Log in using the admin password obtained earlier.
3. Go to **Configuration > Data Sources**; you should already see a default loki datasource; if not, add a new data source, and select **Loki**.
   - Set the URL to `http://loki.loki-stack:3100`.
   - Click **Save & Test**.
4. Go to **Dashboards > Manage > New Dashboard**.
5. Click **Add a New Panel**.
6. In the query editor, select **Loki** as the data source.
7. Enter the following query to filter logs from the example deployment:

   ```
   {app="logger"}
   ```

8. Set visualization to **Logs**.
9. Click **Apply**.
10. Save the dashboard with a meaningful name.

You now have a basic Grafana dashboard that monitors logs from your example deployment.

