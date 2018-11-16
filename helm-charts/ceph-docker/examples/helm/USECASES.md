# Use Cases  
Authors: Hee Won Lee <knowpd@research.att.com>  
Created on 11/3/2017

### Fio testing
We assume that you created a ceph pool `rbd` with a proper `pg_num`, which is depending on your number of OSDs.    
To choose the value of `pg_num`, refer to <http://docs.ceph.com/docs/master/rados/operations/placement-groups>.
```
# Create a pvc
kubectl create -f samples/pvc-sample.yaml 

# Create a pod with the pvc attached
kubectl create -f samples/deploy-sample.yaml
```
Now you can find a pod with a mounted volume as follows:
```
# To find your pod (e.g, deploy-sample-6d7679d6c9-942zq)
kubectl get pods

# To check a new volume `rbd0` and a newly-mounted directory `myvol`
kubectl exec -it <pod> -- lsblk
kubectl exec -it <pod> -- ls /mnt
```
After fio testing, you can delete the pod and pvc as follows:
```
kubectl delete -f samples/deploy-sample.yaml -f samples/pvc-sample.yaml
```
