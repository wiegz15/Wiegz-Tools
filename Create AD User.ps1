#PowerShell script to create AD user

Import-Module ActiveDirectory
$User = Get-ADUser -Identity (Read-Host -Prompt "Enter the username for someone you would like to copy") -Properties *
$oldDisplayName = $user.DisplayName
"Would you like to copy the user: $oldDisplayName ?"
$Continue = Read-Host -Prompt "Continue?  (Y/N)"
If ($Continue -eq "Y"){

$DN = $User.distinguishedName
$OldUser = [ADSI]"LDAP://$DN"
$Parent = $OldUser.Parent
$OU = [ADSI]$Parent
$OUDN = $OU.distinguishedName
$strOUDN = [string]$OUDN
$FirstName = Read-Host -Prompt "Input the First Name of the user you would like to add"
$LastName = Read-Host -Prompt "Input the Last Name of the user you would like to add"
$SAMAccountName = Read-Host -Prompt "Input the Username of the user you would like to add"
#Check if username already exists
$UserCheck = Get-ADUser -Filter {sAMAccountName -eq $SAMAccountName}
If ($UserCheck -ne $Null) {$SAMAccountName = Read-Host -Prompt "Username $SAMAccountName already exists.  Enter a new username or rename the existing user in AD"}
$Password = Read-Host -AsSecureString "Enter the password for this user"
$Phone = Read-Host "Enter a phone number for this account if applicable"
$Title = Read-Host "Enter a Title for this account if applicable"
$Office = $User.office
$Company = $User.company
$DisplayName = $LastName + ", " + $FirstName
$ObjectName = $FirstName + " " + $LastName
$Description = $User.description
$Department = $User.department
$Office = $User.office
$EmailAddress = $UPN
$LogonScript = $User.ScriptPath


#Collect Group Membership
$Groups = $User.memberOf

#Create New User
New-ADUser -Name $ObjectName -AccountPassword $Password -ChangePasswordAtLogon $True -Description $Description -DisplayName $DisplayName -EmailAddress $EmailAddress -Enabled $true -GivenName $FirstName -Path $strOUDN -SamAccountName $SAMAccountName -Surname $LastName -ScriptPath $LogonScript -UserPrincipalName $UPN -OfficePhone $Phone -Office $Office -Company $Company -Title $Title -Department $Department


#Copy Group Membership to new user
foreach ($Group in $Groups){
Add-ADGroupMember -Identity $Group -members $SAMAccountName
}
Get-ADUser -Identity $SAMAccountName

"User added!"
}



