# Prometheus in Containers

### Ceph exporter
Ref: <http://docs.ceph.com/docs/master/mgr/prometheus>
- The prometheus module is enabled with:
```
ceph mgr module enable prometheus
```
By default the module will accept HTTP requests on port 9283.


### Promethues helm chart
- Download
```
git clone https://github.com/kubernetes/charts.git
```

- Configure `charts/stable/prometheus/values.yaml`
```
alertmanager:
  ## If false, alertmanager will not be installed
  ##
  enabled: false

kubeStateMetrics:
  ## If false, kube-state-metrics will not be installed
  ##
  enabled: false

nodeExporter:
  ## If false, node-exporter will not be installed
  ##
  enabled: false

server:
  persistentVolume:
    ## If true, Prometheus server will create/use a Persistent Volume Claim
    ## If false, use emptyDir
    ##
    enabled: false

  service:
    type: NodePort 

## Prometheus server ConfigMap entries
##
serverFiles:
  prometheus.yml:
    scrape_configs:
      - job_name: prometheus
        static_configs:
          - targets:
            - 10.22.1.102:9283
```

- Run
```
helm delete --purge my-prometheus
helm install --name my-prometheus charts/stable/prometheus --namespace ceph

# To check
kubectl exec -it -n ceph --container prometheus-server my-prometheus-prometheus-server-9bd889998-v2gjj -- /bin/sh
```

- Access
```
# Find port
$ kubectl get svc -n ceph
NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
my-prometheus-prometheus-server   NodePort    10.103.24.186   <none>        80:30241/TCP   20m

# Find IP address of AWS
$ kubectl get pods -n ceph -o wide
NAME                                              READY     STATUS    RESTARTS   AGE       IP               NODE
my-prometheus-prometheus-server-9bd889998-v2gjj   2/2       Running   2          22h       192.168.85.70    ip-10-22-1-103
```

Using ip-10-22-1-103, go to AWS console and find IPv4 Public IP.

Now you can browse at 54.210.122.185:30241.


