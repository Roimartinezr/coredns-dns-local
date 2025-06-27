Write-Host "COMANDOS DIG:" -ForegroundColor Yellow
Write-Host "dig @127.0.0.1 buenosdias.com MX"
Write-Host "dig @127.0.0.1 mail.buenosdias.com A"
Write-Host "dig @127.0.0.1 api.buenosdias.com CNAME"
Write-Host "dig @127.0.0.1 buenosdias.com TXT"
Write-Host "dig @127.0.0.1 buenosdias.com SOA"
Write-Host "exit" -ForegroundColor DarkRed

Write-Host ""

$existeContenedor = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq "coredns" }

if ($existeContenedor) {
	docker run --rm -it --entrypoint sh --network container:coredns coredns-debug
} else {
	Write-Host "Servidor DNS no levantado" -ForegroundColor DarkRed
	Pause
}