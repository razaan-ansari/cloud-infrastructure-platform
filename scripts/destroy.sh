#!/bin/bash
echo "========================================="
echo "      Destroying Infrastructure          "
echo "========================================="

# Delete flask service first (removes ELB)
echo "Step 1: Removing Load Balancer..."
kubectl delete svc flask-service -n default 2>/dev/null

# Delete chaos experiments
echo "Step 2: Cleaning up chaos experiments..."
kubectl delete stresschaos --all -n chaos-mesh 2>/dev/null
kubectl delete networkchaos --all -n chaos-mesh 2>/dev/null

# Wait for ELB to be removed
echo "Waiting 30 seconds for ELB cleanup..."
sleep 30

# Terraform destroy
echo "Step 3: Destroying Terraform infrastructure..."
cd terraform/
terraform destroy -auto-approve

echo "========================================="
echo "Infrastructure destroyed!"
echo "No more AWS charges!"
echo "========================================="

