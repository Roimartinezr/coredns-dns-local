# Auto-elevación
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

try {
    # Restaurar DNS automático en Windows
    Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ResetServerAddresses -ErrorAction Stop

    # Comprobar que el archivo docker-compose existe
    $composePath = "$PSScriptRoot\..\docker-compose.yml"
    if (-not (Test-Path $composePath)) {
        throw "No se encontró el archivo docker-compose.yml en: $composePath"
    }

    # Detener el contenedor de CoreDNS
    $dockerSalida = docker compose -f $composePath down 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Error al detener el contenedor: $dockerSalida"
    }

    Write-Output ""
    Write-Host "OK" -ForegroundColor Green
    Write-Host "Servidor DNS desactivado" -ForegroundColor Cyan
}
catch {
    Write-Host ""
    Write-Host "ERROR: Fallo la desactivacion del servidor DNS" -ForegroundColor Red
    Write-Host "Detalles: $_" -ForegroundColor DarkRed
}

# Ejecutar script que comprueba la configuración DNS
. "$PSScriptRoot\comprobar_dir_dns.ps1"
