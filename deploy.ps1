# DevSecOps - Skrypt Uruchomieniowy
Write-Host "Rozpoczynam dokcer compose up -d dla srodowiska DevSecOps..." -ForegroundColor Cyan

# Sprawdzenie czy Docker Engine dziala
docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[BLAD] Demon Docker nie odpowiada!" -ForegroundColor Red
    Write-Host "Probuje automatycznie uruchomic Docker Desktop..." -ForegroundColor Yellow
    
    try {
        # Domyslna sciezka instalacji w windows
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction Stop
        Write-Host "Wydano polecenie startu. Poczekaj kilkanascie sekund az Docker sie uruchomi i uruchom ten skrypt ponownie." -ForegroundColor Cyan
    } catch {
        Write-Host "Nie udalo sie automatycznie uruchomic Dockera. Wlacz aplikacje recznie." -ForegroundColor Red
    }
    exit
}

# sprawdzenie portu 8080 dla NGINX
$Port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($Port8080) {
    Write-Host "[BLAD] Port 8080 jest zajety! Prawdopodobnie inny serwer lub kontener juz dziala." -ForegroundColor Red
    exit
}

# sprawdzenie portu 1433 dla MSSQL
$Port1433 = Get-NetTCPConnection -LocalPort 1433 -ErrorAction SilentlyContinue
if ($Port1433) {
    Write-Host "[BLAD] Port 1433 (Baza Danych) jest zajety!" -ForegroundColor Red
    exit
}

Write-Host "Testy portow OK. Podnosze infrastrukture Dockera..." -ForegroundColor Green
docker compose up -d

# weryfikacja uruchomienia - usuniecie false positive
if ($LASTEXITCODE -eq 0) {
    Write-Host "Srodowisko zostalo pomyslnie uruchomione!" -ForegroundColor Green
} else {
    Write-Host "[BLAD] Wystapil problem podczas uruchamiania kontenerow. Sprawdz logi wyzej." -ForegroundColor Red
}