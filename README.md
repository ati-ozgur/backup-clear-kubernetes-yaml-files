# backup clear kubernetes yaml files

This repository is about taking clear kubernetes yaml files for backup.
I know you are supposed to implement gitops/devops and yaml files are supposed to be kept in the source control (git) repository.
But reality is sometimes you can not enforce this policy and you would like to get backup clear yaml files from your current kubernetes cluster.

Script is written in powershell.
I work mostly in windows and powershell is cross platform nowadays.

## Main idea

Read following [blog post](https://fabianlee.org/2022/06/06/kubernetes-export-a-clean-yaml-manifest-that-can-be-re-imported/
)

It shows using jq and yq commands to get clear yaml file for a kubernetes resource.



- [jq](https://github.com/stedolan/jq/) jq is Command-line JSON processor 
- [yq](https://github.com/mikefarah/yq) yq is a portable command-line YAML, JSON, XML, CSV and properties processor 


install these two tools.

### windows install of jq and yq

I am using scoop


	scoop install jq
	scoop install yq

### ubuntu install of jq and yq



	sudo apt install jq -y
	sudo snap install yq

## usage

1. download zip or clone repository
2. open powershell
3. goto directory of project

4. run following commands in powershell

a. save everything in all namespaces in default backup folder

	.  .\backup_clear_kubernetes_yaml_files.ps1 
	save_all

b. save everything in all namespaces in a given folder

	.  .\backup_clear_kubernetes_yaml_files.ps1 
	save_all folder_to_save


c. save everything in given namespace, below development

	.  .\backup_clear_kubernetes_yaml_files.ps1 
	save_all_in_namespace development


d. save everything in given namespace and folder, below development and folder_to_save

	.  .\backup_clear_kubernetes_yaml_files.ps1 
	save_all_in_namespace development folder_to_save

e. save one resource in given namespace, below save deployments in development namespace

	.  .\backup_clear_kubernetes_yaml_files.ps1 
	save_resource deployments development

f. save one resource in given namespace, below save deployments in development namespace in folder_to_save

	.  .\backup_clear_kubernetes_yaml_files.ps1 
	save_resource deployments development folder_to_save


5. every resource you have access are saved to backup directory separated by namespace and resource name.
Below is an output directory structure of an example run

```
└───development
    ├───configmaps
    ├───deployments
    ├───endpoints
    ├───ingress
    ├───pods
    ├───replicasets
    ├───secrets
    └───services
```


### current resources saved

current script saves below resources.
It should be easy to add more resources to this list provided resource is supported by kubectl get command.



- workloads
	- "pods"
	- "deployments"
	- "daemonsets"
	- "statefulsets"
	- "replicasets"
	- "jobs"
	- "cronjobs"
- config
	- "configmaps"
	- "secrets"
- network
	- "services"
	- "endpoints"
	- "ingress"
	- "networkpolicy"
- storage
	- "persistentvolumeclaims"
	- "persistentvolume"




### Pull requests

Pull requests are welcome.
Current scripts is enough for me right now but bug fixes/more features are always good.


I handled 1 value return from kubectl get command using type checking for string.
But if powershell experts has a more elegant solution, I would like to learn it.

