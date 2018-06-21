======================
Miscellaneous Failures
======================

Test Environment:

- Cluster size: 4 host machines
- Kubernetes 1.9.3
- Ceph 12.2.3
- OpenStack-Helm commit 28734352741bae228a4ea4f40bcacc33764221eb

Case: Fail to Attach a RBD volume to a Pod
==========================================

Symptom: "Unable to mount volumes for pod"
------------------------------------------
Prepare ``pvc-sample.yaml`` and ``deploy-sample.yaml`` for creating an RBD volume and attach it to a pod.

.. code-block::

  $ cat pvc-sample.yaml
  ---
  kind: PersistentVolumeClaim
  apiVersion: v1
  metadata:
    name: pvc-sample
    annotations:
      volume.beta.kubernetes.io/storage-class: general
  spec:
    accessModes: [ "ReadWriteOnce" ]
    resources:
      requests:
        storage: 20G

.. code-block::

  $ cat deploy-sample.yaml
  apiVersion: extensions/v1beta1
  kind: Deployment
  metadata:
    name: deploy-sample
  spec:
    replicas: 1
    template:
      metadata:
        labels:
          app: deploy-sample
        namespace: default
      spec:
        #hostNetwork: true 
        #dnsPolicy: ClusterFirstWithHostNet
        containers:
          - name: deploy-sample
            image: docker.io/knowpd/ceph:kubectl-ubuntu-16.04
            imagePullPolicy: Always
            args:
              - /bin/bash
            stdin: true
            tty: true
            volumeMounts:
              - name: vol-sample
                mountPath: /mnt/myvol
        volumes:
          - name: vol-sample
            persistentVolumeClaim:
              claimName: pvc-sample

 
.. code-block::

  $ kubectl create -f pvc-sample.yaml -n openstack
  persistentvolumeclaim "pvc-sample" created
  $ kubectl get pvc -n openstack
  NAME                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
  mysql-data-mariadb-0   Bound     pvc-026f8614-3f4b-11e8-8a90-d4ae52a3acc1   5Gi        RWO            general        29m
  mysql-data-mariadb-1   Bound     pvc-02708ba4-3f4b-11e8-8a90-d4ae52a3acc1   5Gi        RWO            general        29m
  mysql-data-mariadb-2   Bound     pvc-02717a39-3f4b-11e8-8a90-d4ae52a3acc1   5Gi        RWO            general        29m
  pvc-sample             Bound     pvc-1b299ed4-3f4f-11e8-8a90-d4ae52a3acc1   20Gi       RWO            general        9s

.. code-block::
  
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

Solution:
---------

Check ``Ceph Heath`` from monitor pod:

.. code-block::

  $ kshell ceph-mon-8tml7 -n ceph
  (mon-pod):/# ceph -s
                cluster:
                  id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
                  health: HEALTH_WARN
                          too few PGs per OSD (22 < min 30)
                          mon voyager1 is low on available space
  
Checked that ``pg_num`` and ``pgp_num`` is 64 set for pool rbd. We have 24 OSDs which requires 24*100/3=800 placement groups.

.. code-block:: 

  Set pg_num and pgp_num to 800: 
  (mon-pod):/# ceph osd pool set rbd pg_num 800
  (mon-pod):/# ceph osd pool set rbd pgp_num 800
  (mon-pod):/# ceph -s
                cluster:
                  id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
                  health: HEALTH_WARN
                          mon voyager1 is low on available space

Exit monitor pod, clean up and re-create the deployment for creating rbd volume and attach:

.. code-block:: 

  $ kubectl delete deploy deploy-sample -n openstack
  $ kubectl delete -f pvc-sample.yaml -n openstack
  $ kubectl create -f pvc-sample.yaml -n openstack
  $ kubectl create -f deploy-sample.yaml -n openstack
  $ kubectl get pods -n openstack
  NAME                             READY     STATUS    RESTARTS   AGE
  deploy-sample-67589b7c8d-sp9vv   1/1       Running   0          34s
  mariadb-0                        1/1       Running   0          41m
  mariadb-1                        1/1       Running   0          41m
  mariadb-2                        1/1       Running   0          41m


Case: Inconsistent placement group 
==================================

Symptom: "Possible data damage: 1 pg inconsistent"
--------------------------------------------------

You might encounter inconsistent placement group due to data damage.

.. code-block:: 

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_ERR
              1 scrub errors
              Possible data damage: 1 pg inconsistent
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in
   
    data:
      pools:   18 pools, 918 pgs
      objects: 318 objects, 978 MB
      usage:   5625 MB used, 44672 GB / 44678 GB avail
      pgs:     917 active+clean
               1   active+clean+inconsistent

Solution:
---------

Find and reapir the inconsistent placement group:

.. code-block:: 

  (mon-pod):/# ceph pg dump | grep inconsistent
  dumped all
  1.242         1                  0        0         0       0    49152 382      382 active+clean+inconsistent 2018-04-25 19:27:25.220388 121'382  184:681  [11,13,4]         11  [11,13,4]             11    121'382 2018-04-24 20:35:47.946821         121'382 2018-04-21 04:14:57.104920             0 

.. code-block:: 

  (mon-pod):/# ceph pg repair 1.242
  instructing pg 1.242 on osd.11 to repair

.. code-block:: 

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in
   
    data:
      pools:   18 pools, 918 pgs
      objects: 318 objects, 978 MB
      usage:   5625 MB used, 44672 GB / 44678 GB avail
      pgs:     918 active+clean
