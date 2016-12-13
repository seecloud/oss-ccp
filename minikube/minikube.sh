#!/bin/bash 
set -x
set -eu
set -o pipefail

up_registry () {
  docker run -d -p 5000:5000 --restart=always --name registry registry:2
}

deploy_es () {

  if [[ $(kubectl get namespace | grep oss | wc -l) -lt 1 ]]; then
    kubectl create namespace oss
  fi

  pushd elasticsearch
  for YAML in service-account.yaml es-svc.yaml es-rc.yaml ; do
    kubectl create -f $YAML --namespace=oss
  done
  popd

  while true; do
    STATUS=$(kubectl get po | grep es | awk -F' ' '{print $3}')
    if [ "$STATUS" == 'Running' ]; then
      break
    fi
  done
  ES_PORT=$(kubectl get svc elasticsearch -o json | jq -r '.spec.ports[] | select(.name == "http") | .nodePort')
  MINIKUBE_IP=$(minikube ip)
  echo "============================================"
  echo "ElasticSearch adress:  $MINIKUBE_IP:$ES_PORT"
  echo "============================================"
}


generate_config () {
  CA_CERT=$(grep certificate-authority ~/.kube/config | awk -F" " '{print $2}')
  CERT_FILE=$(grep client-certificate ~/.kube/config | awk -F" " '{print $2}')
  KEY_FILE=$(grep client-key ~/.kube/config | awk -F" " '{print $2}')
  REGISTRY_IP=$(hostname -i)
  cat > ~/.ccp.yaml <<EOF
builder:
  push: True
registry:
  insecure: True
  address: "$REGISTRY_IP:5000"
nodes:
  minikube:
    roles:
      - infra
      - frontend
      - backend
kubernetes:
  namespace: oss
  server: "https://kubernetes:8443"
  ca_cert: "$CA_CERT"
  cert_file: "$CERT_FILE"
  key_file: "$KEY_FILE"
  insecure: "true"

images:
  namespace: oss
repositories:
  repos:
    - name: fuel-ccp-debian-base
      git_url: https://github.com/openstack/fuel-ccp-debian-base
    - name: fuel-ccp-entrypoint
      git_url: https://github.com/openstack/fuel-ccp-entrypoint
    - name: fuel-ccp-etcd
      git_url: https://github.com/openstack/fuel-ccp-etcd
    - name: fuel-devops-portal
      git_url: https://github.com/seecloud/fuel-devops-portal
    - name: ceagle
      git_url: https://github.com/seecloud/ceagle
    - name: health
      git_url: https://github.com/seecloud/health
    - name: availability
      git_url: https://github.com/seecloud/availability
    - name: performance
      git_url: https://github.com/seecloud/performance
roles:
  infra:
    - etcd
  frontend:
    - devops-portal
  backend:
    - ceagle
    - health-api
    - health-job
    - availability-api
    - availability-watcher

debug: true
EOF
}

set_context() {
  kubectl config set-context oss --namespace oss
  kubectl config use-context oss
}

_help() {
  echo "Help for this script:"
  echo " -s - change kubectl context to oss"
  echo " -g - generate configuration file for ccp"
  echo " -d - deploy elasticsearch to kubernetes"
  echo " -u - set up local registry"
  echo " -h - show this help message"
}


while getopts "sgduh" opt ; do
  case $opt in
    s)
      set_context
    ;;
    g)
      generate_config
    ;;
    d)
      deploy_es
    ;;
    u)
      up_registry
    ;;
    h)
      set +x
      _help
    ;;
    *)
    ;;
  esac
done

