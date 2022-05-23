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


$Computername = Get-ADComputer -Filter {operatingsystem -like '*server*'} | select-object -expandproperty name
$StartTime = [datetime]::today
$EndTime = [datetime]::now
        
<# Event Log Levels
    1 = Critical
    2 = Error
    3 = Warning
    4 = Information
    5 = Verbose 
    #>  
$Levels = @('Placeholder-0','Critical','Error', 'Warning', 'Information', 'Verbose')

$EventFilter = @{Logname='System','Application'
                 Level=1,2,3
                 StartTime=$StartTime
                 EndTime=$EndTime
                 }          

foreach($Computer in $Computername){
[void] $listBox.Items.Add("$Computer")
}

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $ServerSelection = $listBox.SelectedItems
    foreach($Server in $ServerSelection) {
    try {

        $Events = Get-WinEvent -ComputerName $Server -Verbose:$false -ErrorAction Stop -FilterHashtable $EventFilter 
    
        $Output = $Events | Select-Object @{n='Computer';e={$Server}}, TimeCreated,LogName, @{n='Level';e={$Levels[$($_.Level)]}}, Message 
        
        #Output to Screen
        $Output | ft

        #Export to File 
        #$Output | Out-File C:\Users\awiegel\WinEvents-$Computer.txt

    } catch {
           
        Write-warning "Error connecting to server: $Server - $($Error[0])"
    }
} 
}