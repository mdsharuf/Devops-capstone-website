#!/usr/bin/env bash
set -e
CLUSTER=${1:-minikube}

if [ "$CLUSTER" = "minikube" ]; then
  echo "Starting minikube..."
  minikube start || true
  echo "Using minikube docker daemon..."
  eval $(minikube docker-env)
  echo "Building image..."
  docker build -t website:local .
  echo "Deploying to Kubernetes with local image..."
  sed 's|mdsharuf/devops-capstone-website:latest|website:local|g' k8s/deployment.yaml | kubectl apply -f -
  kubectl apply -f k8s/service.yaml
  kubectl rollout status deployment/capstone-website-deployment --timeout=120s
  echo "Service URL:"
  minikube service capstone-nodeport --url
else
  echo "Using kind..."
  kind create cluster --name capstone || true
  docker build -t website:local .
  kind load docker-image website:local --name capstone
  sed 's|mdsharuf/devops-capstone-website:latest|website:local|g' k8s/deployment.yaml | kubectl apply -f -
  kubectl apply -f k8s/service.yaml
  kubectl rollout status deployment/capstone-website-deployment --timeout=120s
  echo "Note: You may need port-forward for NodePort on kind."
fi

