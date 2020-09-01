# Parameters
$newDeploymentName="AZ204Lab03Deployment"
$resourceGroupName="StorageMedia"
$location="East US"
$storageAccountNameSuffix="az204lab03" # to be updated (yourname)

$ParametersObj = @{
    newDeploymentName = $newDeploymentName
    resourceGroupName = $resourceGroupName
    location = $location
    storageAccountNameSuffix = $storageAccountNameSuffix
}

$storageAccountName="mediastor"+$storageAccountNameSuffix

# Deployment
New-AzDeployment -Location $location -TemplateFile 'template-lab03.json' -TemplateParameterObject $ParametersObj

# Retrieve Storage Account key
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName) | Where-Object {$_.KeyName -eq "key1"}

# Get Storage Account Context
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey.value

# Upload blobs
Set-AzStorageBlobContent -Context $context -Container "raster-graphics" -File "images/graph.jpg" -Blob "graph.jpg" -Properties @{"ContentType" = "image/jpeg"}
Set-AzStorageBlobContent -Context $context -Container "vector-graphics" -File "images/graph.svg" -Blob "graph.svg" -Properties @{"ContentType" = "image/svg+xml"}
