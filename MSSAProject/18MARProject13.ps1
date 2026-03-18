#Inventory Shared Folders and Review Permissions
$Shares = Get-SMBShare | Where-Object {$_.ShareType -eq "FileSystemDirectory"}
foreach ($Share in $Shares) {
    Write-Host "Name: $($Share.name)" -ForegroundColor Green
    Write-Host "Path: $($Share.path)" -ForegroundColor Cyan
    Write-Host "Description: $($Share.Description)" -ForegroundColor Magenta
    Write-Host "Permissions:" -ForegroundColor DarkYellow
    $Permissions = Get-SmbShareAccess -Name $Share.name
    foreach ($Permission in $Permissions) {
        Write-Host "$($Permission.AccountName): $($Permission.AccessControlType) ($($Permission.AccessRights))" -ForegroundColor DarkYellow
    }
    Write-Host "====================================================" -ForegroundColor White
}
#This script checks to see what shared folders exist and where they exist, as well
#as the description of what kind of file it is. This also allows Administrators to
#check to see who has permissions within the shared folders, see what their accesses
#are, and what specific access rights they have. In this particular environment, there
#are no access rights applied (indicated by the empty parentheses).