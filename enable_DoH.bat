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
