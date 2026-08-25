# DevSecOps - lekki IDS 
#zaladowanie z env
$EnvFile = Get-Content "$PSScriptRoot\..\.env"
$WebhookUrl = ($EnvFile | Where-Object {$_ -match '^DISCORD_IDS_WEBHOOK=' }) -replace '^DISCORD_IDS_WEBHOOK=', ''
$WebhookUrl =$WebhookUrl.Trim()

$ContainerName = 'devsecops-homelab-web-1'
Write-Host ('[ Tarcza DevSecOps aktywna. Nasluchiwanie logow z ' + $ContainerName + '... ]') -ForegroundColor Cyan

# ciągłe monitorowanie nowych logów 
docker logs -f --tail 0 $ContainerName 2>&1 | ForEach-Object {
    $Line =$_.ToString()
    #szukanie wzorców
    if ($Line -match 'nikto|nmap|1=1|alert|<script>|union') {
        Write-Host ('WYKRYTO ATAK: ' + $Line) -ForegroundColor Yellow
        Write-Host 'Wysylam alert na Discord...' -ForegroundColor Blue
        
        # discord markdown format
        $Backticks = '```'
        $NL = [Environment]::NewLine
        $Markdown = '**ALARM IDS!** Zarejestrowano zlosliwy ruch webowy:' + $NL + $Backticks + $NL + $Line + $NL + $Backticks
        
        $Payload = @{ content = $Markdown } | ConvertTo-Json
        #discord alert
        try {
            Invoke-RestMethod -Uri $WebhookUrl -Method Post -ContentType 'application/json; charset=utf-8' -Body $Payload | Out-Null
            Write-Host 'Wyslano alert na Discord!' -ForegroundColor Green
        } catch {
            Write-Host ('Blad wysylania na Discord: ' + $_) -ForegroundColor Red
        }
        
        Start-Sleep -Seconds 2.5
    }
}