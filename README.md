# Cloud Infrastructure & Monitoring Platform

This repository contains my Final Year Project (FYP) for my Computer Science degree at INTI International University.

The project simulates an enterprise cloud environment using:
- AWS (EC2, VPC, IAM, Security Groups)
- Terraform (Infrastructure as Code)
- Docker & Kubernetes
- Prometheus, Grafana, Alertmanager
- CI/CD pipelines
- Python & Bash automation

The goal is to design, deploy, and operate a secure, scalable, and monitored cloud infrastructure similar to real-world enterprise production environments.

This project is actively being developed and improved.
# Cloud-Native Application Resilience Testing using Chaos Engineering on AWS EKS

![AWS](https://img.shields.io/badge/AWS-EKS-orange)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)
![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-blue)
![Chaos](https://img.shields.io/badge/Chaos-Mesh-red)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-orange)
![Grafana](https://img.shields.io/badge/Visualization-Grafana-yellow)
![Docker](https://img.shields.io/badge/Container-Docker-blue)
![Python](https://img.shields.io/badge/App-Python-green)

## Overview
This project demonstrates cloud-native application resilience testing using Chaos Engineering principles on AWS Elastic Kubernetes Service (EKS). The system intentionally injects failures into a running application to validate its ability to withstand and recover from real-world disruptions similar to Netflix's Chaos Monkey approach.

## Architecture
```
                         ┌─────────────┐
                         │   Internet  │
                         └──────┬──────┘
                                │
                         ┌──────▼──────┐
                         │     ELB     │
                         │ LoadBalancer│
                         └──────┬──────┘
                                │
              ┌─────────────────▼──────────────────┐
              │           AWS EKS Cluster          │
              │                                    │
              │  ┌──────────┐   ┌───────────────┐  │
              │  │ Flask App│   │  Chaos Mesh   │  │
              │  │ Pod x3   │◄──│  CPU Stress   │  │
              │  │  (HPA)   │   │  Net Delay    │  │
              │  └────┬─────┘   └───────────────┘  │
              │       │                            │
              │  ┌────▼─────┐   ┌───────────────┐  │
              │  │Prometheus│   │    Grafana    │  │
              │  │ Scrapes  │──►│   Dashboard   │  │
              │  │ /metrics │   └───────────────┘  │
              │  └────┬─────┘                      │
              │  ┌────▼───────┐  ┌──────────────┐  │
              │  │Alertmanager│  │     HPA      │  │
              │  └────┬───────┘  │ Auto Scaling │  │
              │       │          └──────────────┘  │
              └───────┼────────────────────────────┘
                      │
               ┌──────▼─────┐
               │    Gmail   │
               │    Alert   │
               └────────────┘
```

## Technologies Used
| Technology | Version | Purpose |
|---|---|---|
| AWS EKS | 1.33 | Managed Kubernetes cluster |
| Terraform | >= 1.0 | Infrastructure as Code |
| Docker | Latest | Application containerization |
| Flask | 2.x | Python web application |
| prometheus-client | Latest | Flask metrics endpoint |
| Chaos Mesh | Latest | Chaos engineering platform |
| Prometheus | Latest | Metrics collection |
| Grafana | Latest | Metrics visualization |
| Alertmanager | v0.31.1 | Alert routing and email notification |
| Kubernetes HPA | v2 | Horizontal Pod Autoscaler |

## Project Structure
```
cloud-infrastructure-platform/
├── app/
│   ├── app.py                  # Flask app with /metrics endpoint
│   ├── Dockerfile              # Non-root container (fypuser)
│   └── requirements.txt        # flask, prometheus-client
├── terraform/
│   ├── provider.tf             # AWS, Kubernetes, Helm providers
│   ├── vpc.tf                  # VPC, subnets, IGW, route tables
│   ├── eks.tf                  # EKS cluster (v1.29)
│   ├── nodes.tf                # Node group (t3.medium x2)
│   ├── iam.tf                  # IAM roles and policies
│   ├── rbac.tf                 # Kubernetes RBAC for Chaos Mesh
│   └── monitoring.tf           # kube-prometheus-stack Helm release
├── kubernetes/
│   ├── deployment.yaml         # Flask deployment (3 replicas)
│   ├── service.yaml            # LoadBalancer service
│   ├── hpa.yaml                # HPA (min:2, max:5, cpu:50%)
│   ├── servicemonitor.yaml     # Prometheus scraping config
│   ├── stress-chaos.yaml       # CPU stress chaos experiment
│   ├── network-chaos.yaml      # Network delay chaos experiment
│   └── cpu-throttle-alert.yaml # PrometheusRule for alerting
└── scripts/                    # Utility scripts
```

## Chaos Experiments

### Experiment 1 — CPU Stress Test
```yaml
mode: one
cpu:
  workers: 2
  load: 90
duration: 5m
```
**Tests:**
- CPU throttling detection by Prometheus
- HPA auto scaling from 3 to 5 pods
- FlaskCPUThrottlingHigh alert firing
- Email notification via Gmail SMTP


### Experiment 2 — Self Healing
```bash
kubectl delete pod <pod-name> -n default
```
**Tests:**
- Kubernetes automatic pod recovery
- Mean Time To Recovery (MTTR)
- Desired replica count maintenance

## Results Summary
| Experiment | Expected Outcome | Actual Outcome | Result |
|---|---|---|---|
| CPU Stress | CPU throttling detected | Alert fired in <2 mins | ✅ Pass |
| HPA Scaling | Pods scale under load | Scaled 3→5 automatically | ✅ Pass |
| Email Alert | Email notification received | Gmail alert received | ✅ Pass |
| Self Healing | Pod restarts automatically | MTTR ~12 seconds | ✅ Pass |
| Network Chaos | Latency injected | 200ms delay applied | ✅ Pass |

## Key Findings
- Kubernetes HPA successfully scaled pods from 3 to 5 under CPU stress
- CPU throttling detected and alerted within 2 minutes of chaos injection
- Self-healing MTTR of ~12 seconds demonstrates strong fault tolerance
- Complete observability pipeline validated from metrics to email notification
- KubeControllerManagerDown alert is expected behaviour in AWS EKS managed control plane
- Chaos Mesh requires containerd runtime configuration on EKS 1.24+

## Prerequisites
```bash
AWS CLI >= 2.0
Terraform >= 1.0
kubectl
Helm >= 3.0
Docker
```

> The following are installed automatically via Helm:
> Prometheus, Grafana, Alertmanager, Chaos Mesh

## Deployment Guide

### 1. Configure AWS Credentials
```bash
aws configure
```

### 2. Deploy Infrastructure
```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

### 3. Update kubeconfig
```bash
aws eks update-kubeconfig --region us-east-1 --name razan-fyp-cluster
```

### 4. Verify Cluster
```bash
kubectl get nodes
kubectl get pods -A
```

### 5. Deploy Flask Application
```bash
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/hpa.yaml
kubectl apply -f kubernetes/servicemonitor.yaml
```

### 6. Install Chaos Mesh
```bash
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm install chaos-mesh chaos-mesh/chaos-mesh \
  --namespace chaos-mesh \
  --create-namespace \
  --set chaosDaemon.runtime=containerd \
  --set chaosDaemon.socketPath=/run/containerd/containerd.sock
```

### 7. Run Chaos Experiments
```bash
# CPU Stress Test
kubectl apply -f kubernetes/stress-chaos.yaml

# Network Delay Test
kubectl apply -f kubernetes/network-chaos.yaml

# Self Healing Test
kubectl delete pod <pod-name> -n default
```

### 8. Access Dashboards
```bash
# Prometheus
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
# Open http://localhost:9090

# Grafana (login: admin / prom-operator)
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
# Open http://localhost:3000

# Alertmanager
kubectl port-forward svc/monitoring-kube-prometheus-alertmanager -n monitoring 9093:9093
# Open http://localhost:9093
```

### 9. Destroy Infrastructure
```bash
terraform destroy
```

## Security Considerations
- Non-root container user (fypuser) following Principle of Least Privilege
- Kubernetes secrets used for sensitive credentials
- IAM roles configured with minimum required permissions
- Gmail App Password used instead of account password

## Challenges and Solutions
| Challenge | Solution |
|---|---|
| Docker vs containerd mismatch on EKS 1.24+ | Set chaosDaemon.runtime=containerd in Helm |
| Stale kubeconfig after terraform destroy | Run aws eks update-kubeconfig after apply |
| ELB blocking terraform destroy | Delete flask-service before terraform destroy |
| Alertmanager null receiver error | Added null receiver to alertmanager config |
| Namespace stuck in Terminating | Force removed finalizers using kubectl patch |

## Author
**Razan** | Cloud Computing | INTI International University

> *"Breaking things on purpose to prove they don't break"*
