local kp =
  (import 'kube-prometheus/main.libsonnet') +
  (import 'kube-prometheus/addons/all-namespaces.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
      prometheus+: {
        namespaces: [],
      },
      grafana+: {
        config+: {
          sections+: {
            server: {
              domain: 'grafana.ssang.io',
              root_url: 'https://grafana.ssang.io',
            },
            auth: {
              disable_login_form: true,
              oauth_auto_login: true,
            },
            'auth.generic_oauth': {
              name: 'Keycloak',
              icon: 'signin',
              enabled: true,
              client_id: (import './secrets.json').grafanaOauthKeycloakOidcClientId,
              client_secret: (import './secrets.json').grafanaOauthKeycloakOidcClientSecret,
              scopes: 'openid profile email',
              empty_scopes: false,
              auth_url: 'https://keycloak.ssang.io/realms/master/protocol/openid-connect/auth',
              token_url: 'https://keycloak.ssang.io/realms/master/protocol/openid-connect/token',
              api_url: 'https://keycloak.ssang.io/realms/master/protocol/openid-connect/userinfo',
              allow_sign_up: true,
              use_pkce: true,
              role_attribute_path: "contains(groups[*], 'grafana-admin') && 'Admin' || 'Viewer'",
            },
          }
        },
      },
    },
    ingress+:: {
      grafana: {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'Ingress',
        metadata: {
          name: $.grafana.service.metadata.name,
          namespace: $.grafana.service.metadata.namespace,
          annotations: {
            'cert-manager.io/cluster-issuer': 'letsencrypt',
            'nginx.ingress.kubernetes.io/ssl-redirect': 'true',
          },
        },
        spec: {
          rules: [{
            host: 'grafana.ssang.io',
            http: {
              paths: [{
                path: '/',
                pathType: 'Prefix',
                backend: {
                  service: {
                    name: $.grafana.service.metadata.name,
                    port: {
                      number: 3000,
                    },
                  },
                },
              }],
            },
          }],
          tls: [{
            hosts: [
              'grafana.ssang.io'
            ],
            secretName: 'grafana-ssang-io-tls-cert'
          }],
        },
      },
    },
  };

{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
}
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
{ 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.filter((function(name) name != 'networkPolicy'), std.objectFields(kp.grafana)) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }