This project aims to demonstrate language features and power of Ballerina language.

The example contains 3 microservices and a CLI tool to interact with the services.
The CLI tool "calculates" best gold currency ratio, and exchanges the amount of gold to the given currency. The services are running in minikube by default.

Operations are the following:
 * CLI tool downloads the ratio from two different services parallely
 * Finds best price
 * Call calculator service to exchange

Components:
 * Exchange service - simple version
 * Echange service - enterprise version
 * Calculator servcie (does not support all operations)

 Steps to execute:
  * make deps - Install Ballerina with brew
  * make init - Enable nginx addon in Minikube
  * $(minikube docker-env)
  * make build - Build project, Docker and Kubernetes resources
  * make kube-apply - Apply service descriptors on Minikube
  * make expose - Expose services to localhost
  * ballerina run convert.bal 3 USD
