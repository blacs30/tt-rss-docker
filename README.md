
# Reverse proxy setup

See [reverse-proxy.md](reverse-proxy.md) for details on how to deploy behind a reverse
proxy.

# Deploy on bare docker

You can pass the same environment variables as in the openshift 
template, except for `APP_ROUTE_HOST`.

```
docker run -it --rm -p 8005:8080 -v /tmp/data:/data -e MODE=app tt-rss
docker run -it --rm -v /tmp/data:/data -e MODE=updater tt-rss
```
