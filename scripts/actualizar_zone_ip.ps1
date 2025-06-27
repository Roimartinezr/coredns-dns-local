# Obtener IP del adaptador Wi-Fi o usar 127.0.0.1 si no disponible
$wifiIP = (Get-NetIPAddress -InterfaceAlias "Wi-Fi" -AddressFamily IPv4 `
            | Where-Object { $_.IPAddress -notlike "169.*" -and $_.PrefixOrigin -ne "WellKnown" } `
            | Select-Object -First 1 -ExpandProperty IPAddress)

if (-not $wifiIP) {
    Write-Host "No se ha encontrado IP válida, usando 127.0.0.1" -ForegroundColor Yellow
    $wifiIP = "127.0.0.1"
} else {
    Write-Host "IP detectada: $wifiIP" -ForegroundColor Green
}

# Ruta al archivo de zona
$zoneFile = "$PSScriptRoot\..\zones\buenosdias.zone"

# Reemplazar las líneas de ns1 y mail en el archivo de zona
(Get-Content $zoneFile) | ForEach-Object {
    $line = $_
    if ($line -match "^\s*ns1\s+IN\s+A\s+") {
        $line = "ns1 IN A $wifiIP"
    }
    if ($line -match "^\s*mail\s+IN\s+A\s+") {
        $line = "mail IN A $wifiIP"
    }
    if ($line -match "^\s*www\s+IN\s+A\s+") {
        $line = "www IN A $wifiIP"
    }
    $line
} | Set-Content $zoneFile

Write-Host "Archivo de zona actualizado con la IP $wifiIP"

Write-Host ""
