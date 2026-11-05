@echo off
setlocal
title InputOptimizer - consulta BCD

echo InputOptimizer - consulta somente leitura
echo Este arquivo nao altera configuracoes de boot.
echo.
bcdedit /enum {current}
if errorlevel 1 (
  echo.
  echo Nao foi possivel consultar o BCD. Tente abrir o Prompt como administrador.
)
echo.
pause
endlocal
