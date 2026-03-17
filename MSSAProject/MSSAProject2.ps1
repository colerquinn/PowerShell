#List Ip Address for a Remote Host
$Computer = Read-Host "Enter the Remote Computer Name"
try {
    $IPInformation = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration `
    -Filter "IPEnabled = TRUE" -ComputerName $Computer -ErrorAction Stop
    Write-Host "IP Addresses for $Computer :" -ForegroundColor Green $IPInformation.IPAddress
}
catch {
    Write-Host "Unable to retrive IP Information for $computer" -ForegroundColor Red
}

#Retrieve Network Adapter Properties for Remote Computers
try {
    $Adapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration`
    -Filter "IPEnabled = TRUE" -ComputerName $Computer -ErrorAction Stop

    Write-Host "Network Adapter Properties for $Computer :" -ForegroundColor Cyan
    $Adapters | Select-Object `
                Description,
                MACAddress,
                IPAddress,
                IPSubnet,
                DefaultIPGateway,
                DNSServerSearchOrder,
                DHCPEnabled
    }
    catch {
        Write-Host "Unable to retrieve network adapter information for $Computer" -ForegroundColor Red
}

#Release and Renew DHCP Leases on Adapters
try { 
    $Adapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration`
    -Filter "IPEnabled = TRUE AND DHCPEnabled = TRUE"`
    -ComputerName $Computer -ErrorAction Stop

    Write-Host "Releasing and Renewing DHCP Leases on $Computer . . ." -ForegroundColor Yellow

        foreach ($Adapter in $Adapters) {
            $Adapter.ReleaseDHCPLease()
            Start-Sleep -Seconds 2
            $Adapter.RenewDHCPLease()
        }
    }
    catch {
        Write-Host "Action Failed on $Computer" -ForegroundColor Red
}

#