# 🐛 Solução: Erro "mirrolist error 255" (CachyOS LiveCD)

Este script corrige o problema de falha na busca por mirrors que impede a instalação do CachyOS.

## ❓ O Problema

O erro \`mirrolist error 255\` ocorre quando o instalador não consegue se comunicar ou processar corretamente a lista de mirrors dos repositórios.

### 💻 Comando para Execução

Execute este comando no terminal do ambiente **LiveCD** para aplicar a correção. Ele fará o download do script e o executará com privilégios de administrador:

```bash
curl -sSLO https://raw.githubusercontent.com/vandermjr/Scripts_CachyOS/main/bugfix-mirrorlist/instalar_cachyos.sh
chmod +x instalar_cachyos.sh
sudo ./instalar_cachyos.sh
