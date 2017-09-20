# README test

Trouble-shoot
=============
1. Fails to join a node
   - Symptom
   ```
   $ sudo kubeadm join --token 461371.ebfd9fbf7569cfa9 135.207.240.41:6443
   ...
   [discovery] Failed to connect to API Server "135.207.240.41:6443": there is no JWS signed token in the cluster-info ConfigMap. This token id "461371" is invalid for this cluster, can't connect
   ```
   - Solution: Find a corrent token by:
   ```
   sudo kubeadm token list
   ```
