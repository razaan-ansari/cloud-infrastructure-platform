resource "helm_release" "prometheus" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true


  values = [
  <<-EOF
  alertmanager:
    config:
      global:
        smtp_smarthost: 'smtp.gmail.com:587'
        smtp_from: 'razaan330@gmail.com'
        smtp_auth_username: 'razaan330@gmail.com'
        smtp_auth_password: 'YOUR_APP_PASSWORD'
      route:
        receiver: 'gmail-notifications'
        routes:
        - receiver: 'null'
          matchers:
          - alertname = "InfoInhibitor"
      receivers:
      - name: 'null'
      - name: 'gmail-notifications'
        email_configs:
        - to: 'razaan330@gmail.com'
          send_resolved: true
  EOF
]
}
  