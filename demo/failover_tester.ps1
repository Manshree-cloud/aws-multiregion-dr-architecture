param(
  [Parameter(Mandatory=$true)][string]$Primary,
  [Parameter(Mandatory=$true)][string]$Secondary,
  [int]$IntervalSec = 5
)

while ($true) {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri $Primary -TimeoutSec 3
    Write-Host "$(Get-Date -Format o) PRIMARY OK $($r.StatusCode)"
  } catch {
    Write-Warning "$(Get-Date -Format o) PRIMARY FAIL -> fallback"
    try {
      $r2 = Invoke-WebRequest -UseBasicParsing -Uri $Secondary -TimeoutSec 3
      Write-Host "$(Get-Date -Format o) SECONDARY OK $($r2.StatusCode)" -ForegroundColor Green
    } catch {
      Write-Error "$(Get-Date -Format o) BOTH DOWN"
    }
  }
  Start-Sleep -Seconds $IntervalSec
}
