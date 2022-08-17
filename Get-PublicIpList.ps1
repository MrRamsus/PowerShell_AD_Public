<#
.SYNOPSIS
	Obtain PublicIP from a Server List.
.DESCRIPTION
	With this script, you can obtain the PublicIP from a CSV list.
.PARAMETER message
    CSVPath = The complete path (and file name and extension) of the CSV file
    $CSVOutPath = The location where this script will export the list (Servername with Public IP)
    
    ====CSV File====
    The CSV file for the input server list, needs the following header:
    Name
    ================
    
.EXAMPLE
	PS> ./Get-PublicIpList.ps1
.LINK
	https://github.com/MrRamsus/PowerShell_AD_Public/blob/main/Get-PublicIpList.ps1
.NOTES
	Author: MrRamsus
#>

Function ImportCSV{
    param (
            [string]$CSVPath = $(Write-Host "CSV Path: " -ForegroundColor Green -NoNewline; Read-Host)
        )
    try {
        $script:ServerList = Import-CSV -Path $CSVPath -ErrorAction Stop
    }
    catch {
        Write-Host "Importing the CSV file has failed. Please try again!" -ForegroundColor Red
        ImportCSV
    }
        
}

Function ObtainPublicIP{
    param (
            $ServerList
    )
    ForEach($Server in $ServerList.Name){        
        try {
            $Status = Invoke-Command -ComputerName $ServerName -ScriptBlock { 
                $GetHostname = $Env:ComputerName
                $PubIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
                Return $GetHostname, $PubIP
            } -ErrorAction Stop
            $script:ListPubIP += @($Status[0]+";"+$Status[1])
        }
        catch {
            Write-Host "$Server is not responding for RemotePowershell." -ForegroundColor Red
            $script:ListPubIP += $Server+";No_WinRM"
        }
        
    }
}

Function ExportToCSV{
    param (
        $InputObject,
        [string]$CSVOutPath = $(Write-Host "Location to export the CSV: " -ForegroundColor Green -NoNewline; Read-Host)
    )
    try {
        Out-File -FilePath $CSVOutPath -InputObject $InputObject -Encoding ASCII -Width 50 -ErrorAction Stop
    }
    catch {
        Write-Host "Output file has not been created." -ForegroundColor Yellow
    }
    
}

#Execution:
ImportCSV
ObtainPublicIP -ServerList $ServerList
ExportToCSV -InputObject $ListPubIP
