# Parameters
param([string] $location = "East US")
$newDeploymentName="AZ204Lab03Deployment"
$resourceGroupName="StorageMedia"
$storageAccountNameSuffix=Get-Random -Maximum 100000000

$ParametersObj = @{
    newDeploymentName = $newDeploymentName
    resourceGroupName = $resourceGroupName
    location = $location
    storageAccountNameSuffix = "$storageAccountNameSuffix"
}

$storageAccountName="mediastor"+$storageAccountNameSuffix

# Deployment
New-AzDeployment -Location $location -TemplateFile 'template-lab03.json' -TemplateParameterObject $ParametersObj

# Retrieve Storage Account key
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName) | Where-Object {$_.KeyName -eq "key1"}

# Get Storage Account Context
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey.value

# Upload images
Set-AzStorageBlobContent -Context $context -Container "raster-graphics" -File "images/graph.jpg" -Blob "graph.jpg" -Properties @{"ContentType" = "image/jpeg"}
Set-AzStorageBlobContent -Context $context -Container "vector-graphics" -File "images/graph.svg" -Blob "graph.svg" -Properties @{"ContentType" = "image/svg+xml"}

# Update BlobManager program
$blobServiceEndpoint = "https://" + $storageAccountName + ".blob.core.windows.net"
((Get-Content -path BlobManager/Program.cs -Raw) -replace '<primary-blob-service-endpoint>',$blobServiceEndpoint) | Set-Content -Path BlobManager/Program.cs
((Get-Content -path BlobManager/Program.cs -Raw) -replace '<storage-account-name>',$storageAccountName) | Set-Content -Path BlobManager/Program.cs
((Get-Content -path BlobManager/Program.cs -Raw) -replace '<key>',$storageAccountKey.value) | Set-Content -Path BlobManager/Program.cs
