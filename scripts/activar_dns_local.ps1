# & "$PSScriptRoot\actualizar_zone_ip.ps1"

# Asegurar que Docker Desktop está activo
$dockerProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue

if (-not $dockerProcess) {
    Write-Host "Iniciando Docker Desktop..." -ForegroundColor Cyan
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    
    # Esperar hasta que Docker esté activo
    while (-not (docker info 2>$null)) {
        Start-Sleep -Seconds 1
        Write-Host "." -NoNewline
    }

    $timeout = 30
    $elapsed = 0
    while ($elapsed -lt $timeout) {
	Start-Sleep -Seconds 2
	$elapsed += 2
        Write-Host "." -NoNewline
    }

} else {
    Write-Host "Docker Desktop ya esta en ejecucion." -ForegroundColor Green
}

$done = 0

while ($done -lt 1) {
    try {
        # Activar CoreDNS y usarlo como DNS principal
        Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("127.0.0.1", "1.1.1.1") -ErrorAction Stop

        # Validar que el archivo docker-compose existe
        $composePath = "$PSScriptRoot\..\docker-compose.yml"
        if (-not (Test-Path $composePath)) {
            throw "No se encontró el archivo docker-compose.yml en: $composePath"
        }

        # Levantar el contenedor
        $dockerSalida = docker compose -f $composePath up -d 2>&1
        if ($LASTEXITCODE -ne 0) {
             throw "Error al levantar el contenedor: $dockerSalida"
        }

        Write-Host ""
        Write-Host "OK" -ForegroundColor Green
        Write-Host "Servidor DNS activado" -ForegroundColor Cyan

	$done = 1

   }
   catch {
       Write-Host ""
       Write-Host "ERROR: Fallo la activacion del servidor DNS" -ForegroundColor Red
       Write-Host "Detalles: $_" -ForegroundColor DarkRed
   }
}

ipconfig /flushdns

Start-Sleep -Seconds 3

# Ejecutar script para comprobar la configuración DNS
. "$PSScriptRoot\comprobar_dir_dns.ps1"
