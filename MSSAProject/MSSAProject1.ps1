#Create New Organizational Units
$DomainDN = "DC=Adatum,DC=com"
$OUs = @(
    "HumanResources"
    "IT"
    "Finance"
    "Sales"
    "Training"
)
foreach ($OU in $OUs) {
    $ExistingOU =  Get-ADOrganizationalUnit -Filter "Name -eq '$OU'"
        if ($ExistingOU -eq $null) {
            New-ADOrganizationalUnit -Name $OU -Path $DomainDN
            Write-Host "New OU created with the name: $OU"
        } else {
            Write-Host "OU already exists: $OU"
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
            Write-Host "New Global Security Group has been created with the name: $($Group.Name)"
        } else {
            Write-Host "The Group already exists: $($Group.Name)"
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
    Write-Host "New User created: $($User.Name) ($($User.Sam)) in OU $($User.OU)"
}
#Add Existing Users into Existing Groups
$GroupMap = @{
    "IT" = "IT-Admins"
    "HumanResources" = "HR-Users"
    "Finance" = "Finance-Analysts"
    "Sales" = "Sales-Team"
    "Training" = "Training-Security"
}
ForEach ($User in $Users) {
    $GroupName = $GroupMap[$User.OU]
    $ExistingGroup = Get-ADGroup -Filter "Name -eq '$GroupName'"
        if ($ExistingGroup) {
        Add-ADGroupMember -Identity $GroupName -Members $User.Sam
        Write-Host "$($User.Sam) has been added to: $GroupName"
        } 
        else {
        Write-Host "Could not complete this action." -ForegroundColor Red
    }
}
#Get Disabled Users and Enable Them
$DisabledUsers = Get-ADUser -Filter 'Enabled -eq $false'
ForEach ($User in $DisabledUsers) {
    try {
        Enable-ADAccount -Identity $User.SamAccountName
        Write-Host "User Enabled: $($User.SamAccountName)"
    }
    catch {
        Write-Host "Failed to Enable User: $($User.SamAccountName)"
    }
}
