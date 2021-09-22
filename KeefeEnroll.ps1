#This Script enrolls the computer into Keefe Tech Domain and Installs files. 

function pause{$null = Read-Host "Wait for Ninite to finish then press Enter to continue..."}

Pause

$domain = "internal.keefetech.org"
$username = Read-Host -Prompt "Enter domain username"
$password = Read-Host -Prompt "Enter password for $username" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
$input = Read-Host -Prompt 'Enter Computer Name'
$hostname = "$input"


add-computer -Credential $credential -DomainName $domain -NewName $hostname -Restart