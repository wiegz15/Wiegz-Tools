$DaysInactive = 60
$time = (Get-Date).Adddays(-($DaysInactive))

Get-ADComputer -ResultPageSize 10000 -Property Name,lastLogon -Filter {lastLogon -lt $time -and Name -like "ADM*"} |      
            
foreach{
        if(Test-Connection $_.name -Count 1 -ErrorAction SilentlyContinue){

            Write-Output "Successfully Pinged $($_.name)" 
            Get-ADComputer -ResultPageSize 10000 -Property Name,lastLogon, DistinguishedName, whenCreated -Filter {lastLogon -lt $time -and Name -like "ADM*"} |
            Select-Object Name,OperatingSystem ,@{N='lastlogon'; E={[DateTime]::FromFileTime($_.lastlogon)}}, whenCreated |
            Export-CSV "C:\Users\admin.awiegel\Desktop\Up.csv" -append
        }else{

            Write-Output "No Ping Response $($_.name)"    

            Get-ADComputer -ResultPageSize 10000 -Property Name,lastLogonDate, DistinguishedName, whenCreated -Filter {lastLogon -lt $time -and Name -like "ADM*"} |
            Select-Object Name,@{N='lastlogon'; E={[DateTime]::FromFileTime($_.lastlogon)}}, whenCreated |
            Export-CSV "C:\Users\admin.awiegel\Desktop\Down.csv" -append
        }
} 
