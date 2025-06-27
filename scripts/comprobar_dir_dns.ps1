Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq "Wi-Fi"}

# Obtener la configuración DNS del adaptador Wi-Fi
$resultado = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq "Wi-Fi"}

Write-Output ""

# Comprobar si está apuntando al DNS local
if ($resultado.ServerAddresses -contains "127.0.0.1") {
    Write-Host "Configuracion DNS de Windows apuntando al servidor DNS local (127.0.0.1)" -ForegroundColor Yellow
} else {
    Write-Host "Configuracion DNS de Windows por defecto" -ForegroundColor Green
}

Write-Output ""

docker ps

# Comprobar si el contenedor Docker "coredns-dns-local" existe (en cualquier estado)
$existeContenedor = docker ps --format "{{.Names}}" | Where-Object { $_ -eq "coredns" }

Write-Output ""

if ($existeContenedor) {
    Write-Host "El contenedor Docker 'coredns-dns-local' se esta ejecutando." -ForegroundColor Green
} else {
    Write-Host "El contenedor Docker 'coredns-dns-local' NO se esta ejecutando." -ForegroundColor Red
}

Write-Output ""

Pause

if (($resultado.ServerAddresses -contains "127.0.0.1") -and -not ($existeContenedor)) {
    . "$PSScriptRoot\desactivar_dns_local.ps1"
}
if (-not ($resultado.ServerAddresses -contains "127.0.0.1") -and $existeContenedor) {
    . "$PSScriptRoot\desactivar_dns_local.ps1"
}
