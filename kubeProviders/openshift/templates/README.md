## Openshift Manifests

The files in this folder will never be applied automatically by Jenkins X and are here just to be used independently or to be referenced in documentation.

One of the steps to get Jenkins X installed in an OpenShift cluster with limited permissions is having an admin install these manifests in the cluster directly with Kubectl.

By having them here, they can do so by executing:

```bash
 $ kubectl -f https://raw.githubusercontent.com/<path_to_the_file>
```
