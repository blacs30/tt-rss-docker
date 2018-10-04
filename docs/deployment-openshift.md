# Deploy on openshift

First create a persitent volume as admin (or let it be created for you). 
The template uses the `supplementalGroups` 5555.

Change to the root of the GIT tree and build the docker image:

```
docker build -t docker-registry-default.apps.lan.terhaak.de/ttrss-test/tt-rss:latest .
```

Adjust the docker-tag to point to your internal openshift registry.

The template exposes some configuration parameters. You can set them in the web console
while importing the template, or on the command line using a env-file.

Create a file `ttrss.env` and adapt the values:

```sh
DB_TYPE="mysql"
DB_HOST="myhost"
DB_USER="myuser"
DB_NAME="mydb"
DB_PASS="mypass"
DB_PORT="3306"
SELF_URL_PATH="https://example.com/ttrss"
SINGLE_USER_MODE="false"
APP_ROUTE_HOST="my-ttrss.apps.example.com"
```

Make sure to change to your project (adapt the project name):

```
oc project my-ttrss
```

Create the openshift objects based on the template:

```
oc process --param-file=ttrss.env -f openshift-template.yml | oc create -f -
```

Push the docker image to the internal registry to trigger the deployment. The 
containers will automatically redeploy when the docker image is updated.

```
docker push docker-registry-default.apps.lan.terhaak.de/ttrss-test/tt-rss:latest
```

You can override the default configurations and the parameters from the template 
using a normal tt-rss config file. Refer to the file `config.php-dist` in the tt-rss
GIT tree for details. Drop the config file into the root of the data volume mounted 
in the containers on `/data`. This way you can also add a `.htaccess` file which will
be linked into the www-base directory. You can use this to add rewrite rules. 
  
Prepare a folder on your local host (example: `/tmp/data`) 
with your `config.php` and possibly a `feed-icons` folder.

Get a list of the running pods and remember the name of the tt-rss pod:

```
oc get pods
```

Sync the files to the persistent volume:

```
oc rsync -c tt-rss /tmp/data/ tt-rss-1-gn5ej:/data/
```

replace `tt-rss-1-gn5ej` with the pod name.

Now visit the url set in `SELF_URL_PATH`.
