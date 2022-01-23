$ip = Read-Host -Prompt "Enter the IP Address you want to look up"
ipmo virtualmachinemanager -ErrorAction Stop
$ipaddress = Get-SCIPAddress -IPAddress $ip
$Gateway = Get-SCNetworkGateway | Select-Object -ExpandProperty VMNetworkGateways |Select-Object -ExpandProperty Natconnections | Where-Object {$_.id -eq $ipaddress.AssignedToID}
$VNET = Get-SCVMNetwork | ? {($_ |Select-Object -ExpandProperty Natconnections| ? {$_.Name -eq $Gateway.Name})}
if ($VNET -ne $null) {
    $VmNetwork = Get-SCVMNetwork -Name $VNET
    $VmNetworkGateway = (Get-SCNetworkGateway).VMNetworkGateways | Where-Object { $_.Name -eq $vmNetwork.VMNetworkGateways.Name }
    Write-Host ""
    Write-Host "The owner of ip $ip is " -NoNewline
    Write-Host -ForegroundColor Yellow $VNET.Owner
    Write-Host ""
    Write-Host "The owner has these VMs behind this ip:"
    Get-SCVirtualNetworkAdapter -All | Where-Object {$_.VMNetwork -match "$VNET"} | Select Name, ipv4addresses
    Write-Host ""
    if ($VmNetworkGateway.Natconnections.Rules -ne $null) {
        Write-Host "The owner has these NAT Rules on $ip :"
        $VmNetworkGateway.Natconnections.Rules
        Write-Host ""
    }
    if ($VmNetworkGateway.VPNConnections -ne $null) {
        Write-Host "The owner has these VPN Tunnels on $ip :"
        $VmNetworkGateway.VPNConnections
    }
    Write-Host "Press any key to continue ..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} else {
    Write-Host -ForegroundColor Red "Cannot find any information associated with $ip"
}