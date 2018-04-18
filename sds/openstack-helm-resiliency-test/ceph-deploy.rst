==========
Resiliency
==========

==
HI
==

Case 1: Fail To Create Deployment (Create RBD Volume and Attach)
================================================================

Prior Steps: Create the Persistent Volume Claim
-----------------------------------------------

hi

.. code-block:: shell
  
  ...
  $ kubectl create -f pvc-sample.yaml -n openstack
  persistentvolumeclaim "pvc-sample" created
  $ kubectl get pvc -n openstack
  NAME                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
  mysql-data-mariadb-0   Bound     pvc-026f8614-3f4b-11e8-8a90-d4ae52a3acc1   5Gi        RWO            general        29m
  mysql-data-mariadb-1   Bound     pvc-02708ba4-3f4b-11e8-8a90-d4ae52a3acc1   5Gi        RWO            general        29m
  mysql-data-mariadb-2   Bound     pvc-02717a39-3f4b-11e8-8a90-d4ae52a3acc1   5Gi        RWO            general        29m
  pvc-sample             Bound     pvc-1b299ed4-3f4f-11e8-8a90-d4ae52a3acc1   20Gi       RWO            general        9s

Symptom: When creating RBD Volume and Attach
--------------------------------------------

hi

.. code-block:: shell
  
  $ kubectl create -f deploy-sample.yaml -n openstack
  deployment "deploy-sample" created
  $ kubectl get pods -n openstack
  NAME                             READY     STATUS              RESTARTS   AGE
  deploy-sample-67589b7c8d-qfwzb   0/1       ContainerCreating   0          13s
  mariadb-0                        1/1       Running             0          30m
  mariadb-1                        1/1       Running             0          30m
  mariadb-2                        1/1       Running             0          30m
  $ kubectl describe pod deploy-sample-67589b7c8d-qfwzb -n openstack
  Name:           deploy-sample-67589b7c8d-qfwzb
  Namespace:      openstack
  Node:           voyager3/135.207.240.43
  Start Time:     Fri, 13 Apr 2018 15:17:06 -0400
  Labels:         app=deploy-sample
                  pod-template-hash=2314563748
  Annotations:    <none>
  Status:         Pending
  IP:             
  Controlled By:  ReplicaSet/deploy-sample-67589b7c8d
  Containers:
    deploy-sample:
      Container ID:  
      Image:         docker.io/knowpd/ceph:kubectl-ubuntu-16.04
      Image ID:      
      Port:          <none>
      Args:
        /bin/bash
      State:          Waiting
        Reason:       ContainerCreating
      Ready:          False
      Restart Count:  0
      Environment:    <none>
      Mounts:
        /mnt/myvol from vol-sample (rw)
        /var/run/secrets/kubernetes.io/serviceaccount from default-token-2xnhf (ro)
  Conditions:
    Type           Status
    Initialized    True 
    Ready          False 
    PodScheduled   True 
  Volumes:
    vol-sample:
      Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
      ClaimName:  pvc-sample
      ReadOnly:   false
    default-token-2xnhf:
      Type:        Secret (a volume populated by a Secret)
      SecretName:  default-token-2xnhf
      Optional:    false
  QoS Class:       BestEffort
  Node-Selectors:  <none>
  Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                   node.kubernetes.io/unreachable:NoExecute for 300s
  Events:
    Type     Reason                 Age   From               Message
    ----     ------                 ----  ----               -------
    Normal   Scheduled              2m    default-scheduler  Successfully assigned deploy-sample-67589b7c8d-qfwzb to voyager3
    Normal   SuccessfulMountVolume  2m    kubelet, voyager3  MountVolume.SetUp succeeded for volume "default-token-2xnhf"
    Warning  FailedMount            43s   kubelet, voyager3  Unable to mount volumes for pod "deploy-sample-67589b7c8d-qfwzb_openstack(410a2feb-3f4f-11e8-8a90-d4ae52a3acc1)": timeout expired waiting for volumes to attach/mount for pod "openstack"/"deploy-sample-67589b7c8d-qfwzb". list of unattached/unmounted volumes=[vol-sample]

Solution
--------

Check ``Ceph Heath`` from monitor pod:

.. code-block:: shell

  $ kshell ceph-mon-8tml7 -n ceph
  root@voyager3:/# ceph -s
                cluster:
                  id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
                  health: HEALTH_WARN
                          too few PGs per OSD (22 < min 30)
                          mon voyager1 is low on available space
  
Checked that ``pg_num`` and ``pgp_num`` is 64 set for pool rbd. We have 24 OSDs which requires 24*100/3=800 placement groups.

.. code-block:: shell

  Set pg_num and pgp_num to 800: 
  root@voyager3:/# ceph osd pool set rbd pg_num 800
  root@voyager3:/# ceph osd pool set rbd pgp_num 800
  root@voyager3:/# ceph -s
                cluster:
                  id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
                  health: HEALTH_WARN
                          mon voyager1 is low on available space

Exit monitor pod, clean up and re-create the deployment for creating rbd volume and attach:

.. code-block:: shell

  $ kubectl delete deploy deploy-sample -n openstack
  $ kubectl delete -f pvc-sample.yaml -n openstack
  $ kubectl create -f pvc-sample.yaml -n openstack
  $ kubectl create -f deploy-sample.yaml -n openstack
  $  kubectl get pods -n openstack
  NAME                             READY     STATUS    RESTARTS   AGE
  deploy-sample-67589b7c8d-sp9vv   1/1       Running   0          34s
  mariadb-0                        1/1       Running   0          41m
  mariadb-1                        1/1       Running   0          41m
  mariadb-2                        1/1       Running   0          41m
