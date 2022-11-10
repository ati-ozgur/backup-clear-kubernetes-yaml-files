
function run_kubectl_get
{
	param (
		[string]$type_name,
		[string]$replacement,
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
		$current = $list[$i]  -replace "$replacement/", ""

		$list[$i] = $current
	}

	Write-Output -NoEnumerate $list
}


function get_pods
{
	param (
		[string]$namespace = ""
		)
	#Write-Output $namespace
	run_kubectl_get "pods" "pod" $namespace
}




function get_namespaces
{
	run_kubectl_get "namespaces" "namespace"

}

function confirm_folder
{
	param (
		[string]$foldername
		)
	$exists = Test-Path -Path $foldername
	if ( $exists -eq $false) {
	   Write-Host "$foldername doesn't exist, creating"
	   New-Item -Path $foldername -ItemType directory
	}
}


function save_yaml
{
	param (
		[string]$type_name,
		[string]$name,
		[string]$namespace = ""
		)
	confirm_folder "backup/$namespace"
	$scriptblock = {kubectl get $type_name $name  -n $namespace -o=json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' | yq eval . --prettyPrint	}
	Invoke-Command -scriptblock $scriptblock | Out-File "$namespace\pod_$name.yml"
	
}

