#!/bin/bash
echo "Opening all dashboards..."

# Port forward all dashboards in background
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090 &
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 &
kubectl port-forward svc/monitoring-kube-prometheus-alertmanager -n monitoring 9093:9093 &

echo "========================================="
echo "Dashboards available at:"
echo "Prometheus:   http://localhost:9090"
echo "Grafana:      http://localhost:3000"
echo "Alertmanager: http://localhost:9093"
echo "Grafana login: admin / prom-operator"
echo "========================================="

