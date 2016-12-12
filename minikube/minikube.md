# Quickstart to Mirantis MS development

### Table of contents:
- [Install kubectl](#kubectl)
- [Install minikube](#minikube)
- [Install drivers for minikube](#minikube_drivers)
- [Let's start!](#starting)

### <a name="kubectl"></a>Kubectl installation

For installation of `kubectl` you can use [these](http://kubernetes.io/docs/user-guide/prereqs/) instructions

### <a name="minikube"></a>Minikube installation

For getting `minikube` binaries you can proceed with [this](https://github.com/kubernetes/minikube/releases) instruction

### <a name="minikube_drivers"></a>Install drivers for minikube

This step is optional, but if you want use minikube with kvm driver, take a look at [these](https://github.com/kubernetes/minikube/blob/master/DRIVERS.md) guide

### <a name="starting"></a>Let's start!

First that you need to do, it's add string with 'kubernetes' and your ip address at your `/etc/hosts`.
After that you can use `minikube.sh` script, that allow you generate config for ccp project, setup simple local docker registry and deploy ElasticSearch to kubernetes.
Just run:
 - `./minikube.sh -g` - for config generation
 - `./minikube.sh -u` - for registry creation
 - `./minikube.sh -d` - for ES deployment
 
N.B.! You should disable tls verification for docker private registry, or use self-signed certificates

After these steps, you can clone [ccp repo](http://github.com/openstack/fuel-ccp), and install it with instructions. After config generation, you can start using our ccp definition:
 - `ccp fetch` will clone our repos
 - `ccp build -c etcd ceagle health devops-portal` will build proper docker images
 - `ccp deploy -c etcd ceagle health-api health-job devops-portal` start these application in kubernetes


