Troubleshoot
============
Contributors:
  - Hee Won Lee <knowpd@research.att.com>

## Problem: [Swift Authentication]  
- Problem Description  
How to find `token` and `storage_url` for `<storage type="swift" config="token=...;storage_url=..." />`.

- Solution  
You can find endpoint url (i.e., `http://controller:8080/v1/AUTH_2bccc882410f47f2b6e443ff6652d412`) by
```
$ swift --os-auth-url http://voyager5:5000/v3 --auth-version 3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name admin --os-username admin --os-password admin123 list --debug
DEBUG:keystoneclient.auth.identity.v3.base:Making authentication request to http://voyager5:5000/v3/auth/tokens
DEBUG:urllib3.connectionpool:Starting new HTTP connection (1): voyager5
DEBUG:urllib3.connectionpool:http://voyager5:5000 "POST /v3/auth/tokens HTTP/1.1" 201 1730
DEBUG:keystoneclient.auth.identity.v3.base:{"token": {"is_domain": false, "methods": ["password"], "roles": [{"id": "8a364aa88cfd41dd80d6af1ab2158937", "name": "admin"}], "expires_at": "2018-03-09T22:25:35.000000Z", "project": {"domain"
: {"id": "default", "name": "Default"}, "id": "2bccc882410f47f2b6e443ff6652d412", "name": "admin"}, "catalog": [{"endpoints": [{"url": "http://controller:8080/v1/AUTH_2bccc882410f47f2b6e443ff6652d412", "interface": "public", "region": "
RegionOne", "region_id": "RegionOne", "id": "8f518f85248e4a26a9afbd1880f7bd41"}, {"url": "http://controller:8080/v1", "interface": "admin", "region": "RegionOne", "region_id": "RegionOne", "id": "c597dd05de2e496ab660ca31f7fff18b"}, {"ur
l": "http://controller:8080/v1/AUTH_2bccc882410f47f2b6e443ff6652d412", "interface": "internal", "region": "RegionOne", "region_id": "RegionOne", "id": "ee45941d59a94981b736276d9bd263ff"}], "type": "object-store", "id": "68249e52079f46f1
82a1e32d042e2a52", "name": "swift"}, {"endpoints": [{"url": "http://controller:5000/v3/", "interface": "internal", "region": "RegionOne", "region_id": "RegionOne", "id": "a0a869b27f3b4f3fba0b8ffffc566805"}, {"url": "http://controller:35
357/v3/", "interface": "admin", "region": "RegionOne", "region_id": "RegionOne", "id": "be5a56e018224f0eab606dc6721ad7ff"}, {"url": "http://controller:5000/v3/", "interface": "public", "region": "RegionOne", "region_id": "RegionOne", "i
d": "fe5bfb83bc8b454990422cd20375a8e6"}], "type": "identity", "id": "80ade41679224b0fae26bee027e4f152", "name": "keystone"}], "user": {"domain": {"id": "default", "name": "Default"}, "password_expires_at": null, "name": "admin", "id": "
1b59bfc213e8496b84e5581950eb03c4"}, "audit_ids": ["lgtmWxmoT-q7JVsM_el2HA"], "issued_at": "2018-03-09T21:25:35.000000Z"}}
DEBUG:urllib3.connectionpool:Starting new HTTP connection (1): controller
DEBUG:urllib3.connectionpool:http://controller:8080 "GET /v1/AUTH_2bccc882410f47f2b6e443ff6652d412?format=json HTTP/1.1" 200 288
DEBUG:swiftclient:REQ: curl -i http://controller:8080/v1/AUTH_2bccc882410f47f2b6e443ff6652d412?format=json -X GET -H "Accept-Encoding: gzip" -H "X-Auth-Token: gAAAAABaovvP-D1i0LrPzxkPduFNqi7MKiVvwJEpjXpe2par3VeFKVWufHVqVb-do91X6r63u4ZKk
J_0NiVB0SaDyyQddz6uglprq9P6kNJYJ5eW6ac8lhqLcXSXPZPf4nMrNxn1AAJaoMT_Xbii74THBj8q3cqb-jZS7NTnCJEbh1aXDM0cZJU"
DEBUG:swiftclient:RESP STATUS: 200 OK
DEBUG:swiftclient:RESP HEADERS: {u'Content-Length': u'288', u'X-Account-Object-Count': u'3', u'x-account-project-domain-id': u'default', u'X-Openstack-Request-Id': u'txabab69eff57e40d1bcd3e-005aa2fbcf', u'X-Account-Storage-Policy-Policy
-0-Bytes-Used': u'76', u'X-Account-Storage-Policy-Policy-0-Container-Count': u'3', u'X-Timestamp': u'1520025972.57070', u'X-Account-Storage-Policy-Policy-0-Object-Count': u'3', u'X-Trans-Id': u'txabab69eff57e40d1bcd3e-005aa2fbcf', u'Dat
e': u'Fri, 09 Mar 2018 21:25:35 GMT', u'X-Account-Bytes-Used': u'76', u'X-Account-Container-Count': u'3', u'Content-Type': u'application/json; charset=utf-8', u'Accept-Ranges': u'bytes'}
DEBUG:swiftclient:RESP BODY: [{"count": 1, "last_modified": "2018-03-02T21:26:12.591940", "bytes": 32, "name": "container1"}, {"count": 1, "last_modified": "2018-03-05T20:25:06.319560", "bytes": 22, "name": "container2"}, {"count": 1, "
last_modified": "2018-03-05T20:30:08.427600", "bytes": 22, "name": "container3"}]
DEBUG:urllib3.connectionpool:http://controller:8080 "GET /v1/AUTH_2bccc882410f47f2b6e443ff6652d412?format=json&marker=container3 HTTP/1.1" 200 2
DEBUG:swiftclient:REQ: curl -i http://controller:8080/v1/AUTH_2bccc882410f47f2b6e443ff6652d412?format=json&marker=container3 -X GET -H "Accept-Encoding: gzip" -H "X-Auth-Token: gAAAAABaovvP-D1i0LrPzxkPduFNqi7MKiVvwJEpjXpe2par3VeFKVWufHV
qVb-do91X6r63u4ZKkJ_0NiVB0SaDyyQddz6uglprq9P6kNJYJ5eW6ac8lhqLcXSXPZPf4nMrNxn1AAJaoMT_Xbii74THBj8q3cqb-jZS7NTnCJEbh1aXDM0cZJU"
DEBUG:swiftclient:RESP STATUS: 200 OK
DEBUG:swiftclient:RESP HEADERS: {u'Content-Length': u'2', u'X-Account-Object-Count': u'3', u'x-account-project-domain-id': u'default', u'X-Openstack-Request-Id': u'txf0fdb5c06f9e4736bbe2f-005aa2fbcf', u'X-Account-Storage-Policy-Policy-0
-Bytes-Used': u'76', u'X-Account-Storage-Policy-Policy-0-Container-Count': u'3', u'X-Timestamp': u'1520025972.57070', u'X-Account-Storage-Policy-Policy-0-Object-Count': u'3', u'X-Trans-Id': u'txf0fdb5c06f9e4736bbe2f-005aa2fbcf', u'Date'
: u'Fri, 09 Mar 2018 21:25:35 GMT', u'X-Account-Bytes-Used': u'76', u'X-Account-Container-Count': u'3', u'Content-Type': u'application/json; charset=utf-8', u'Accept-Ranges': u'bytes'}
DEBUG:swiftclient:RESP BODY: []
container1
container2
container3
```

