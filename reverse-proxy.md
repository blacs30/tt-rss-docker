# Reverse proxy setup

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

TT-RSS will still complain about wrong `SELF_URL_PATH` because of the TLS termination.
( `https://` instead of `http://`). So add the the following line to `config.php`

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

Rsync this file into the data volume along `config.php` and `feed-icons`.

Now everything should work as expected.
