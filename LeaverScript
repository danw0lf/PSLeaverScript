$choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Y","&N")
while ( $true ) {

#Prerequisites
Import-Module ActiveDirectory
Add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010

# User Input Parameters
$AccountName = Read-Host -Prompt 'Enter account name to disable'

#Script Input Parameters
$ADGroups = Get-ADPrincipalGroupMembership -Identity $accountName | where {$_.Name -ne "Domain Users"}
$Date = Get-Date -format d

#Script
#Pre-Disable - Gets AD Groups and Exports them to \\Path\ then amends the description of the user to the date and who disabled the account
(Get-ADUser $AccountName –Properties MemberOf).memberof | Get-ADGroup | Select-Object name | Out-File "\\Path\$($accountName).txt" -width 120 -Append
Set-ADUser $AccountName -Description "Disabled on $Date by $env:UserName"

#Remove Groups, Disable, Hide from GAL, Move to Disabled OU
Remove-ADPrincipalGroupMembership -ErrorAction SilentlyContinue -Identity $accountName -MemberOf $ADGroups -Confirm:$false
Disable-ADAccount -Identity $AccountName
Set-Mailbox -Identity Domain\$AccountName -HiddenFromAddressListsEnabled $true
Get-ADUser $AccountName | Move-ADObject -TargetPath 'OU=Users,OU=Disabled Objects,DC=local,DC=Domain'

#Prompt for Completion
Write-Host 'The account has been terminated, disable their door access, and email their Line Manager'

#Prompt to Repeat for another user?
$choice = $Host.UI.PromptForChoice("Disable another user?","",$choices,0)
  if ( $choice -ne 0 ) {
    break
  }
}
