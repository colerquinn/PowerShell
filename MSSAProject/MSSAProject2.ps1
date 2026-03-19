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
$Computer = Read-Host "Enter the Remote Computer Name"
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
$Computer = Read-Host "Enter the Remote Computer Name"
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

#Create a Network Share
$FolderPath = "C:\ColesMSSAData"
$ShareName = "MSSAShare1"
if (-not(Test-Path $FolderPath)) {
    New-Item -Path $FolderPath -ItemType Directory
    Write-Host "Successfully created new directory at: $FolderPath" -ForegroundColor Green
} 
else {
    Write-Host "Folder Already Exists: $Folderpath" -ForegroundColor DarkYellow
}
if (-not(Get-SMBShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    New-SmbShare `
        -Name $ShareName `
        -Path $FolderPath `
        -FullAccess "Administrators" `
        -ReadAccess "Everyone"

    Write-Host "'$ShareName' has been created on the network." -ForegroundColor Green
}
else {
    Write-Host "The Share '$ShareName' is already in use." -ForegroundColor DarkYellow
}

#Stop and start process on remote host
$Computer = Read-Host "Enter the Remote Computer Name"
$ProcessName = Read-Host "Enter the Process Name"

Invoke-Command -ComputerName $Computer -ScriptBlock {
    $CurrentProcess = Get-Process -Name $using:ProcessName -ErrorAction SilentlyContinue

    if ($CurrentProcess) {
        Write-Host "Stopping Process..." -ForegroundColor DarkYellow
        Stop-Process -Name $using:ProcessName -Force

        Start-Sleep -Seconds 1

        Write-Host "Starting Process..." -ForegroundColor DarkYellow
        Start-Process $using:ProcessName

        Write-host "Process $Using:ProcessName successfully started!" -ForegroundColor Green
    } else {
        Write-Host "Process $Using:ProcessName not found running this device" -ForegroundColor Red
    }
}

#Stop and start service on remote host
$Computer = Read-Host "Enter the Remote Computer Name"
$ServiceName = Read-Host "Enter the Service Name"

Invoke-Command -ComputerName $Computer -ScriptBlock {
    $CurrentService = Get-Service -Name $using:ServiceName -ErrorAction SilentlyContinue

    if ($CurrentService) {
        Write-Host "Stopping Service..." -ForegroundColor DarkYellow
        Stop-Service -Name $using:ServiceName -Force

        Start-Sleep -Seconds 1

        Write-Host "Starting Service..." -ForegroundColor DarkYellow
        Start-Service $using:ServiceName

        Write-host "Service $Using:ServiceName successfully restarted!" -ForegroundColor Green
    } else {
        Write-Host "Service $Using:ServiceName not found running this device" -ForegroundColor Red
    }
}

