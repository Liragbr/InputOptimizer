[CmdletBinding()]
param(
    [ValidateRange(10, 100000)]
    [int] $Iterations = 1000,

    [ValidateRange(1, 1000)]
    [int] $SleepMilliseconds = 1,

    [string] $CsvPath
)

$ErrorActionPreference = 'Stop'

function Get-Percentile {
    param(
        [Parameter(Mandatory = $true)][double[]] $Values,
        [Parameter(Mandatory = $true)][ValidateRange(0.0, 1.0)][double] $Percentile
    )

    $sorted = @($Values | Sort-Object)
    $index = [Math]::Ceiling($Percentile * $sorted.Count) - 1
    $index = [Math]::Max(0, [Math]::Min($index, $sorted.Count - 1))
    return [double] $sorted[$index]
}

if (-not [Diagnostics.Stopwatch]::IsHighResolution) {
    Write-Warning 'Stopwatch não usa um contador de alta resolução nesta plataforma.'
}

Write-Host "Aquecimento: 50 esperas de $SleepMilliseconds ms (descartadas)..."
for ($i = 0; $i -lt 50; $i++) {
    Start-Sleep -Milliseconds $SleepMilliseconds
}

$results = [System.Collections.Generic.List[object]]::new()
Write-Host "Medindo $Iterations amostras..."

for ($i = 1; $i -le $Iterations; $i++) {
    $watch = [Diagnostics.Stopwatch]::StartNew()
    Start-Sleep -Milliseconds $SleepMilliseconds
    $watch.Stop()

    $actualMs = $watch.Elapsed.TotalMilliseconds
    $results.Add([pscustomobject]@{
        Sample = $i
        RequestedMs = [double] $SleepMilliseconds
        ObservedMs = [Math]::Round($actualMs, 4)
        OvershootMs = [Math]::Round(($actualMs - $SleepMilliseconds), 4)
    })
}

$observed = [double[]] @($results | ForEach-Object { $_.ObservedMs })
$overshoot = [double[]] @($results | ForEach-Object { $_.OvershootMs })

$summary = [pscustomobject]@{
    Samples = $Iterations
    RequestedMs = $SleepMilliseconds
    ObservedMinMs = [Math]::Round(($observed | Measure-Object -Minimum).Minimum, 4)
    ObservedMedianMs = [Math]::Round((Get-Percentile -Values $observed -Percentile 0.50), 4)
    ObservedP95Ms = [Math]::Round((Get-Percentile -Values $observed -Percentile 0.95), 4)
    ObservedP99Ms = [Math]::Round((Get-Percentile -Values $observed -Percentile 0.99), 4)
    ObservedMaxMs = [Math]::Round(($observed | Measure-Object -Maximum).Maximum, 4)
    OvershootMedianMs = [Math]::Round((Get-Percentile -Values $overshoot -Percentile 0.50), 4)
    StopwatchFrequency = [Diagnostics.Stopwatch]::Frequency
}

Write-Host ''
Write-Host 'Resumo (ms; esta medição não representa input lag):'
$summary | Format-List

if ($CsvPath) {
    $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($CsvPath)
    $results | Export-Csv -LiteralPath $resolvedPath -NoTypeInformation -Encoding UTF8
    Write-Host "Amostras gravadas em: $resolvedPath"
}
