param (
    [Parameter(Mandatory = $true, HelpMessage = "Please specify the target environment.")]
    [ValidateSet('demo', 'dev', 'uat', 'prod', IgnoreCase = $true)]
    [string]$DeployEnv,
	
	[Parameter(Mandatory = $true, HelpMessage = "Please specify the target group (1 or 2).")]
    [ValidateSet(1, 2)]
    [int]$Group
)

$environments = @{
    demo  = @{ 
		account_id = "334044477312";  
		profile = "iamadmin";  
	}
    dev  = @{ 
		account_id = "344626517534";  
		profile = "dev-iamadmin";  
	}
    uat  = @{ 
		account_id = "619924817113";  
		profile = "uat-iamadmin";  
	}
	prod  = @{ 
		account_id = "136609826199";  
		profile = "prod-iamadmin";  
	}
}

if ($environments.ContainsKey($DeployEnv)) {
    # Extract the map for the matching environment
    $config = $environments[$DeployEnv]

    # Assign values to individual variables
    $account_id = $config.account_id
    $profile = $config.profile
	
	echo "AWS account: ${account_id}"
	echo "Local profile: ${profile}"
}

$targetDir = "C:\Users\arthas\VSCode\WorkoutPlanner\workout"
Set-Location -Path $targetDir

# build local file
./gradlew clean build -x test
docker build --platform linux/amd64 -t mwp-service-workout:latest .

# push docker image to ECR
docker tag mwp-service-workout:latest "${account_id}.dkr.ecr.ap-east-1.amazonaws.com/mwp-service-workout:latest"
aws ecr get-login-password --region ap-east-1 --profile ${profile} | docker login --username AWS --password-stdin "${account_id}.dkr.ecr.ap-east-1.amazonaws.com"
docker push "${account_id}.dkr.ecr.ap-east-1.amazonaws.com/mwp-service-workout:latest"

# prepare taskdef.json
$rawJson = aws ecs describe-task-definition --task-definition "mwp-service-workout-task" --output json --profile ${profile}
$taskDef = $rawJson | ConvertFrom-Json
$cleanTaskDef = $taskDef.taskDefinition
$cleanTaskDef.PSObject.Properties.Remove('taskDefinitionArn')
$cleanTaskDef.PSObject.Properties.Remove('revision')
$cleanTaskDef.PSObject.Properties.Remove('status')
$cleanTaskDef.PSObject.Properties.Remove('requiresAttributes')
$cleanTaskDef.PSObject.Properties.Remove('compatibilities')
$cleanTaskDef.PSObject.Properties.Remove('registeredAt')
$cleanTaskDef.PSObject.Properties.Remove('registeredBy')
$cleanTaskDef | ConvertTo-Json -Depth 100 | Out-File -FilePath .\taskdef.json -Encoding utf8
$content = Get-Content .\taskdef.json -Raw
$absolutePath = Resolve-Path .\taskdef.json
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($absolutePath, $content, $utf8NoBom)

# register new task definition in ECS
$newAndActiveArn = aws ecs register-task-definition --cli-input-json file://taskdef.json --query "taskDefinition.taskDefinitionArn" --output text --profile ${profile}

# update appspec.yml with new task definition ARN
$appspecTemplate = Get-Content .\appspec_template.yml -Raw
$updatedAppspecContent = $appspecTemplate -replace '<TASK_DEFINITION_ARN>', $newAndActiveArn
$updatedAppspecContent | Set-Content .\appspec.yml -Encoding utf8

# prepare deployment revision for CodeDeploy
$appspecRaw = Get-Content .\appspec.yml -Raw
$escapedAppspec = $appspecRaw -replace '\\', '\\' -replace '"', '\"' -replace "`r`n", '\n' -replace "`n", '\n'
$payloadJson = '{"revisionType": "String", "string": {"content": "' + $escapedAppspec + '"}}'
[System.IO.File]::WriteAllText("$(Get-Location)\deploy-revision.json", $payloadJson, (New-Object System.Text.UTF8Encoding($false)))

# trigger deployment
aws deploy create-deployment --application-name mwp-service-workout-app --deployment-group-name "mwp-service-workout-env${Group}-dg" --revision file://deploy-revision.json --profile ${profile}