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

$Groups = @(
    "HR-Users"
    "IT-Admins"
    "Finance-Analysts"
    "Sales-Team"
    "Training-Security"
)
$GroupPath = $OU,$DomainDN

foreach ($Group in $Groups) {
    $ExistingGroup = Get-ADGroup -Filter "Name -eq $Group"
        if ($ExistingGroup -eq $null) {
            New-ADGroup -Name $Group -GroupScope Global -GroupCategory Security -Path $GroupPath
            Write-Host "New Global Security Group has been created with the name: $Group"
        } else {
            Write-Host "The Group already exists: $Group"
        }
}

