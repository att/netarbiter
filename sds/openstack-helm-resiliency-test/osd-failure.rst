===========
OSD Failure
===========

We have 24 OSDs, 6 OSDs on each of the 4 nodes.
6 OSDs down on voyager1 : 30 secs before they are up again.

.. code-block::

$ kshell ceph-osd-default-64779b8c-jdrj4 -n ceph
(osd-pod):/# ps -ef|grep /usr/bin/ceph-osd
ceph     44587 43680  1 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb5 -f -i 4 --setuser ceph --setgroup disk
ceph     44627 43744  1 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb2 -f -i 6 --setuser ceph --setgroup disk
ceph     44720 43927  2 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb6 -f -i 3 --setuser ceph --setgroup disk
ceph     44735 43868  1 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb1 -f -i 9 --setuser ceph --setgroup disk
ceph     44806 43855  1 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb4 -f -i 0 --setuser ceph --setgroup disk
ceph     44896 44011  2 18:12 ?        00:00:01 /usr/bin/ceph-osd --cluster ceph --osd-journal /dev/sdb3 -f -i 1 --setuser ceph --setgroup disk
root     46144 45998  0 18:13 pts/10   00:00:00 grep --color=auto /usr/bin/ceph-osd
(osd-pod):/# kill -9 44587 44627 44720 44735 44806 44896 


