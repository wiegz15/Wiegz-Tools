$names = Get-content "\Location\Of\CSV\List"

foreach ($name in $names){
if (Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue){
    Write-Host "$name,up"|
    Export-CSV "C:\Users\admin.awiegel\Desktop\UP.csv" -append
}
else{
    Write-Host "$name,down"|
    Export-CSV "\Location\To\Save" -append
}
}