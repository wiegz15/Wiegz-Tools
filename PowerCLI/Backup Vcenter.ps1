Add-Type -AssemblyName System.Windows.Forms

# This script initiates VMware PowerCLI
#. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
#
# Specify vCenter Server, vCenter Server prompts for username and vCenter Server user password

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'vCenter Server'
$msg   = 'Enter your vcenter Server:'
$vCenter= [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
 
# Get backup save path
$backuppath = New-Object System.Windows.Forms.FolderBrowserDialog
[void]$backuppath.ShowDialog()
$backuppath = Get-Location
 
Write-Host "Connecting to vCenter Server $vCenter" -foreground green
Connect-viserver $vCenter -WarningAction 0
 
# Get list of all ESXi hosts known by vCenter
$AllVMHosts =  Get-VMHost
 
ForEach ($VMHost in $AllVMHosts)
{
    Write-Host " "
    Write-Host "Backing Up Host Configuration: $VMHost" -foreground green
    Get-VMHostFirmware -VMHost $VMHost -BackupConfiguration -DestinationPath $backuppath
}
 
Write-Host
Write-Host "Files Saved to: $backuppath";
Write-Host "Use Set-VMHostFirmware to restore"
Write-Host
Write-Host "Press any key to close ..."
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")