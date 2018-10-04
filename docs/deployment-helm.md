# Deploy to kubernetes with helm

Clone the tt-rss-docker project and change into the charts directory:

```
git clone https://gitlab.terhaak.de/jojo/tt-rss-docker.git tt-rss
cd tt-rss/helm-charts
```

Export the helm environment variables (if needed):

```sh
export HELM_HOME="/myhelm/mynamespace"
export TILLER_NAMESPACE="mynamespace"
```

Create a `values.yaml` file to configure the instance of ttrss. You can copy the 
file with the default variables and then adapt it. The exact location of the file 
is not important, as long it is always accessible.

```
cd tt-rss/values.yaml ../../tt-rss-values.yml
vim ../../tt-rss-values.yml
```

Example (The file with the defaults contains extra comments with explanations):

```yaml
database:
  type: "mysql"
  host: "myhost"
  user: "myuser"
  name: "mydb"
  password: "my_precious"
  port: "3306"

ttrss:
  selfUrl: "https://example.com/ttrss"
  singleUser: "true"

image:
  repository: registry.example.com/tt-rss
  tag: latest
  pullPolicy: Always

persistence:
  accessMode: ReadWriteOnce
  size: 500Mi

service:
  type: NodePort
  port: 80
  
securityContext:
  supplementalGroups: [5000] 
```

Then install the chart:

```
helm install -f ../../tt-rss-values.yml tt-rss
```

To upgrade to the latest chart version, use:

```
helm upgrade -f ../../tt-rss-values.yml release-name tt-rss
```

The release name is displayed after the installation and does not change until you 
remove and recreate the instance.

The chart contains a persistent volume claim. My custom k8s infrastructure uses manual
volume provisioning.

To query the name of the PVC:

```sh
echo $(kubectl -n jojo get pvc -o jsonpath='{.items[*].metadata.name}' --selector=app=tt-rss)
```

Then Create a PV bound to the wainting PVC 
(attention this config sample is truncated. Refer to the k8s docs for details)

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-ttrss-data
  annotations:
    pv.beta.kubernetes.io/gid: "5000"
spec:
  storageClassName: manual
  persistentVolumeReclaimPolicy: Retain
  capacity:
    storage: 500Mi
  accessModes:
    - ReadWriteMany
    - ReadWriteOnce
  claimRef:
    namespace: mynamespace
    name: release-name-tt-rss
  cephfs:
    ...
```

Note the use of `claimRef` to directly bind the PV to it's claim.

To restore a backup of the data I mount the cephfs filesystem and copy the files normally.

Finally expose tt-rss using a [reverse-proxy](reverse-proxy.md).