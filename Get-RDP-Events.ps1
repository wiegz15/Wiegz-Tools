Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please make a selection from the list below:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)

$listBox.SelectionMode = 'MultiExtended'

$listBox.Height = 70
$form.Controls.Add($listBox)
$form.Topmost = $true


$LogName = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'

$Results = @()

$Computername = Get-ADComputer -Filter {operatingsystem -like '*server*'} | select-object -expandproperty name

foreach($Computer in $Computername){
[void] $listBox.Items.Add("$Computer")
}

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $ServerSelection = $listBox.SelectedItems
    foreach($Server in $ServerSelection) {
    try {
        $Events = Get-WinEvent -ComputerName $Server -Verbose:$false -ErrorAction Stop -LogName $LogName
        foreach ($Event in $Events) {
                $EventXml = [xml]$Event.ToXML()
                $ResultHash = @{
                Time = $Event.TimeCreated.ToString()
                'Event ID' = $Event.Id
                'Desc' = ($Event.Message -split "`n")[0]
                Username = $EventXml.Event.UserData.EventXML.User
                'Source IP' = $EventXml.Event.UserData.EventXML.Address
                'Details' = $Event.Message
                }
                $Results += (New-Object PSObject -Property $ResultHash)
}
$Results | Export-Csv "Remote Desktop Users $Server.csv"

    } catch {

        Write-warning "Error connecting to server: $Server - $($Error[0])"
    }
} 
}