#!/bin/bash
echo "========================================="
echo "   Deploying Cloud Infrastructure FYP   "
echo "========================================="

# Update kubeconfig
echo "Step 1: Updating kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name razan-fyp-cluster

# Deploy Flask app
echo "Step 2: Deploying Flask app..."
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/hpa.yaml
kubectl apply -f kubernetes/servicemonitor.yaml

# Install Chaos Mesh
echo "Step 3: Installing Chaos Mesh..."
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update
helm install chaos-mesh chaos-mesh/chaos-mesh \
  --namespace chaos-mesh \
  --create-namespace \
  --set chaosDaemon.runtime=containerd \
  --set chaosDaemon.socketPath=/run/containerd/containerd.sock

echo "========================================="
echo "Deployment Complete!"
echo "========================================="
kubectl get pods -A
