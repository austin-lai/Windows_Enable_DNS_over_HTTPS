

# Windows 11 to enable DNS over HTTPS

```markdown
> Austin.Lai |
> -----------| September 25th, 2023
> -----------| Updated on September 25th, 2023
```

---

## Table of Contents
<!-- TOC -->

- [Windows 11 to enable DNS over HTTPS](#windows-11-to-enable-dns-over-https)
    - [Table of Contents](#table-of-contents)
    - [Disclaimer](#disclaimer)
    - [Description](#description)
    - [Enable DNS over HTTPS for Windows 11](#enable-dns-over-https-for-windows-11)
        - [Method 1 - Enable DNS over HTTPS using netsh command](#method-1---enable-dns-over-https-using-netsh-command)
        - [Method 2 - Enable DNS over HTTPS using powershell command](#method-2---enable-dns-over-https-using-powershell-command)
    - [Enforce DNS over HTTPS using powershell command to modify registry and GPO](#enforce-dns-over-https-using-powershell-command-to-modify-registry-and-gpo)

<!-- /TOC -->
<br>

## Disclaimer

<span style="color: red; font-weight: bold;">DISCLAIMER:</span>

This project/repository is provided "as is" and without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.

This project/repository is for <span style="color: red; font-weight: bold;">Educational</span> purpose <span style="color: red; font-weight: bold;">ONLY</span>. Do not use it without permission. The usual disclaimer applies, especially the fact that me (Austin) is not liable for any damages caused by direct or indirect use of the information or functionality provided by these programs. The author or any Internet provider bears NO responsibility for content or misuse of these programs or any derivatives thereof. By using these programs you accept the fact that any damage (data loss, system crash, system compromise, etc.) caused by the use of these programs is not Austin responsibility.

<br>

## Description

<!-- Description -->

Note for Windows 11 to enable DNS over HTTPS

<br>

## Enable DNS over HTTPS for Windows 11

### Method 1 - Enable DNS over HTTPS using `netsh` command

You can create a batch file (enable_DoH.bat) or execute the command in Command Prompt or Windows Terminal (elevated or admin mode).

The `enable_DoH.bat` file can be found [here](./enable_DoH.bat) or below:

```batch
@REM This to check if DoH status
netsh dns show global

@REM List all available DoH servers and template for Windows 11
netsh dns show encryption

@REM Enable DoH
netsh dns add global dot=yes

@REM Adding First DoH Server
netsh dns add encryption server=8.8.8.8 dohtemplate=https://dns.google/dns-query autoupgrade=yes udpfallback=no

@REM Adding Second DoH Server
netsh dns add encryption server=9.9.9.9 dohtemplate=https://dns.quad9.net/dns-query autoupgrade=yes udpfallback=no

@REM Flush the DNS
ipconfig /flushdns
```

<br>

### Method 2 - Enable DNS over HTTPS using `powershell` command

You can create a powershell script (enable_DoH.ps1) or execute the command in PowerShell in elevated or admin mode.

The `enable_DoH.ps1` file can be found [here](./enable_DoH.ps1) or below:

```powershell

# Windows Server ships with a list of servers that are known to support DoH.
# You can determine which DNS servers are on this list by using the  "Get-DNSClientDohServerAddress" PowerShell cmdlet.
Get-DNSClientDohServerAddress

# Then you can add DNS server definition to the list and ensure it never falls back to plain-text DNS:
Add-DnsClientDohServerAddress -ServerAddress "8.8.8.8" -DohTemplate "https://dns.google/dns-query" -AllowFallbackToUdp $False -AutoUpgrade $True

# Then you can add another DNS server definition to the list and ensure it never falls back to plain-text DNS:
Add-DnsClientDohServerAddress -ServerAddress "9.9.9.9" -DohTemplate "https://dns.quad9.net/dns-query" -AllowFallbackToUdp $False -AutoUpgrade $True

# Flush the DNS
ipconfig /flushdns
```

<br>

## Enforce DNS over HTTPS using `powershell` command to modify registry and GPO

You can create a powershell script (enforce_DoH.ps1) or execute the command in PowerShell in elevated or admin mode.

But first, check out the powershell command usage and all the relevant information in below:

<details>

<summary><span style="padding-left:10px;">Click here to expand to check out the powershell command usage and all the relevant information !!!</span>

</summary>

```powershell

# The GPO for DoH Policy is under
# "Computer Configuration\Policies\Administrative Templates\Network\DNS Client"
# Policy name "Configuring DoH through Group Policy"
# Allow DoH: Perform DoH queries if the configured DNS servers support it. If they don't support, it tries the classic name resolution.
# Require DoH: Allow only DoH name resolution. If there are no DoH-capable DNS servers configured, the name resolution fails.

# The Registry Key corresponding to the DoH Policy in GPO is
# "HKLM\Software\Policies\Microsoft\Windows NT\DNSClient\DoHPolicy"
# Key Detail as below:
# ### Require DoH
# ### Registry Hive	HKEY_LOCAL_MACHINE
# ### Registry Path	Software\Policies\Microsoft\Windows NT\DNSClient
# ### Value Name	DoHPolicy
# ### Value Type	REG_DWORD
# ### Value	3
# ### Allow DoH
# ### Registry Hive	HKEY_LOCAL_MACHINE
# ### Registry Path	Software\Policies\Microsoft\Windows NT\DNSClient
# ### Value Name	DoHPolicy
# ### Value Type	REG_DWORD
# ### Value	2





# For powershell
# To check or list if "DNSClient" exists
Get-ChildItem -Path Registry::"HKLM\Software\Policies\Microsoft\Windows NT\"

# To check or list if "DoHPolicy" exists in "DNSClient"
Get-Item -Path Registry::"HKLM\Software\Policies\Microsoft\Windows NT\" | Select-Object -ExpandProperty Property

# To check if "DoHPolicy" exists in "DNSClient"
Get-Item -Path Registry::"HKLM\Software\Policies\Microsoft\Windows NT\DNSClient" | Select-Object -ExpandProperty Property

# All the commands above are similar !!!





# Sample of the "DoHPolicy" registry entries as below:
Get-ItemProperty -Path Registry::"HKLM\Software\Policies\Microsoft\Windows NT\DNSClient\" -Name "DoHPolicy"
# ### DoHPolicy    : 3
# ### PSPath       : Microsoft.PowerShell.Core\Registry::HKLM\Software\Policies\Microsoft\Windows NT\DNSClient\
# ### PSParentPath : Microsoft.PowerShell.Core\Registry::HKLM\Software\Policies\Microsoft\Windows NT
# ### PSChildName  : DNSClient
# ### PSProvider   : Microsoft.PowerShell.Core\Registry





# Sample of the type of registry key for "DoHPolicy" as below:
(Get-Item -Path Registry::"HKLM\Software\Policies\Microsoft\Windows NT\DNSClient\").GetValueKind("DoHPolicy")
# ### DWord





# If the command above fails because it the node is not exist, let’s create it first

# Create "DNSClient" key
New-Item –Path Registry::"HKLM\Software\Policies\Microsoft\Windows NT\" –Name DNSClient

# Create "DoHPolicy" with "DWord" value of "3"
# "3" corresponding to the information above is "Require DoH"
New-ItemProperty -Path Registry::"HKLM\Software\Policies\Microsoft\Windows NT\DNSClient\" -Name "DoHPolicy" -Value "3" -PropertyType "DWord" -Force





# If "DoHPolicy" existed, set the value to "3"
# "3" corresponding to the information above is "Require DoH"
Set-ItemProperty -Path Registry::"HKLM\Software\Policies\Microsoft\Windows NT\DNSClient\" -Name "DoHPolicy" -Value "3" -Type "DWord" -Force
```

**OR**


```powershell

# Once you in powershell.
# You execute "cd HKLM:"
# It will instruct powershell to use Registry moudle
# The "Registry::HKLM" is prepended
# Therefore, we can navigate to the local machine registry root key by running the following command:
cd HKLM:

# Alternatively, we can set our current working location to a particular path in the registry using the Set-Location cmdlet:
set-location -path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient"

# Then list all the item inside "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient"
Get-childitem



OR



# If you dont want to use "set-location"
# You may directly enter the path with the powershell command as shown below:
Get-Item -path "\Software\Policies\Microsoft\Windows NT\DNSClient"

Get-Item -path "\Software\Policies\Microsoft\Windows NT\DNSClient" | Select-Object -ExpandProperty Property
```

</details>

<br>

The `enforce_DoH.ps1` file can be found [here](./
enforce_DoH.ps1) or below:

<details>

<summary><span style="padding-left:10px;">Click here to expand for the "enforce_DoH.ps1" !!!</span>

</summary>

```powershell
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
} else {
    Write-Host "The 'DoHPolicy' registry entry already exists."
}

# If "DNSClient" and "DoHPolicy" exist, set the value of "DoHPolicy" to 3
if ((Test-Path -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient") -and (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "DoHPolicy" -ErrorAction SilentlyContinue)) {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient\" -Name "DoHPolicy" -Value 3 -Type DWord -Force | Out-Null
}
```

</details>

<br>