You can also check the endpoint by:
```
$ openstack endpoint list
+----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------+
| ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                           |
+----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------+
| 8f518f85248e4a26a9afbd1880f7bd41 | RegionOne | swift        | object-store | True    | public    | http://controller:8080/v1/AUTH_%(project_id)s | <-- HERE
| a0a869b27f3b4f3fba0b8ffffc566805 | RegionOne | keystone     | identity     | True    | internal  | http://controller:5000/v3/                    |
| be5a56e018224f0eab606dc6721ad7ff | RegionOne | keystone     | identity     | True    | admin     | http://controller:35357/v3/                   |
| c597dd05de2e496ab660ca31f7fff18b | RegionOne | swift        | object-store | True    | admin     | http://controller:8080/v1                     |
| ee45941d59a94981b736276d9bd263ff | RegionOne | swift        | object-store | True    | internal  | http://controller:8080/v1/AUTH_%(project_id)s |
| fe5bfb83bc8b454990422cd20375a8e6 | RegionOne | keystone     | identity     | True    | public    | http://controller:5000/v3/                    |
+----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------+

$ openstack project list
+----------------------------------+---------+
| ID                               | Name    |
+----------------------------------+---------+
| 2bccc882410f47f2b6e443ff6652d412 | admin   | <--- HERE
| 65ee2e82f27b4a6d9950036963e32f54 | service |
+----------------------------------+---------+
```

You can issue a token by 
```
$ openstack token issue
+------------+---------------------------------------------------+
| Field      | Value                                             |
+------------+---------------------------------------------------+
| expires    | 2018-03-09T22:28:57+0000                          |
| id         | gAAAAABaovyZMxKGDN--jkOFyT1JLQtZLxEXm99...-Yb8Epc | <-- HERE
| project_id | 2bccc882410f47f2b6e443ff6652d412                  |
| user_id    | 1b59bfc213e8496b84e5581950eb03c4                  |
+------------+---------------------------------------------------+
```

Now you can accee swift by `storage-url` and `auth-token` as follows:
```
$ swift --os-storage-url http://<proxy-server-ip>:8080/v1/AUTH_2bccc882410f47f2b6e443ff6652d412 --os-auth-token gAAAAABaovyZMxKGDN--jkOFyT1JLQtZLxEXm99i...-Yb8Epc list
container1
container2
container3
```
Note that you can replace `controller` with `<proxy-server-ip>` to change the access point.


