<#
.SYNOPSIS
	Set and change a single DNS record
.DESCRIPTION
	This PowerShell script can create and change a single DNS record. Change only the value's on line 51.
.PARAMETER message
	DNSServerName = the DNS Server host
    HostName = The record of the DNS name you will add/change
    ZoneName = The name of the zone inside the DNS server
    IPv4Address = The common IPv4 Address you will add
.EXAMPLE
	PS> ./Set-DNSRecord -DNSServerName "DC01" -HostName "SQL01" -ZoneName "MrRamsus.local" -IPv4Address "10.10.10.115"
.LINK
	https://github.com/MrRamsus/PowerShell_AD_Public/blob/main/Set-DNSRecord.ps1
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

##Script starts here##
Set-DNSRecord -DNSServerName "" -HostName "" -ZoneName "" -IPv4Address ""
