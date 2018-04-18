Clone the OpenStack-Helm Repos
------------------------------

Once the host has been configured the repos containing the OpenStack-Helm charts
should be cloned onto each node in the cluster:

.. code-block:: shell
   #!/bin/bash
    set -xe

    chown -R ubuntu: /opt
    git clone https://git.openstack.org/openstack/openstack-helm-infra.git /opt/openstack-helm-infra
    git clone https://git.openstack.org/openstack/openstack-helm.git /opt/openstack-helm