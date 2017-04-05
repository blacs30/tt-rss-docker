# Build and push the image

```
docker build -t docker.terhaak.de/jojo/tt-rss .
docker push docker.terhaak.de/jojo/tt-rss
```

# Deploy on openshift

First create a persitent volume as admin (or let it be created for you)

Create the objects from the template:

```
oc -n jojo process -f openshift-template.yml | oc -n jojo create -f -
```

Replace `jojo` with your project-namespace.

Prepare a folder with your `config.php` and possibly `feed-icons` folder.

Get a list of the running pods and remember the name of the tt-rss pod:

```
oc -n jojo get pods
```

Sync the files to the persistent volume:

```
oc -n jojo rsync -c tt-rss /home/jojo/Desktop/data/ tt-rss-1-gn5ej:/data/
```

replace `tt-rss-1-gn5ej` with the pod name.

Once the config.php is there the updater pod should stop crashing and you can visit 
the URL pointing to thye router. Apply the database-upgrade if necessary.

# Deploy on bare docker

```
docker run -it --rm -p 8005:80 -v /home/jojo/Desktop/data:/data  -e MODE=app docker.terhaak.de/jojo/tt-rss
docker run -it --rm -v /home/jojo/Desktop/data:/data -e MODE=updater docker.terhaak.de/jojo/tt-rss
```
