Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
$form.Size = New-Object System.Drawing.Size(500,500)
$form.StartPosition = 'CenterScreen'

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,410)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(155,410)
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
$listBox.Location = New-Object System.Drawing.Point(10,60)
$listBox.Size = New-Object System.Drawing.Size(400,500)
$listBox.SelectionMode = 'MultiExtended'
$listBox.Height = 350
$form.Controls.Add($listBox)
$form.Topmost = $true

$dialog = New-Object System.Windows.Forms.SaveFileDialog
$dialog.filter = "CSV (*.csv)| *.csv"


$LogName = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'

$Results = @()

$Computernames = @(Get-ADComputer -Filter {operatingsystem -like '*windows server*'} | select-object -expandproperty name)
$listBox.DataSource = $Computernames
$textBox.Add_TextChanged({
		
	$listBox.DataSource = (($Computernames | ? { $_ -like "*$($textBox.Text)*" }))
	
	
})

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $dialog.ShowDialog()
    $ComputerSelections = $listBox.SelectedItems
    foreach($ComputerSelection in $ComputerSelections) {
    
        $updates =@()
        $updates = Get-WUList �ComputerName $ComputerSelection
        $updates | Select ComputerName, KB, Size, Title, Status, IsDownloaded, IsHidden, IsInstalled, IsMandatory, RebootRequired, IsPresent| export-csv -Path $dialog.FileName -Append

}

}