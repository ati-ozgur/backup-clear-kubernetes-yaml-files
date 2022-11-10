# backup-clear-kubernetes-yaml-files

This repository is about taking clear kubernetes yaml files for backup.
I know you are supposed to implement gitops/devops and yaml files are supposed to be in the repository.
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
I am using scoop


	scoop install jq
	scoop install yq


## usage

