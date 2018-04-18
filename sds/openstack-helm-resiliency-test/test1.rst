==============================
Clone the OpenStack-Helm Repos
==============================

---------------------------------
Once the host has been configured
---------------------------------

should be cloned onto each node
-------------------------------

.. code-block:: shell

   #!/bin/bash
    set -xe

    chown -R ubuntu: /opt
    git clone https://git.openstack.org/openstack/openstack-helm-infra.git /opt/openstack-helm-infra
    git clone https://git.openstack.org/openstack/openstack-helm.git /opt/openstack-helm