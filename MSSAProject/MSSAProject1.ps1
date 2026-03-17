#Create New Organizational Units
$DomainDN = "DC=Adatum,DC=com"
$OUs = @(
    "HumanResources"
    "IT"
    "Finance"
    "Sales"
    "Training"
    "DisabledUsers"
)
foreach ($OU in $OUs) {
    $ExistingOU =  Get-ADOrganizationalUnit -Filter "Name -eq '$OU'"
        if ($ExistingOU -eq $null) {
            New-ADOrganizationalUnit -Name $OU -Path $DomainDN
            Write-Host "New OU created with the name: $OU" -ForegroundColor Green
        } else {
            Write-Host "OU already exists: $OU" -ForegroundColor Yellow
        }
}

#Create New Groups
$Groups = @(
    @{ Name = "HR-Users"; OU = "HumanResources" }
    @{ Name = "IT-Admins"; OU = "IT" }
    @{ Name = "Finance-Analysts"; OU = "Finance" }
    @{ Name = "Sales-Team"; OU = "Sales" }
    @{ Name = "Training-Security"; OU = "Training" }
)
foreach ($Group in $Groups) {
    $ExistingGroup = Get-ADGroup -Filter "Name -eq '$($Group.Name)'"
    $GroupPath = "OU=$($Group.OU),$DomainDN"
        if ($ExistingGroup -eq $null) {
            New-ADGroup -Name $($Group.Name) -GroupScope Global -GroupCategory Security -Path $GroupPath
            Write-Host "New Global Security Group has been created with the name: $($Group.Name)" -ForegroundColor Green
        } else {
            Write-Host "The Group already exists: $($Group.Name)" -ForegroundColor Yellow
        }
}

#Create Bulk Users
$Users = @(
    @{ Name = "Cole Quinn"; Sam = "cquinn"; OU = "IT"}
    @{ Name = "Christian McGhee"; Sam = "cmcghee"; OU = "IT"}
    @{ Name = "Douglas Binchus"; Sam = "dbinchus"; OU = "IT"}
    @{ Name = "Joshua Frometa"; Sam = "jfrometa"; OU = "IT"}

    @{ Name = "Brandon Perez"; Sam = "bperez"; OU = "HumanResources"}
    @{ Name = "Herby Milfort"; Sam = "hmilfort"; OU = "HumanResources"}
    @{ Name = "Camilo Alvarez"; Sam = "calvarez"; OU = "HumanResources"}
    @{ Name = "David Xiong"; Sam = "dxiong"; OU = "HumanResources"}

    @{ Name = "Edjeame Toyi"; Sam = "etoyi"; OU = "Finance"}
    @{ Name = "Hamdaani Ousmane"; Sam = "housmane"; OU = "Finance"}
    @{ Name = "Jayar Loiselle"; Sam = "jloiselle"; OU = "Finance"}
    @{ Name = "Angela Kelly"; Sam = "akelly"; OU = "Finance"}

    @{ Name = "Jonathan Arroyo"; Sam = "jarroyo"; OU = "Sales"}
    @{ Name = "Scott Harris"; Sam = "sharris"; OU = "Sales"}
    @{ Name = "Brittany Zurilgen"; Sam = "bzurilgen"; OU = "Sales"}
    @{ Name = "Feras Bouti"; Sam = "fbouti"; OU = "Sales"}

    @{ Name = "John Smith"; Sam = "jsmith"; OU = "Training"}
    @{ Name = "Emily Clark"; Sam = "eclark"; OU = "Training"}
    @{ Name = "Sarah Chase"; Sam = "schase"; OU = "Training"}
    @{ Name = "Michael Robinson"; Sam = "mrobinson"; OU = "Training"}
)
foreach ($User in $Users) {
    $UserPath = "OU=$($User.OU),$DomainDN"
    $Password = ConvertTo-SecureString "Pa55w.rd" -AsPlainText -Force
    $UPN = "$($User.Sam)@adatum.com"
    New-ADUser `
    -Name $($User.Name) `
    -SamAccountName $($User.Sam) `
    -UserPrincipalName $UPN `
    -Path $UserPath `
    -AccountPassword $Password `
    -Enabled $true
    Write-Host "New User created: $($User.Name) ($($User.Sam)) in OU $($User.OU)" -ForegroundColor Green
}

#Add Existing Users into Existing Groups
$GroupMap = @{
    "IT" = "IT-Admins"
    "HumanResources" = "HR-Users"
    "Finance" = "Finance-Analysts"
    "Sales" = "Sales-Team"
    "Training" = "Training-Security"
}
foreach ($User in $Users) {
    $GroupName = $GroupMap[$User.OU]
    $ExistingGroup = Get-ADGroup -Filter "Name -eq '$GroupName'"
        if ($ExistingGroup) {
        Add-ADGroupMember -Identity $GroupName -Members $User.Sam
        Write-Host "$($User.Sam) has been added to: $GroupName" -ForegroundColor Green
        } 
        else {
        Write-Host "Could not complete this action." -ForegroundColor Red
    }
}

#Get Disabled Users and Enable Them
$DisabledUsers = Get-ADUser -Filter 'Enabled -eq $false'
foreach ($User in $DisabledUsers) {
    try {
        Enable-ADAccount -Identity $User.SamAccountName
        Write-Host "User Enabled: $($User.SamAccountName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to Enable User: $($User.SamAccountName)" -ForegroundColor Red
    }
}

#Disable user accounts that have that have not been used to logon with in 30 or more days
$Cutoff = (Get-Date).AddDays(-30)
$CutoffFileTime = $Cutoff.ToFileTime()
$InactiveUsers = Get-ADUser -Filter "LastLogonTimeStamp -lt $CutoffFileTime" -Properties LastLogonTimeStamp
foreach ($User in $InactiveUsers) {
        try {
            Disable-ADAccount -Identity $User.SamAccountName
            Write-Host "Disabled user: $($User.SamAccountName)" -ForegroundColor Green
        }
        catch {
        Write-Host "Failed to disable user: $($User.SamAccountName)" -ForegroundColor Red
         }
}

#Disabled User
Disable-ADAccount -Identity "cquinn"

#Move Disabled Users to the DisabledUsers OU
$TargetDisabledOU = "OU=DisabledUsers,DC=adatum,DC=com"
$DisabledUsers2 = Get-ADUser -Filter 'Enabled -eq $false' -Properties DistinguishedName
foreach ($User in $DisabledUsers2) {
    try {
        Move-ADObject -Identity $User.DistinguishedName -TargetPath $TargetDisabledOU
        Write-Host "Moved user: $($User.SamAccountName) to DisabledUsers OU" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to move user: $($User.SamAccountName)" -ForegroundColor Red
    }
}

#Create list of computers with a particular operating system installed
$OS = "Windows Server 2022*"
$Windows2022Computers = Get-ADComputer -Filter "OperatingSystem -like '$OS'" -Properties OperatingSystem
$Windows2022Computers | Select-Object Name,OperatingSystem

#Restart a Computer Remotely
$Computers = @(
    "Server01"
    "Server02"
    "Server03"
)
foreach ($computer in $computers) {
    try { Restart-Computer -ComputerName $Computer -Force
    Write-Host "Successfully Restarted Computer: $Computer" -ForegroundColor Green
    }
    catch { 
        Write-Host "Unable to Restart Computer: $Computer" -ForegroundColor Red
    }
}
