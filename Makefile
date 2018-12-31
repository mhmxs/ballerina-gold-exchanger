deps:
	brew install ballerina

init:
	minikube addons enable ingress

build:
	$(info Do not forget to execute 'eval $$(minikube docker-env)' before building project)
	ballerina build

kube-apply:
	$(info Be sure minikube config is the active)
	kubectl apply -f target/kubernetes/exchange-simple
	kubectl apply -f target/kubernetes/exchange-enterprise
	kubectl apply -f target/kubernetes/calculator

expose:
	kubectl port-forward $$(kubectl get pods -o=name | grep exchange-simple-deployment) 9091 || : &
	kubectl port-forward $$(kubectl get pods -o=name | grep exchange-enterprise-deployment) 9092 || : &
	kubectl port-forward $$(kubectl get pods -o=name | grep calculator-deployment) 9090 || : &

cleanup:
	$(info Be sure minikube config is the active)
	kill -9 $$(ps x | grep "port-forward pod/exchange-simple-deployment" | head -1 | cut -d' ' -f 1)
	kill -9 $$(ps x | grep "port-forward pod/exchange-enterprise-deployment" | head -1 | cut -d' ' -f 1)
	kill -9 $$(ps x | grep "port-forward pod/calculator-deployment" | head -1 | cut -d' ' -f 1)
	@kubectl delete -f target/kubernetes/exchange-simple || :
	@kubectl delete -f target/kubernetes/exchange-enterprise || :
	@kubectl delete -f target/kubernetes/calculator || :