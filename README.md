# LiteLLM LLMOps Infrastructure

Production-grade LLM Gateway deployed on AWS EKS with full observability stack.

## Architecture
Internet → FreeDNS → AWS ELB → Nginx Ingress Controller

├── LiteLLM      (kailashtech.chickenkiller.com)

├── Grafana      (kailashgrafana.chickenkiller.com)

└── Langfuse     (kailashlangfuse.chickenkiller.com)
LiteLLM → Redis          (Response Caching)

LiteLLM → Langfuse       (LLM Traces)

LiteLLM → Prometheus     (Metrics)

Prometheus → Grafana     (Dashboards)

Alertmanager → Zoho Mail (Incident Alerts)

## Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| LLM Gateway | LiteLLM | Multi-model routing, caching, tracing |
| Orchestration | AWS EKS (Kubernetes) | Container orchestration |
| Caching | Redis | API response caching |
| Metrics | Prometheus + Grafana | Infrastructure monitoring |
| LLM Observability | Langfuse v2 | Request traces, token usage, cost |
| Ingress | Nginx Ingress Controller | Traffic routing + SSL termination |
| SSL | cert-manager + Let's Encrypt | Automatic HTTPS |
| Alerts | Alertmanager + Zoho Mail | Incident notifications |

## Models Configured

| Model Name | Provider | Underlying Model |
|-----------|----------|-----------------|
| gemini-pro | Google Gemini | gemini-2.5-flash |
| groq-llama | Groq | llama-3.1-8b-instant |
| groq-70b | Groq | llama-3.3-70b-versatile |
| openrouter-model | OpenRouter | Free tier |
| github-gpt4 | GitHub Models | gpt-4o |

## Cluster Details

| Detail | Value |
|--------|-------|
| Cluster | kailash-k8s |
| Region | ap-south-1 (Mumbai) |
| Nodes | 3x t3.small |
| Nodegroup | kailash-nodes-3 |

## Setup

### Prerequisites
- AWS CLI configured
- kubectl, helm, eksctl installed
- EKS cluster running

### 1. Configure kubectl

```bash
aws eks update-kubeconfig --region ap-south-1 --name kailash-k8s
```

### 2. Install Nginx Ingress Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/aws/deploy.yaml
```

### 3. Install cert-manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.yaml
```

### 4. Create Secret and ConfigMap

```bash
kubectl create secret generic litellm-secret --from-env-file=.env
kubectl create configmap litellm-config --from-file=config.yaml
```

### 5. Deploy Redis

```bash
kubectl create deployment redis --image=redis:alpine
kubectl expose deployment redis --port=6379 --type=ClusterIP
```

### 6. Deploy LiteLLM

```bash
kubectl apply -f eks/litellm-deployment.yaml
kubectl apply -f eks/litellm-service.yaml
kubectl apply -f eks/litellm-ingress.yaml
```

### 7. Deploy Monitoring Stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
kubectl apply -f eks/grafana-ingress.yaml
```

### 8. Deploy Langfuse

```bash
kubectl create namespace langfuse

kubectl create secret generic langfuse-secret \
  --namespace langfuse \
  --from-literal=DATABASE_URL='your-supabase-url' \
  --from-literal=NEXTAUTH_SECRET='your-secret' \
  --from-literal=SALT='your-salt' \
  --from-literal=ENCRYPTION_KEY='your-key' \
  --from-literal=NEXTAUTH_URL='https://kailashlangfuse.chickenkiller.com' \
  --from-literal=REDIS_HOST='langfuse-redis' \
  --from-literal=REDIS_PORT='6379'

kubectl apply -f eks/langfuse-deployment.yaml
kubectl apply -f eks/langfuse-service.yaml
kubectl apply -f eks/langfuse-ingress.yaml
```

## Live URLs

| Service | URL |
|---------|-----|
| LiteLLM API | https://kailashtech.chickenkiller.com |
| Grafana Dashboard | https://kailashgrafana.chickenkiller.com |
| Langfuse Traces | https://kailashlangfuse.chickenkiller.com |

## Quick Commands

```bash
# Cluster status
kubectl get pods -A
kubectl get nodes
kubectl top nodes

# LiteLLM
kubectl logs -l app=litellm
kubectl rollout restart deployment litellm

# Grafana password reset
helm upgrade monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword="NewPassword" \
  --reuse-values
```
