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
      // grafana+: {
      //   config+: (import './grafana-config.jsonnet')
      // },
      // alertmanager+: {
      //   config+: {
      //     receivers: [{
      //       name: 'Critical',
      //       email_configs: [(import './alertmanager-email-config.jsonnet')],
      //     }, {
      //       name: 'Default',
      //     }, {
      //       name: 'Watchdog',
      //     }, {
      //       name: 'null',
      //     },],
      //   },
      // },
    },
  };

{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
}
// { 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
// { 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
// { 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } + 
// { ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
// { ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) } +
// { ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
// { ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
// { ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) }