# DevSecOps - Skrypt Uruchomieniowy

#Sprawdzenie czy jest plik .env
Write-Host "[INFO] Sprawdzam obecnosc pliku .env..." -ForegroundColor Cyan
if (-Not (Test-Path -Path ".\.env")) {
    Write-Host "[UWAGA] Brak pliku .env. Generuje czysty szablon..." -ForegroundColor Yellow
    try {
        "DB_PASSWORD=`nDISCORD_SYSTEM_ALERT_WEBHOOK=`nDISCORD_IDS_WEBHOOK=`n" | Out-File -FilePath .\.env -NoClobber -Encoding utf8
        Write-Host "[BLAD] Szablon .env zostal utworzony! Wypelnij go swoimi danymi i uruchom skrypt ponownie." -ForegroundColor Red
        exit
    }
    catch {
        Write-Host "[BLAD] Nie udało się utworzyć pliku .env." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "[OK] Plik .env jest obecny (sprawdz poprawnosc hasel)." -ForegroundColor Green
}

#Sprawdzenie requirements.txt
Write-Host "[INFO] Sprawdzam obecnosc pliku requirements.txt..." -ForegroundColor Cyan
if (Test-Path -Path "$PSScriptRoot\scripts\requirements.txt") {
    Write-Host "[INFO] Znaleziono plik requirements.txt. Rozpoczynam instalacje pakietow..." -ForegroundColor Yellow
    try {
        pip install -r "$PSScriptRoot\scripts\requirements.txt"
        Write-Host "[OK] Pakiety zainstalowane." -ForegroundColor Green
    }
    catch {
        Write-Host "[UWAGA] Problem z pip. Sprawdz, czy Python jest zainstalowany." -ForegroundColor Yellow
    }
} else {
    Write-Host "[UWAGA] Brak pliku requirements.txt. Pomijam instalacje pakietow." -ForegroundColor Yellow
}


# Sprawdzenie czy Docker Engine dziala
Write-Host "[INFO] Sprawdzam status demona Docker..." -ForegroundColor Cyan
docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[BLAD] Demon Docker nie odpowiada!" -ForegroundColor Red
    Write-Host "[INFO] Probuje automatycznie uruchomic Docker Desktop..." -ForegroundColor Yellow
    
    try {
        # Domyslna sciezka instalacji w windows
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction Stop
        Write-Host "[INFO] Wydano polecenie startu. Poczekaj kilkanascie sekund az Docker sie uruchomi i uruchom ten skrypt ponownie." -ForegroundColor Cyan
    } catch {
        Write-Host "[BLAD] Nie udalo sie automatycznie uruchomic Dockera. Wlacz aplikacje recznie." -ForegroundColor Red
    }
    exit
} else {
    Write-Host "[OK] Demon Docker jest aktywny." -ForegroundColor Green
}

# sprawdzenie portu 8080 dla NGINX
Write-Host "[INFO] Weryfikuje dostepnosc portu 8080 (NGINX)..." -ForegroundColor Cyan
$Port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($Port8080) {
    Write-Host "[BLAD] Port 8080 jest zajety! Prawdopodobnie inny serwer lub kontener juz dziala." -ForegroundColor Red
    exit
} else {
    Write-Host "[OK] Port 8080 jest wolny." -ForegroundColor Green
}

# sprawdzenie portu 1433 dla MSSQL
Write-Host "[INFO] Weryfikuje dostepnosc portu 1433 (Baza Danych)..." -ForegroundColor Cyan
$Port1433 = Get-NetTCPConnection -LocalPort 1433 -ErrorAction SilentlyContinue
if ($Port1433) {
    Write-Host "[BLAD] Port 1433 (Baza Danych) jest zajety!" -ForegroundColor Red
    exit
} else {
    Write-Host "[OK] Port 1433 jest wolny." -ForegroundColor Green
}

Write-Host "[INFO] Wszystkie testy OK. Podnosze infrastrukture Dockera..." -ForegroundColor Green
docker compose up -d

# weryfikacja uruchomienia - usuniecie false positive
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Srodowisko zostalo pomyslnie uruchomione!" -ForegroundColor Green
} else {
    Write-Host "[BLAD] Wystapil problem podczas uruchamiania kontenerow. Sprawdz logi wyzej." -ForegroundColor Red
}