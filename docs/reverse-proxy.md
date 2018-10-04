# Reverse proxy setup to kubernetes

The helm chart sets up a *nodePort* type service. This means that kubernetes 
exposes the tt-rss service on a specific port number (selected by k8s) on all nodes.
One could use ingress to load balance inside of kubernetes, however using 
already apache httpd for my main website, I prefer to directly use the load balancing
capacities of apache.

This is a schema of the set up:

```
                                 +----------+    +-----------+
                             +-> | k8s node | -> | ttrss pod |
                +---------+  |   +----------+    +-----------+
+---------+     | apache  |  |   +----------+          ^
| Browser | ->  | reverse | -*-> | k8s node | -------->|
+---------+     | proxy   |  |   +----------+          |
                +---------+  |   +----------+          |
                             +-> | k8s node | -------->|
                                 +----------+
```

Apache distributes the load to the kubernetes nodes. When traffic enters a node
it is routed to the corresponding pod, regardless on which node the pod runs 
(due to the overlay network used by k8s). If the node with the pod fails, the pod 
is rescheduled on a free available node and the traffic is redirected to the new pod.

Note that this still has single point of failures. However shutting down the main 
apache httpd means shutting down the complete website and thus is avoided.

First get the node port assigned to the service of tt-rss:

```
kubectl get service
```

Now to the apache configs:

```xml
<Proxy balancer://my-ha-ttrss>
    BalancerMember http://kubernetes-node1.example.com:30958
    BalancerMember http://kubernetes-node2.example.com:30958
    BalancerMember http://kubernetes-node3.example.com:30958
    ProxySet lbmethod=byrequests
</Proxy>

RedirectPermanent "/apps/ttrss" "https://www.example.com/apps/ttrss/"
<LocationMatch "^/apps/ttrss/(.*)$" >
    ProxyPass "balancer://my-ha-ttrss/apps/ttrss/$1"
    ProxyPassReverse "balancer://my-ha-ttrss/apps/ttrss/$1"
    ProxyPreserveHost On
</LocationMatch>
```

Enable the load balancer module and restart apache:

```
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
systemctl restart apache2
```

Do not forget to make the common app config changes (described below).


# Reverse proxy setup with Openshift

Setup:
```
               +---------+    +-----------+    +-----------+
+---------+    | apache  |    | openshift |    | apache    |
| Browser | -> | reverse | -> | HA-proxy  | -> | ttrss pod |
+---------+    | proxy   |    | router    |    +-----------+
               +---------+    +-----------+
```

The first apache reverse proxy is facing the internet and is also used for TLS termination.
The Openshift router is only accessible in the LAN. Actually the openshift router 
will forward to the ttrss openshift service, which in turn will forward to the pod, but this
is omitted for simplicity. 

This setup will make tt-rss availabe on the URL: `https://www.example.com/apps/ttrss`.
The openshift router is accessible on the LAN by this hostname: `paas.example.com`.

In order to work correctly the main reverse proxy will need to preserve the host 
and the openshift route must be set to the public hostname and needs a path set.
TT-RSS will check if `SELF_URL_PATH` is set correctly and will not redirect properly 
the login page when `_SKIP_SELF_URL_PATH_CHECKS` is set to true. In order to 
preserve the hostname until the tt-rss app the openshift router must also preserve 
the hostname. The only way to set this, is to use the public hostname and use the path as 
unique differentiator.

The apache config of the main reverse proxy facing the internet:

```
RedirectPermanent "/apps/ttrss" "https://www.example.com/apps/ttrss/"

<LocationMatch "^/apps/ttrss/(.*)$" >
  ProxyPassReverse "http://paas.example.com/apps/ttrss/$1"
  ProxyPass "http://paas.example.com/apps/ttrss/$1"
  ProxyPreserveHost On
</LocationMatch>
```

Template parameters to be set in `ttrss.env` (or on the command line):

```
APP_ROUTE_HOST="www.example.com"
APP_ROUTE_PATH="/apps/ttrss"
```

Note the missing trailing slash on `APP_ROUTE_PATH`, required for openshift to 
proxy also sub-urls.

Do not forget to make the common app config changes (described below).

# Common app config for reverse proxying tt-rss

TT-RSS will complain about wrong `SELF_URL_PATH` because the TLS termination 
happens before the app container. Tt-rss will see `http://` instead of `https://`

We need to add the the following line to `config.php`

```
define('_SKIP_SELF_URL_PATH_CHECKS', true);
```

Now we need to make the path available in the tt-rss container. By default the container 
will make tt-rss available on the root path. We add a `.htaccess` file with a rewrite rule 
into the data volume. The container will link this file into it's web root.

```
RewriteEngine On
RewriteRule  "^app/ttrss/(.*)$" "/$1"
```

Note the missing leading slash in the rule pattern. Rewrite rules in `.htaccess`
files are relative to the directory where they reside, thus in this case `/`. 

Copy `config.php` and `.htaccess` into the root of the data volume of the app container
and restart the container. Now you should be able to use tt-rss.
