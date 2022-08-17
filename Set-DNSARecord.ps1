<#
.SYNOPSIS
	Set and change a single or multiple DNS A-records
.DESCRIPTION
	This PowerShell script can create and change a single or multiple DNS A-record. No changes of this script is needed.
.PARAMETER message
    DNSServerName = the DNS Server host
    HostName = The record of the DNS name you will add/change
    ZoneName = The name of the zone inside the DNS server
    IPv4Address = The common IPv4 Address you will add
    CSVPath = The complete path (and file name and extension) of the CSV file
    Delimiter = The delimiter of the CSV file
    
    ====CSV File====
    CSV File needs to be have the following header (or other delimiter)
    ================
    DNSServerName;Hostname;ZoneName;IPv4Address
    
.EXAMPLE
	PS> ./Set-DNSARecord.ps1
.LINK
	https://github.com/MrRamsus/PowerShell_AD_Public/blob/main/Set-DNSARecord.ps1
.NOTES
	Author: MrRamsus
#>

function Set-DNSRecord {
    param (
        $DNSServerName,
        $HostName,
        $ZoneName,
        $IPv4Address
    )
    
    $CheckRecord = get-DnsServerResourceRecord -ComputerName $DNSServerName -Name $Hostname -ZoneName $ZoneName -ErrorAction SilentlyContinue 
    If($CheckRecord){
        try {
            $NewRecord = [ciminstance]::new($CheckRecord)
            $NewRecord.RecordData.ipv4address = [System.Net.IPAddress]::parse($IPv4Address)
            Set-DnsServerResourceRecord -ComputerName $DNSServerName -NewInputObject $NewRecord -OldInputObject $CheckRecord -ZoneName $ZoneName -PassThru -ErrorAction Stop | Out-Null
            Write-Host "$Hostname ($IPv4Address) has been updated in the zone: $ZoneName" -ForegroundColor Yellow -BackgroundColor DarkGreen
        }
        catch {
            Write-Host "$Hostname ($IPv4Address) can't be updated in the zone: $ZoneName" -ForegroundColor Yellow -BackgroundColor Red
        }
    }
    else{
        try {
            Add-DnsServerResourceRecordA -ComputerName $DNSServerName -Name $Hostname -ZoneName $ZoneName -IPv4Address $IPv4Address -AllowUpdateAny -ErrorAction Stop | Out-Null
            Write-Host "$Hostname ($IPv4Address) has been added to the zone: $ZoneName" -ForegroundColor Green
        }
        catch {
            Write-Host "$Hostname ($IPv4Address) can't be added to the zone: $ZoneName" -ForegroundColor White -BackgroundColor Red
        }
    }
}

Function Single{
     param(
            [string]$DNSServerName = $(Write-Host "DNS Server Name: " -ForegroundColor Green -NoNewline; Read-Host),
            [string]$HostName = $(Write-Host "Hostname to add to DNS: " -ForegroundColor Green -NoNewline; Read-Host),
            [string]$ZoneName = $(Write-Host "DNS Zone Name: " -ForegroundColor Green -NoNewLine; Read-Host),
            [string]$IPv4Address = $(Write-Host "IPv4 Address of the hostname to add to DNS: " -ForegroundColor Green -NoNewLine; Read-Host)
        )

    $title    = 'Confirm'
    $question = "Can you confirm that the following values will be used? `r DNSServerName: $DNSServerName `r Hostname: $Hostname `r ZoneName: $ZoneName `r IPv4: $Ipv4Address"
    $choices  = '&Yes', '&No'
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
   if ($decision -eq 0) {
        Write-Host 'Your record will be created/update.'
        Set-DNSRecord -DNSServerName $DNSServerName -HostName $HostName -ZoneName $ZoneName -IPv4Address $IPv4Address
    }
    elseif($decision -eq 1){
            cls
            Write-Host "Your choice is 'No'. Please fill the correct values"
            Single
    }
}

Function CSV{
    param (
            [string]$CSVPath = $(Write-Host "CSV Path: " -ForegroundColor Green -NoNewline; Read-Host),
            [string]$Delimiter = $(Write-Host "Delimiter value: " -ForegroundColor Green -NoNewline; Read-Host)
        )

    $DNSHostList = Import-CSV -Path $CSVPath -Delimiter $Delimiter 
    ForEach($DNSHost in $DNSHostList){
        Set-DNSRecord -DNSServerName $DNSHost.DNSServerName -HostName $DNSHost.HostName -ZoneName $DNSHost.ZoneName -IPv4Address $DNSHost.IPv4Address
    }     
}

Function Choice{

    $title    = 'Set-DNSRecord Bulk or single'
    $question = "Do you wan't to add/change the DNS Records by single input, or with a CSV file?"
    $choices  = '&Single', '&CSV'
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

    if ($decision -eq 0) {
        Write-Host 'Your choice is Single.'
        Single
    }
    elseif($decision -eq 1){
            Write-Host 'Your choice is CSV Value.'
            CSV
    }
}

#Execution
Choice
