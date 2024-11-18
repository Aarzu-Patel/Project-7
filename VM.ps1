# Variables
$resourceGroupName = "Project-7"
$location = "CanadaCentral"
$vmName = "LinuxVM"
$adminUsername = "aarzupatel"
$password = ConvertTo-SecureString "Password@123456" -AsPlainText -Force
$subnetName = "MySubnet"  # Define the name of the subnet
$vnetName = "MyVNet"      # Define the name of the virtual network

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Virtual Network and Subnet (if they don't already exist)
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName -ErrorAction SilentlyContinue
if (-not $vnet) {
    # Create the Virtual Network
    $vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $vnetName -AddressPrefix "10.0.0.0/16"
    $subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.1.0/24" -VirtualNetwork $vnet
    $vnet | Set-AzVirtualNetwork
} else {
    Write-Host "Virtual network $vnetName already exists."
}

# Get the Subnet ID manually (or use it if known)
$subnetId = (Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName).Subnets | Where-Object {$_.Name -eq $subnetName} | Select-Object -ExpandProperty Id

# Create Public IP Address
$publicIP = New-AzPublicIpAddress -Name "MyPublicIP" -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static

# Create Network Security Group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "MyNSG"

# Create NIC (Manually specifying SubnetId)
$nic = New-AzNetworkInterface -Name "MyNIC" -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnetId -PublicIpAddressId $publicIP.Id -NetworkSecurityGroupId $nsg.Id

# Create VM Configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_DS2"

# Set Operating System
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential (New-Object PSCredential ($adminUsername, $password))

# Set VM Image
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "ubuntu-24_04-lts" -Skus "server-gen1" -Version "latest"

# Add Network Interface to VM Configuration
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Create VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig


#Get-AzVMImage -Location "EastUS" -PublisherName "Canonical" -Offer "ubuntu-24_04-lts" -Skus "server-gen1" -Version "latest"
