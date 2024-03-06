IMAGE=zenitugo/healet
varfile=terraform.tfvars
deployfile=deploy.yml
servicefile=service.yml
REGION=eu-west-1
clusterName=my-eks-cluster
namespace1=healet
namespace=namespace.yml
namespace2=prometheus
namespace3=grafana

# To build a docker image
build:
	docker build -t "${IMAGE}" 

# To build and push image to docker hub
publish: build
	docker push "${IMAGE}" 
	
initialize:
	terraform init

# To validate configuration
validate: initilize
	terraform validate

# To review configuration
review: validate
	terraform plan -var-file="${varfile}"

# To create aws infrastructure
cluster: review
	terraform apply -auto-approve

# To destroy aws infrastructure
destroy:
	terraform destroy -auto-approve

# To update aws cli to have access to eks
access-aws:
	aws eks update-kubeconfig --region "${REGION}" --name "${clusterName}"

# To create namespaces for the pods
namespace:
	kubectl apply -f ${namespace}

# To deploy web app on eks
deployment:
	kubectl apply -f "${deployfile}"

# To expose web app outside the cluster
service:
	kubectl apply -f "${servicefile}"

# To see all worker nodes
nodes:
	kubectl get nodes

# To check the svc for the healet application
check app-svc:
	kubectl get svc  -n "${namespace1}"

# To check the pods for healet app
pods-app:
	kubectl get pods -n "${namespace1}"


# To check all the resources for healet app
healet:
	kubectl get all -n "${namespace1}"

# To install and add prometheus to namespace called prometheus
install-prometheus:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts \
	helm repo update; \
	helm install prometheus prometheus-community/prometheus \
	--namespace "${namespace2}" \
	--set server.alertManager.persistentVolume.storageClass="gp2" \
	--set server.persistentVolume.storageClass="gp2" \
	--set server.service.type=LoadBalancer 

# To see all prometheus resources
prometheus:
	kubectl get all -n "${namespace2}"

# To install and add grafana to namespace called grafana
add-grafana:
	helm repo add grafana https://grafana.github.io/helm-charts \
	helm repo update; \
	helm install my-grafana grafana/grafana \
	--namespace "${namespace3}"
	--set persistence.storageClassName="gp2"
	--set adminPassword='ubuntu'
	--set server.service.type=LoadBalancer

# To see all grafana resources
grafana:
	kubectl get all -n "${namespace3}"


