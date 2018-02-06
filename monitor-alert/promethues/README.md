# Prometheus

### Ceph exporter
Ref: <http://docs.ceph.com/docs/master/mgr/prometheus>
- The prometheus module is enabled with:
```
ceph mgr module enable prometheus
```
By default the module will accept HTTP requests on port 9283


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
# Find access IP and port
kubectl get svc -n ceph
NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
ceph-exporter                     ClusterIP   None            <none>        9128/TCP       3h
ceph-mon                          ClusterIP   None            <none>        6789/TCP       3h
my-prometheus-prometheus-server   NodePort    10.103.24.186   <none>        80:30241/TCP   20m
```
Now you can browse at 10.103.24.186:30241.


