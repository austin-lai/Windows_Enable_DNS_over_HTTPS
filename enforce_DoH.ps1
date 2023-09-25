# Check if "DNSClient" exists in "HKLM\Software\Policies\Microsoft\Windows NT\" registry key
if (!(Test-Path -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient")) {
    Write-Host "The 'DNSClient' registry key does not exist."
    # Create the 'DNSClient' registry key
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\" -Name DNSClient | Out-Null
} else {
    Write-Host "The 'DNSClient' registry key already exists."
}

# Check if "DoHPolicy" exists in "DNSClient"
if (!(Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "DoHPolicy" -ErrorAction SilentlyContinue)) {
    Write-Host "The 'DoHPolicy' registry entry does not exist."
    # Create the 'DoHPolicy' registry entry with value 3
    New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient\" -Name "DoHPolicy" -Value 3 -PropertyType DWord -Force | Out-Null

    gpupdate.exe /force
} else {
    Write-Host "The 'DoHPolicy' registry entry already exists."
}

# If "DNSClient" and "DoHPolicy" exist, set the value of "DoHPolicy" to 3
if ((Test-Path -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient") -and (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "DoHPolicy" -ErrorAction SilentlyContinue)) {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient\" -Name "DoHPolicy" -Value 3 -Type DWord -Force | Out-Null

    gpupdate.exe /force
}
