[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'

Write-Host 'InputOptimizer — inspeção somente leitura'
Write-Host 'Nenhuma configuração será alterada.'
Write-Host ''

$os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($os) {
    [pscustomobject]@{
        ComputerName = $env:COMPUTERNAME
        Windows = $os.Caption
        Version = $os.Version
        Build = $os.BuildNumber
        LastBoot = $os.LastBootUpTime
        StopwatchHighResolution = [Diagnostics.Stopwatch]::IsHighResolution
        StopwatchFrequency = [Diagnostics.Stopwatch]::Frequency
    } | Format-List
}

Write-Host 'Plano de energia ativo:'
$powerCfg = Get-Command powercfg.exe -ErrorAction SilentlyContinue
if ($powerCfg) {
    & $powerCfg.Source /getactivescheme
    if ($LASTEXITCODE -ne 0) { Write-Warning 'Não foi possível consultar o plano de energia.' }
} else {
    Write-Warning 'powercfg.exe não foi encontrado.'
}

Write-Host ''
Write-Host 'Opções de boot (consulta BCD):'
$bcdEdit = Get-Command bcdedit.exe -ErrorAction SilentlyContinue
if ($bcdEdit) {
    $bcdOutput = & $bcdEdit.Source /enum '{current}' 2>&1
    if ($LASTEXITCODE -eq 0) {
        $bcdOutput
    } else {
        Write-Warning 'O BCD não pôde ser consultado. Tente novamente em um PowerShell elevado.'
        $bcdOutput | ForEach-Object { Write-Verbose $_ }
    }
} else {
    Write-Warning 'bcdedit.exe não foi encontrado.'
}

Write-Host ''
Write-Host 'GlobalTimerResolutionRequests (somente leitura):'
$registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'
try {
    $property = Get-ItemProperty -LiteralPath $registryPath -Name GlobalTimerResolutionRequests -ErrorAction Stop
    [pscustomobject]@{
        Path = $registryPath
        Name = 'GlobalTimerResolutionRequests'
        Value = $property.GlobalTimerResolutionRequests
    } | Format-List
} catch {
    Write-Host 'Valor ausente ou inacessível; nenhum valor foi criado.'
}
