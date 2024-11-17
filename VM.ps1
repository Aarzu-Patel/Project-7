# Variables
$resourceGroupName = "Project-7"
$location = "EastUS"
$vmName = "LinuxVM"
$adminUsername = "aarzupatel"
$password = ConvertTo-SecureString "Password@123456" -AsPlainText -Force

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Virtual Network and Subnet
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "MyVNet" -AddressPrefix "10.0.0.0/16"
$subnet = Add-AzVirtualNetworkSubnetConfig -Name "MySubnet" -AddressPrefix "10.0.1.0/24" -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Create Public IP Address
$publicIP = New-AzPublicIpAddress -Name "MyPublicIP" -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static

# Create Network Security Group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "MyNSG"

# Create NIC
$nic = New-AzNetworkInterface -Name "MyNIC" -ResourceGroupName $resourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIP.Id -NetworkSecurityGroupId $nsg.Id

# Create VM Configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_DC1ds_v3" |
    Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential (New-Object PSCredential ($adminUsername, $password)) |
    Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "20_04-lts" -Version "latest" |
    Add-AzVMNetworkInterface -Id $nic.Id

# Create VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

