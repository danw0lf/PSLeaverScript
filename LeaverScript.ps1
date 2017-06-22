#Prerequisites
Import-Module ActiveDirectory
Add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010
$PSEmailServer = "Exchange Server"

$choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Y","&N")
while ( $true ) {

# User Input Parameters
$UserName = Read-Host -Prompt 'Enter username to disable'

#Script Input Parameters
$ADGroups = Get-ADPrincipalGroupMembership -Identity $UserName | where {$_.Name -ne "Domain Users"}
$Date = Get-Date -format d
$DisplayName=(Get-Aduser $username -Properties cn).cn
$ManagerEmail=(Get-AdUser (Get-aduser $UserName -properties manager).manager -properties emailaddress).EmailAddress
$ManagerName=(Get-AdUser (Get-aduser $UserName -properties manager).manager -properties cn).cn

#Script
#Pre-Disable - Gets AD Groups and Exports them to IT Dept\User Admin\Leavers
#Amends the description of the user to the date and who disabled the account
(Get-ADUser $UserName –Properties MemberOf).memberof |
	Get-ADGroup | Select-Object name |
	Out-File "\\ctcmain\I\CTC Aviation Group plc\IT Dept\User Admin\Leavers\$($UserName).txt" -width 120 -Append
Set-ADUser $UserName -Description "Disabled on $Date by $env:UserName"

#Remove Groups, Disable, Hide from GAL, Move to Disabled OU
Remove-ADPrincipalGroupMembership -ErrorAction SilentlyContinue -Identity $UserName -MemberOf $ADGroups -Confirm:$false
Disable-ADAccount -Identity $UserName
Set-Mailbox -Identity domain\$UserName -HiddenFromAddressListsEnabled $true
Get-ADUser $UserName | Move-ADObject -TargetPath 'OU=Users,OU=Disabled Objects,DC=local,DC=Domain'

#Send email to their Line Manager - be warned sidescrolling
Send-MailMessage -From "email" -Cc "email" -To "$ManagerEmail" -Subject "User Disabled - $AccountName" -Body "Hi $ManagerName,

This is to inform you that $DisplayName has been successfully disabled. After 30 days we will fully delete their mailbox, documents and profile. Please make us aware during this time if you need access to any of their files.

Kind regards,"

#Prompt for Completion
Write-Host 'The user has been terminated, disable their door access, and email their Line Manager'

#Prompt to Repeat for another user?
$choice = $Host.UI.PromptForChoice("Disable another user?","",$choices,0)
  if ( $choice -ne 0 ) {
    break
  }
}
