# InputOptimizer

**Diagnóstico transparente de temporização no Windows — sem promessas mágicas.**

O InputOptimizer começou como uma coleção de utilitários e ajustes para tentar reduzir input lag. Esta atualização organiza o projeto em torno de uma regra simples: **medir primeiro, mudar uma coisa por vez e manter a reversão documentada**.

> Medir a duração de `Sleep(1)` não mede o input lag de um jogo. A latência percebida depende de toda a cadeia: dispositivo, polling, sistema operacional, driver, jogo, renderização e monitor. Os scripts deste repositório avaliam temporização e mostram algumas configurações; não prometem FPS maior nem menor latência de entrada.

## O que há aqui

- **Diagnóstico de espera:** mede amostras de `Start-Sleep`/temporização do Windows e calcula mínimo, mediana, p95, p99 e máximo.
- **CSV opcional:** permite comparar execuções em condições registradas.
- **Inspeção somente leitura:** exibe informações do sistema, plano de energia, opções de boot consultáveis e o valor da configuração de timer no Registro, se existir.
- **Consulta legada segura:** `Prompt/Timer.bat` não altera mais o BCD; apenas exibe a configuração atual.
- **Ferramentas antigas preservadas:** executáveis e capturas originais continuam no repositório para referência. Não são necessários para usar os scripts novos.

## Requisitos

- Windows 10 ou 11.
- Windows PowerShell 5.1 ou PowerShell 7.
- Para consultar algumas opções do BCD, abra o PowerShell como administrador. Os scripts de diagnóstico não alteram o sistema.

## Começar

Clone ou baixe o repositório e abra o PowerShell na pasta.

### 1. Inspecionar configurações (somente leitura)

```powershell
.\Diagnostics\Inspect-System.ps1
```

O script tenta consultar o BCD, o plano de energia ativo e o valor de `GlobalTimerResolutionRequests`. Falhas de acesso à configuração do boot aparecem como aviso, sem interromper a inspeção.

### 2. Medir esperas de 1 ms

```powershell
.\Diagnostics\Measure-Sleep.ps1
```

A execução padrão descarta 50 amostras de aquecimento e mede 1.000 esperas. Para aumentar a duração do teste:

```powershell
.\Diagnostics\Measure-Sleep.ps1 -Iterations 5000 -SleepMilliseconds 1
```

Para salvar os resultados brutos:

```powershell
.\Diagnostics\Measure-Sleep.ps1 -Iterations 2000 -CsvPath .\sleep-results.csv
```

O CSV contém a duração solicitada, a duração observada e o excesso por amostra. Feche cargas de trabalho que você não queira incluir, mantenha a mesma alimentação/energia e compare múltiplas execuções. A variação entre execuções é normal.

Se a política de execução bloquear o script, invoque-o sem alterar a política da máquina:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Diagnostics\Measure-Sleep.ps1
```

## Como interpretar

- **Mediana:** experiência típica nesta amostra; não é uma garantia de latência.
- **p95/p99:** cauda da distribuição; valores maiores mostram que algumas esperas foram mais longas.
- **Máximo:** sensível a interrupções, atividade em segundo plano e outros eventos; não use sozinho para comparar.
- **Delta:** tempo observado menos tempo solicitado. Um valor positivo não significa que um periférico ou jogo tenha esse mesmo atraso.

Para medir input lag de verdade, use uma metodologia externa apropriada, como câmera de alta velocidade/fotodiodo ou equipamento dedicado, e registre jogo, hardware, taxa de atualização, método e condições.

## Ajustes de timer e boot

Este repositório **não aplica automaticamente** ajustes de BCD ou Registro. Comandos como `useplatformtick`, `disabledynamictick` e `useplatformclock` afetam o comportamento de temporização/boot e não são presets universais para jogos. Uma mudança pode piorar resultados ou causar problemas de inicialização. Não os aplique como “otimização” sem uma hipótese testável, backup e um plano de recuperação.

O antigo `Prompt/Timer.bat` foi neutralizado nesta versão: ele apenas consulta o BCD. A configuração `GlobalTimerResolutionRequests` também não é criada ou alterada pelos scripts. Se você já alterou opções de boot, veja a saída de `bcdedit /enum {current}` e consulte a documentação da Microsoft antes de restaurá-las; não apague valores indiscriminadamente.

## Executáveis históricos

Os binários em `ISLC v1.0.3.4/`, `MeasureSleep/` e `TimerResolution/` foram mantidos para preservar o conteúdo original. Este repositório não fornece hashes assinados, cadeia de proveniência nem build reproduzível para esses arquivos. **Não execute um binário baixado sem verificar sua origem e integridade.** Os scripts PowerShell novos são texto legível e não baixam nem executam código externo.

## Estrutura

```
Diagnostics/
  Inspect-System.ps1
  Measure-Sleep.ps1
GlobalTimerResolutionRequests/
ISLC v1.0.3.4/
MeasureSleep/
Prompt/
  Timer.bat
TimerResolution/
assets/
```

## Limitações

- Os resultados descrevem esperas temporizadas no Windows nesta máquina e nesta execução.
- Eles não medem latência de teclado/mouse, latência de rede, frametime, DPC/ISR, nem latência click-to-photon.
- A resolução e o agendamento de timers dependem da versão do Windows, hardware, drivers e carga.
- Mudanças de energia, firmware e drivers podem alterar resultados; faça uma alteração por vez e registre como reverter.

## Contribuições

Correções, medições reproduzíveis e documentação com fontes são bem-vindas. Não inclua recomendações de Registro/BCD sem explicar escopo, versão do Windows, risco, método de validação e reversão.

Consulte [SECURITY.md](SECURITY.md) antes de executar binários históricos.

---

[English documentation](README.en.md)
