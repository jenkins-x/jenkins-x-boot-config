
## Jenkins X Boot Configuration

This repository contains the source code for [Jenkins X Boot configuration](https://jenkins-x.io/getting-started/boot/) so that you can setup, upgrade or configure your Jenkins X installation via GitOps.

## How to install...

### Creating a kubernetes cluster

* either use Terraform to spin up a GKE cluster with a `jx` namespace and any necessary cloud resources (e.g. on GCP we need a Kaniko Service Account and Secret)
* create an empty GKE cluster by hand e.g. via `jx create cluster gke --skip-installation` or using the [GCP Console](https://console.cloud.google.com/)

### Run the new Jenkins X Bootstrap Pipeline

Clone this git repository and make sure you have a recent `jx` binary:

From inside the git clone of this repository type:

``` 
jx boot
```

If you are not in a clone of a boot git repository then `jx boot` will clone this repository and `cd` into the clone.

The bootstrap process runs the Jenkins X Pipeline in interpret mode as there's nothing running in your Kubernetes cluster yet and so there's no server side tekton controller until after we bootstrap.

The bootstrap process will also ask you for various important `parameters` which are used to populate a bunch of `Secrets` stored in either Vault or the local file system (well away from your git clone).

The pipeline will then setup the ingress controller, then cert manager, then install the actual development environment.

Apart from the secrets populated to Vault / local file system everything else is stored inside this git repository as Apps and helm charts.


### How it works

We have improved the support for value + secret composition via this [issue](https://github.com/jenkins-x/jx/issues/4328).


### Parameters file

We define a [env/parameters.yaml](https://github.com/jstrachan/environment-simple-tekton/blob/master/env/parameters.yaml) file which defines all the parameters either checked in or loaded from Vault or a local file system secrets location.

#### Injecting secrets into the parameters

If you look at the current [env/parameters.yaml](https://github.com/jstrachan/environment-simple-tekton/blob/master/env/parameters.yaml) file you will see some values inlined and others use URIs of the form `local:my-cluster-folder/nameofSecret/key`. This currently supports 2 schemes:

* `vault:` to load from a path + key from Vault
* `local:` to load from a key in a YAML file at `~/.jx/localSecrets/$path.yml`

This means we can populate all the Parameters we need on startup then refer to them from `values.yaml` to populate the tree of values to then inject those into Vault.


#### Populating the `parameters.yaml` file 

We can then use the new step to populate the `parameters.yaml` file via this command in the `env` folder:

``` 
jx step create values --name parameters
```

This uses the [parameters.schema.json](https://github.com/jstrachan/environment-simple-tekton/blob/master/env/parameters.schema.json) file which powers the UI.

So if you wanted to perform your own install from this git repo, just fork it, remove `env/parameters.yaml` and run the bootstrap command!

### Improvements to values.yaml

#### Support a tree of values.yaml files

Rather than a huge huge deeply nested values.yaml file we can have a tree of files for each App only include the App specific configuration in each folder. e.g.

``` 
env/
  values.yaml   # top level configuration
  prow/
    values.yaml # prow specific config
  tekton/
    vales.yaml  # tekton specific config 
```
  
  
#### values.yaml templates

When using `jx step helm apply` we now allow `values.yaml` files to use go/helm templates just like `templates/foo.yaml` files support inside helm charts so that we can generate value/secret strings which can use templating to compose things from smaller secret values. e.g. creating a maven `settings.xml` file or docker `config.json` which includes many user/passwords for different registries.

We can then check in the `values.yaml` file which does all of this composition and reference the actual secret values via URLs (or template functions) to access vault or local vault files

To do this we use expressions like: `{{ .Parameter.pipelineUser.token }}` somewhere in the `values.yaml` values file. So this is like injecting values into the helm templates; but it happens up front to help generate the `values.yaml` files.
.
