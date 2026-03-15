#!/bin/bash
echo "========================================="
echo "         Chaos Engineering Tests         "
echo "========================================="

echo "Select experiment:"
echo "1. CPU Stress Test"
echo "2. Network Delay Test"
echo "3. Self Healing Test"
echo "4. Run All"
echo "5. Stop All Experiments"
read -p "Enter choice (1-5): " choice

case $choice in
  1)
    echo "Running CPU Stress Test..."
    kubectl delete stresschaos cpu-stress -n chaos-mesh 2>/dev/null
    kubectl apply -f kubernetes/stress-chaos.yaml
    echo "CPU stress test started! Watch pods:"
    kubectl get pods -n default -w
    ;;
  2)
    echo "Running Network Delay Test..."
    kubectl delete networkchaos network-delay -n chaos-mesh 2>/dev/null
    kubectl apply -f kubernetes/network-chaos.yaml
    echo "Network delay test started!"
    ;;
  3)
    echo "Running Self Healing Test..."
    POD=$(kubectl get pods -n default -o jsonpath='{.items[0].metadata.name}')
    echo "Deleting pod: $POD"
    kubectl delete pod $POD -n default
    echo "Watching recovery..."
    kubectl get pods -n default -w
    ;;
  4)
    echo "Running all experiments..."
    kubectl apply -f kubernetes/stress-chaos.yaml
    kubectl apply -f kubernetes/network-chaos.yaml
    echo "All experiments running!"
    ;;
  5)
    echo "Stopping all experiments..."
    kubectl delete stresschaos --all -n chaos-mesh
    kubectl delete networkchaos --all -n chaos-mesh
    echo "All experiments stopped!"
    ;;
  *)
    echo "Invalid choice!"
    ;;
esac

