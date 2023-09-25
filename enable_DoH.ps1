
# Windows Server ships with a list of servers that are known to support DoH.
# You can determine which DNS servers are on this list by using the  "Get-DNSClientDohServerAddress" PowerShell cmdlet.
Get-DNSClientDohServerAddress

# Then you can add DNS server definition to the list and ensure it never falls back to plain-text DNS:
Add-DnsClientDohServerAddress -ServerAddress "8.8.8.8" -DohTemplate "https://dns.google/dns-query" -AllowFallbackToUdp $False -AutoUpgrade $True

# Then you can add another DNS server definition to the list and ensure it never falls back to plain-text DNS:
Add-DnsClientDohServerAddress -ServerAddress "9.9.9.9" -DohTemplate "https://dns.quad9.net/dns-query" -AllowFallbackToUdp $False -AutoUpgrade $True

# Flush the DNS
ipconfig /flushdns
