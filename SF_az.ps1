Connect-AzAccount

Get-AzServiceFabricCluster -ResourceGroupName 'a-wenyiSFBronze' -ClusterName 'wenyisfbronze'

Update-AzServiceFabricDurability -ResourceGroupName 'a-wenyiSFBronze' -Name 'wenyisfbronze' -DurabilityLevel Silver -NodeType Type806

Update-AzServiceFabricReliability -ResourceGroupName 'a-wenyiSFBronze' -Name 'wenyisfbronze' -ReliabilityLevel Silver

# =======================================================================================================================================================================================

# Add an application certificate to a Service Fabric cluster
Connect-AzAccount

# 1.Create a cert
$VaultName = "WenyiSFKeyVault"
$CertName = "mytestcert"
$SubjectName = "CN=mytestcert"

$policy = New-AzKeyVaultCertificatePolicy -SubjectName $SubjectName -IssuerName Self -ValidityInMonths 12
Add-AzKeyVaultCertificate -VaultName $VaultName -Name $CertName -CertificatePolicy $policy




# 2.Update virtual machine scale sets profile with certificate

$ResourceGroupName = "a-wenyiSFBronze"
$VMSSName = "Type806"
$CertStore = "My" # Update this with the store you want your certificate placed in, this is LocalMachine\My

# If you have added your certificate to the keyvault certificates, use
$CertConfig = New-AzVmssVaultCertificateConfig -CertificateUrl (Get-AzKeyVaultCertificate -VaultName $VaultName -Name $CertName).SecretId -CertificateStore $CertStore

# Otherwise, if you have added your certificate to the keyvault secrets, use
$CertConfig = New-AzVmssVaultCertificateConfig -CertificateUrl (Get-AzKeyVaultSecret -VaultName $VaultName -Name $CertName).Id -CertificateStore $CertStore

$VMSS = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMSSName

# If this KeyVault is already known by the virtual machine scale set, for example if the cluster certificate is deployed from this keyvault, use
$VMSS.virtualmachineprofile.osProfile.secrets[0].vaultCertificates.Add($CertConfig)

# Otherwise use
$VMSS = Add-AzVmssSecret -VirtualMachineScaleSet $VMSS -SourceVaultId (Get-AzKeyVault -VaultName $VaultName).ResourceId  -VaultCertificate $CertConfig



# 3. Update the virtual machine scale set

Update-AzVmss -ResourceGroupName $ResourceGroupName -VirtualMachineScaleSet $VMSS -VMScaleSetName $VMSSName


# =======================================================================================================================================================================================


# Deploy a Service Fabric cluster

# 1. sign in to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId 4f27bec7-26bd-40f7-af24-5962a53d921e


# 2. Use a pointer to a secret uploaded into a key vault
Set-AzKeyVaultAccessPolicy -VaultName 'WenyiSFKeyVault' -EnabledForDeployment

$resourceGroupName="a-testsf"
$parameterFilePath="C:\Users\wenyis\SF\sample2\parameters.json"
$templateFilePath="C:\Users\wenyis\SF\sample2\template.json"
$secretID="https://wenyisfkeyvault.vault.azure.net/secrets/mytestcert/5a0bacc178164071b7c486eca3166b3a"

# 3. deploy the cluster
New-AzServiceFabricCluster -ResourceGroupName $resourceGroupName -SecretIdentifier $secretID -TemplateFile $templateFilePath -ParameterFile $parameterFilePath



# =======================================================================================================================================================================================

# Add a secondary cert

# 1. sign in to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId 4f27bec7-26bd-40f7-af24-5962a53d921e


# 2. Test the template prior to deploying it

$resourceGroupName="a-testsf"
$parameterFilePath="C:\Users\wenyis\SF\sample3\parameters.json"
$templateFilePath="C:\Users\wenyis\SF\sample3\template.json"
$clusterName="wenyisf"


Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parameterFilePath

# 3. Update the cluster
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateParameterFile $parameterFilePath -TemplateUri $templateFilePath -clusterName $clusterName



# =======================================================================================================================================================================================


# Add a secondary cert

# 1. sign in to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId 4f27bec7-26bd-40f7-af24-5962a53d921e


# 2. Test the template prior to deploying it

$resourceGroupName="a-testsf"
$parameterFilePath="C:\Users\wenyis\SF\sample3\parameters.json"
$templateFilePath="C:\Users\wenyis\SF\sample3\template.json"
$clusterName="wenyisf"


Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parameterFilePath

# 3. Update the cluster
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateParameterFile $parameterFilePath -TemplateUri $templateFilePath -clusterName $clusterName


# =======================================================================================================================================================================================














































