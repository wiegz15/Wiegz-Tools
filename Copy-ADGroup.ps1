#PowerShell script to create AD user

Import-Module ActiveDirectory
$User = Get-ADUser -Identity (Read-Host -Prompt "Enter the username for someone you would like to copy") -Properties *
$oldDisplayName = $user.DisplayName

#Collect Group Membership
$Groups = $User.memberOf

#Enter User to to get copied groups
$GroupUser = Get-ADUser -Identity (Read-Host -Prompt "Enter the username of someone who is getting the copied groups") -Properties *

$CopyUser = $GroupUser.DisplayName

"Would you like to copyer the groups of $oldDisplayName to $CopyUser?"
$Continue = Read-Host -Prompt "Continue?  (Y/N)"
If ($Continue -eq "Y"){
#Copy Group Membership to new user
foreach ($Group in $Groups){
Add-ADGroupMember -Identity $Group -members $GroupUser
}
Get-ADUser -Identity $GroupUser
$Output = $GroupUser.memberOf
"Groups Copied to $CopyUser!"
$Output | ft

}



