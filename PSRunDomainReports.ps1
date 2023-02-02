$scriptsList =
@(
'C:\temp\Get-NestedGroupsSearch.ps1'
'C:\temp\Get-ADMembersSearch.ps1'
'C:\temp\Get-DomainHotfixInstalledSearch.ps1'
'C:\temp\Get-SoftwareInstalledSearch.ps1'
)

foreach($script in $scriptsList)
{
Start-Process -FilePath "$PSHOME\powershell.exe" -ArgumentList "-command '& $script'" -Wait
} 
