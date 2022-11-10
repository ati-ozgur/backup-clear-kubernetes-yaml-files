
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
	$list = $list | sort

	for($i=0;$i -lt $list.Length; $i++)
	{
		$current = $list[$i] 
		$start_index = $current.IndexOf("/") + 1
		$current = $current.SubString($start_index)

		$list[$i] = $current
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
		[string]$namespace = ""
		)
	$output_folder = "backup/$namespace/$type_name"
	confirm_folder $output_folder

	$scriptblock = {kubectl get $type_name $name  -n $namespace -o=json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' | yq eval . --prettyPrint	}
	Invoke-Command -scriptblock $scriptblock | Out-File "$output_folder\$name.yml"
	
}

function save_type
{
	param (
		[string]$type_name,
		[string]$namespace
		)
	Write-Host "Working on $namespace $type_name"

	$script_block = {
		$list = run_kubectl_get ${type_name}  $namespace
		for($j=0;$j -lt $list.Length; $j++)
		{
			$current_name = $list[$j]
			Write-Host "saving $type_name : $current_name in $namespace "
			save_yaml ${type_name}  $current_name $namespace
		}
	
	}
	Invoke-Command -scriptblock $script_block

}

function save_all_in_namespace
{
	param (
		[string]$namespace = "development"
		)
		# workloads
		save_type "pods" $namespace
		save_type "deployments" $namespace
		save_type "daemonsets" $namespace
		save_type "statefulsets" $namespace
		save_type "replicasets" $namespace
		save_type "jobs" $namespace
		save_type "cronjobs" $namespace

		# config
		save_type "configmaps" $namespace
		save_type "secrets" $namespace

		# network
		save_type "services" $namespace
		save_type "endpoints" $namespace
		save_type "ingress" $namespace
		save_type "networkpolicy" $namespace

		# storage
		save_type "persistentvolumeclaims" $namespace
		save_type "persistentvolume" $namespace

		

}

function save_all
{
	$namespaces = get_namespaces
	for($i=0;$i -lt $namespaces.Length; $i++)
	{
		$namespace = $namespaces[$i]
		save_all_in_namespace $namespace

	}
}


