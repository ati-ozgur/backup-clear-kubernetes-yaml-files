
function run_kubectl_get
{
	param (
		[string]$type_name,
		[string]$namespace = ""
		)
	if ($namespace -ne "") 
	{
		$scriptblock = {kubectl get $type_name --namespace $namespace -o name}
	}
	else
	{
		$scriptblock = {kubectl get $type_name -o name}
	}
	$list = Invoke-Command -scriptblock $scriptblock

	if (!$list) 
	{ 
		$list = @()
	}

	#Write-Host $list
	
	#Write-Host $list.GetType().Name
	#return

	# if only one element it is string
	if ($list.GetType().Name -eq "String")
	{
		$current = $list
		$start_index = $current.IndexOf("/") + 1
		$current = $current.SubString($start_index)
		$list = @($current)
	}
	else
	{
		$list = $list | sort

		for($i=0;$i -lt $list.Length; $i++)
		{
			$current = $list[$i] 
			$start_index = $current.IndexOf("/") + 1
			$current = $current.SubString($start_index)
	
			$list[$i] = $current
		}
	
	}


	Write-Output -NoEnumerate $list
}





function get_namespaces
{
	run_kubectl_get "namespaces"

}

function confirm_folder
{
	param (
		[string]$foldername
		)
	$exists = Test-Path -Path $foldername
	if ( $exists -eq $false) {
	   Write-Host "$foldername doesn't exist, creating"
	   # silent create directory
	   $null = New-Item -Path $foldername -ItemType directory
	}
}


function save_yaml
{
	param (
		[string]$type_name,
		[string]$name,
		[string]$namespace = "",
		[string]$folder_to_save
		)
	$output_folder = "$folder_to_save/$namespace/$type_name"
	confirm_folder $output_folder

	$scriptblock = {kubectl get $type_name $name  -n $namespace -o=json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' | yq eval . --prettyPrint	}
	Invoke-Command -scriptblock $scriptblock | Out-File "$output_folder\$name.yml" -encoding utf8
	
}

function save_resource
{
	param (
		[string]$type_name,
		[string]$namespace,
		[string]$folder_to_save
		)
	Write-Host "Working on $namespace $type_name"

	$script_block = {
		$list = run_kubectl_get ${type_name}  $namespace
		for($j=0;$j -lt $list.Length; $j++)
		{
			$current_name = $list[$j]
			Write-Host "saving $type_name : $current_name in $namespace "
			save_yaml ${type_name}  $current_name $namespace $folder_to_save
		}
	
	}
	Invoke-Command -scriptblock $script_block

}

function save_all_in_namespace
{
	param (
		[string]$namespace = "development",
		[string] $folder_to_save		
		)
		# workloads
		save_resource "pods" $namespace $folder_to_save
		save_resource "deployments" $namespace $folder_to_save
		save_resource "daemonsets" $namespace $folder_to_save
		save_resource "statefulsets" $namespace $folder_to_save
		save_resource "replicasets" $namespace $folder_to_save
		save_resource "jobs" $namespace $folder_to_save
		save_resource "cronjobs" $namespace $folder_to_save

		# config
		save_resource "configmaps" $namespace $folder_to_save
		save_resource "secrets" $namespace $folder_to_save

		# network
		save_resource "services" $namespace $folder_to_save
		save_resource "endpoints" $namespace $folder_to_save
		save_resource "ingress" $namespace $folder_to_save
		save_resource "networkpolicy" $namespace $folder_to_save

		# storage
		save_resource "persistentvolumeclaims" $namespace $folder_to_save
		save_resource "persistentvolume" $namespace $folder_to_save

		

}

function save_all
{
	param (
		[string] $folder_to_save = "backup"
		)
	$namespaces = get_namespaces
	for($i=0;$i -lt $namespaces.Length; $i++)
	{
		$namespace = $namespaces[$i]
		save_all_in_namespace $namespace $folder_to_save

	}
}


