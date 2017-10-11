# Ceph Helm

### Qucikstart

Assuming you have a Kubeadm managed Kubernetes 1.7+ cluster and Helm 2.6 setup, you can get going straight away! [1]

1. Install helm and tiller
(src: https://github.com/ceph/ceph-docker/tree/master/examples/helm)
```
helm init       # or helm init --upgrade
helm serve &
```

2. Run ceph-mon, mgr, etc. 
```
cd ceph-docker/examples/helm
./create-secret-kubeconfig.sh
helm install ./ceph --name ceph --replace --namespace ceph
```

3. Run an OSD chart
- Usage:
```
cd ceph-docker/examples/helm
./helm-ceph-osd.sh <node_label> <osd_device>
```

- Example:
   - bluestore:
   ```
   ./helm-ceph-osd.sh voyager1 sdb
   ```

   - filestore
   ```
   OSD_FILESTORE=1 ./helm-ceph-osd.sh voyager1 sdb
   ```

   - filestore with journal
   ```
   OSD_FILESTORE=1 OSD_JOURNAL=/dev/sdb1 ./helm-ceph-osd.sh voyager1 sdc
   ```

### Namespace Activation

To use Ceph Volumes in a namespace a secret containing the Client Key needs to be present, the bash function below helps create one:

```
ceph_activate_namespace() {
  kube_namespace=$1
  {
  cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "pvc-ceph-client-key"
type: kubernetes.io/rbd
data:
  key: |
    $(kubectl get secret pvc-ceph-conf-combined-storageclass --namespace=ceph -o json | jq -r '.data | .[]')
EOF
  } | kubectl create --namespace ${kube_namespace} -f -
}
```

Once defined you can then activate Ceph for a namespace by running:

```
ceph_activate_namespace default
```

Where `default` is the name of the namespace you wish to use Ceph volumes in.

### Functional testing

Once Ceph deployment has been performed you can functionally test the environment by running the jobs in the tests directory, these will soon be incorporated into a Helm plugin, but for now you can run:

```
kubectl create -R -f tests/ceph
```


#### Notes
[1] You actually need to have the nodes setup to access the cluster network, and `/etc/resolv.conf` setup similar to the following:
```
$ cat /etc/resolv.conf
nameserver 10.96.0.10		# K8s DNS IP
nameserver 135.207.240.13	# External DNS IP
nameserver 135.207.240.14
search ceph.svc.cluster.local svc.cluster.local cluster.local client.research.att.com research.att.com
```
