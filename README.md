# Terraforming HELM land with GKE


## Project dependencies
- [git](https://git-scm.com/downloads)
- [docker](https://www.docker.com/products/docker-desktop)
- [terraform](https://www.terraform.io/downloads.html) 
- [gcloud cli](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://github.com/helm/helm#install)


## Project setup

Create an account on [gcloud](https://cloud.google.com/) and login via [cli](https://cloud.google.com/sdk/gcloud/reference/auth/login) 

Create a new project on your account and set as default

```
gcloud projects create [name-of-your-project] --set-as-default
```

Generate a directory to create the service account for this proyect example:

```
touch ~/.config/gcloud/[name-of-your-project].json
```

Export this values as env variables

```
export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/[name-of-your-project].json
export GOOGLE_PROJECT=[name-of-your-project]
```

Generate a service account to allow terraform interact with the resources on your project

```
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

gcloud iam service-accounts keys create ${GOOGLE_APPLICATION_CREDENTIALS} \
  --iam-account terraform@${GOOGLE_PROJECT}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT} \
  --member serviceAccount:terraform@${GOOGLE_PROJECT}.iam.gserviceaccount.com \
  --role roles/editor

gcloud services enable \
  container.googleapis.com \
  containerregistry.googleapis.com
```

Or you can use the `setup.sh` script provided on this repository

## Generate the infrastructure for the project 

Is important to have available the env variables provided on the steps above

```
export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/[name-of-your-project].json
export GOOGLE_PROJECT=[name-of-your-project]
```

Init terraform 

```
terraform init
```

Create a `dev` workspace for terraform.
This project take advantage of `terraform workspaces` to provide differents resources for each stage 

```
# create dev workspace
terraform workspace new dev
# list workspaces 
terraform workspace list
# use dev workspace
terraform workspace use dev
```

Plan and apply the IaC

```
terraform plan
```

```
terraform apply
```

## Assing Dns record for the project

After apply the IaC the next output is provided

```
endpoint = ***.***.***.***
ip_cidr_range = 10.240.0.0/24
ip_reserved = ***.***.***.***
vpc_name = dev-vpc
```

We need provide an `A` dns record of you domain for the `ip_reserved` 

Now we are hable to deploy our helm chart

## Get you cluster credentials and check if the helm chart are installed

Use gcloud cli to get the credentials of your project with kubectl 

```
gcloud container clusters get-credentials gke-dev-cluster
```

Check if the access is working getting the pods provided by `helm` charts in the cluster 

```
kubectl get pods

NAME                                                READY     STATUS    RESTARTS   AGE
cert-manager-847b797c7d-mgfz9                       1/1       Running   0          6m
ingress-nginx-ingress-controller-799bc6dff8-dsqfl   1/1       Running   0          6m

```

Check if the charts are installed

```
helm ls 

NAME        	REVISION	UPDATED                 	STATUS  	CHART              	APP VERSION	NAMESPACE  
cert-manager	1       	Thu Feb 28 01:06:35 2019	DEPLOYED	cert-manager-v0.5.2	v0.5.2     	default    
ingress     	1       	Thu Feb 28 01:06:32 2019	DEPLOYED	nginx-ingress-1.3.0	0.22.0     	default    
keel        	2       	Thu Feb 28 01:06:34 2019	DEPLOYED	keel-0.7.7         	0.13.0     	kube-system
```

## Configure the helm chart of the app

check the `values.yaml` file on `helm/cat-app/`

provide the values for your image, hosts, and the acmeMail for the certificates with your domain record 
```
image:
  repository: omero/cat-app
  tag: "0.0.1"
  pullPolicy: IfNotPresent

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    certmanager.k8s.io/issuer: letsencrypt-prod
  paths: ["/"]
  hosts:
    - cat-app.omers.xyz
  tls: 
   - secretName: cat-app-crt
     hosts:
       - cat-app.omers.xyz

acmeMail: info@omers.xyz
```

This chart provides continous delivery taking advantage of [keel](https://keel.sh) project you can play with the configurations and the helm releases on terraform to provide the way that fits on your project

## install the helm chart and see the results

Locate on the helm chart of this project 

```
cd helm/cat-app
```

Istall the chart with helm cli 

```
helm install --name cat-app .
```

Go to your domain and see the results 
enjoy :) 