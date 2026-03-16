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
    @{ Name = "HR-Users"; OU = "HumanResources" }
    @{ Name = "IT-Admins"; OU = "IT" }
    @{ Name = "Finance-Analysts"; OU = "Finance" }
    @{ Name = "Sales-Team"; OU = "Sales" }
    @{ Name = "Training-Security"; OU = "Training" }
)

foreach ($Group in $Groups) {
    $ExistingGroup = Get-ADGroup -Filter "Name -eq $Group"
    $GroupPath = "OU=$($Group.OU),$DomainDN"
        if ($ExistingGroup -eq $null) {
            New-ADGroup -Name $Group -GroupScope Global -GroupCategory Security -Path $GroupPath
            Write-Host "New Global Security Group has been created with the name: $Group"
        } else {
            Write-Host "The Group already exists: $Group"
        }
}
