# Tiny Tiny RSS Docker Deployment

The docker file shipped in this repository build a single container for both the web 
app and the updater daemon. In which mode the container is started is specified by the 
*MODE* environment variable. 

The container contains the latest tiny tiny rss code from the master ( = stable )
branch. After the container has been updated tt-rss may ask to do database migration 
on the next login. This works completely on the web interface. 
See also [the installation notes](https://git.tt-rss.org/fox/tt-rss/wiki/InstallationNotes)

The container contains a special `config.php` file, which converts environment variables 
into tt-rss configuration constants. See the [source code](./config/ttrss/config.php) 
of this file and the [example config file](https://git.tt-rss.org/fox/tt-rss/src/master/config.php-dist)
for details.

The container requires a persistent volume mounted to `/data` to store the feed icons,
a extra `config.php` file and a `.htaccess` file to configure apache httpd.

## Runnin on bare docker

```
docker run -it --rm -p 8005:8080 -v /tmp/data:/data -e MODE=app tt-rss
docker run -it --rm -v /tmp/data:/data -e MODE=updater tt-rss
```

Docker support also a environment file to set many environment variables without 
obstructing the command.

## Deploying on openshift

This repository contains a template for openshift. See the 
[install instructions](./docs/deployment-openshift.md) for openshift.

This method is deprecated, since I moved to bare kubernetes and helm.

## Deploying on kubernetes with helm 

See the [install instructions](./docs/deployment-helm.md) for helm.

## Reverse proxy setup

See [reverse-proxy.md](./docs/reverse-proxy.md) for details on how to deploy behind a reverse
proxy.
