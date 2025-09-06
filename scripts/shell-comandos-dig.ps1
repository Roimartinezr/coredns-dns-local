# Auto-elevación si no está en modo administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "COMANDOS DIG:" -ForegroundColor Yellow
Write-Host "dig @127.0.0.1 buenosdias.com MX"
Write-Host "dig @127.0.0.1 mail.buenosdias.com A"
Write-Host "dig @127.0.0.1 api.buenosdias.com CNAME"
Write-Host "dig @127.0.0.1 buenosdias.com TXT"
Write-Host "dig @127.0.0.1 buenosdias.com SOA"
Write-Host "exit" -ForegroundColor DarkRed
Write-Host ""

# Detectar interfaz activa (Wi-Fi o Ethernet)
$iface = (Get-DnsClient | Where-Object { $_.InterfaceAlias -match "Wi-Fi|Ethernet" -and $_.Status -eq "Up" } | Select-Object -First 1)
if (-not $iface) {
    Write-Host "No se encontró interfaz de red activa" -ForegroundColor Red
    exit
}

# Comprobar si contenedor coredns está en ejecución
$existeContenedor = docker ps --format "{{.Names}}" | Where-Object { $_ -eq "coredns" }

if ($existeContenedor) {
    # Comprobar si existe la imagen coredns-debug
    if (docker image inspect coredns-debug -ErrorAction SilentlyContinue) {
        docker run --rm -it --entrypoint sh --network container:coredns coredns-debug
    }
    else {
        Write-Host "Imagen 'coredns-debug' no encontrada. Usando Alpine con dig..." -ForegroundColor Cyan
        docker run --rm -it --network container:coredns alpine sh -c "
            apk add --no-cache bind-tools >/dev/null;
            sh"
    }
}
else {
    Write-Host "Servidor DNS no levantado" -ForegroundColor DarkRed
    Pause
}