# InputOptimizer

**Transparent Windows timing diagnostics, without magic performance claims.**

InputOptimizer began as a collection of utilities and tweaks intended to reduce input lag. This update organizes the project around a simple rule: **measure first, change one thing at a time, and document how to recover**.

> Measuring `Sleep(1)` does not measure a game's input lag. Perceived latency depends on the entire path: device, polling, operating system, driver, game, rendering, and display. These scripts inspect timing and selected settings; they do not promise higher FPS or lower input latency.

## What is included

- **Wait diagnostics:** measures Windows sleep waits and reports minimum, median, p95, p99, and maximum.
- **Optional CSV:** supports repeatable comparisons with recorded samples.
- **Read-only inspection:** displays system details, active power scheme, queryable boot settings, and the registry timer setting if present.
- **Safe legacy query:** `Prompt/Timer.bat` no longer changes BCD; it only displays current settings.
- **Original utilities preserved:** historical executables and screenshots remain for reference. The new scripts do not depend on them.

## Requirements

- Windows 10 or 11.
- Windows PowerShell 5.1 or PowerShell 7.
- Some BCD settings may require an elevated PowerShell window. The diagnostic scripts do not change the system.

## Quick start

Open PowerShell in the repository directory.

### 1. Inspect settings (read-only)

```powershell
.\Diagnostics\Inspect-System.ps1
```

The script attempts to inspect BCD, the active power scheme, and `GlobalTimerResolutionRequests`. Access failures for boot settings are shown as a warning and do not stop the inspection.

### 2. Measure 1 ms waits

```powershell
.\Diagnostics\Measure-Sleep.ps1
```

By default, it discards 50 warm-up samples and measures 1,000 waits. Increase the sample count for a longer run:

```powershell
.\Diagnostics\Measure-Sleep.ps1 -Iterations 5000 -SleepMilliseconds 1
```

Save raw results:

```powershell
.\Diagnostics\Measure-Sleep.ps1 -Iterations 2000 -CsvPath .\sleep-results.csv
```

The CSV contains the requested duration, observed duration, and overshoot for each sample. Close workloads you do not want included, keep power conditions consistent, and compare multiple runs. Variation is normal.

If script execution policy blocks the file, invoke it without changing the machine policy:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Diagnostics\Measure-Sleep.ps1
```

## Interpreting results

- **Median:** typical observation in this sample; not a latency guarantee.
- **p95/p99:** distribution tail; higher values show some waits took longer.
- **Maximum:** sensitive to interruptions, background activity, and other events; do not use it alone for comparisons.
- **Overshoot:** observed duration minus requested duration. A positive value does not mean a peripheral or game has the same delay.

Actual input-latency measurement requires an appropriate external method, such as a high-speed camera/photodiode or dedicated equipment, with the game, hardware, refresh rate, method, and conditions recorded.

## Timer and boot tweaks

This repository **does not automatically apply** BCD or registry changes. Options such as `useplatformtick`, `disabledynamictick`, and `useplatformclock` affect boot/timing behavior and are not universal gaming presets. A change can worsen results or cause boot problems. Do not apply them as an “optimization” without a testable hypothesis, a backup, and a recovery plan.

The former `Prompt/Timer.bat` has been neutralized: it only queries BCD. The scripts do not create or alter `GlobalTimerResolutionRequests`. If you have already changed boot options, inspect `bcdedit /enum {current}` and consult Microsoft documentation before restoring them; do not indiscriminately delete values.

## Historical executables

Binaries in `ISLC v1.0.3.4/`, `MeasureSleep/`, and `TimerResolution/` are preserved to retain the original project contents. This repository does not provide signed hashes, provenance, or reproducible builds for these files. **Do not run downloaded binaries without verifying their source and integrity.** The new PowerShell scripts are readable text and do not download or execute external code.

## Limitations

- Results describe timed waits on this Windows machine during this run.
- They do not measure keyboard/mouse latency, network latency, frametime, DPC/ISR, or click-to-photon latency.
- Timer resolution and scheduling depend on Windows version, hardware, drivers, and workload.
- Power, firmware, and driver changes can affect results; change one thing at a time and record a recovery path.

## Contributing

Corrections, reproducible measurements, and sourced documentation are welcome. Do not add registry/BCD recommendations without explaining scope, Windows version, risk, validation method, and rollback.

See [SECURITY.md](SECURITY.md) before running historical binaries.

---

[Documentação em português](README.md)
