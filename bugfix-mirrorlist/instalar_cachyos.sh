#!/bin/bash

# --- Variáveis ---
CALAMARES_SOURCE="/usr/share/calamares/settings_online.conf"
CALAMARES_DEST="/etc/calamares/settings.conf"
MIRRORLIST_SCRIPT="/etc/calamares/scripts/update-mirrorlist"

# --- Título ---
echo "================================================="
echo " CachyOS - Configuração Inteligente do Calamares "
echo "================================================="
echo

# --- Função de Escolha do Gerenciador de Boot ---
choose_bootloader() {
    echo "🚨 Passo 1: Escolha o Gerenciador de Boot (Bootloader) que será USADO na instalação:"
    echo "----------------------------------------------------------------------------------"
    echo "1) GRUB (Recomendado para a maioria dos sistemas BIOS/UEFI)"
    echo "2) Systemd-boot (Opção nativa para sistemas UEFI, mais simples)"
    echo "3) rEFInd (Interface gráfica e fácil de gerenciar múltiplos sistemas)"
    echo "4) Limine (Opção moderna e minimalista)"
    echo
    read -p "Digite o número da sua escolha (1-4): " choice

    case $choice in
        1)
            BOOTLOADER_TO_KEEP="grub"
            ;;
        2)
            BOOTLOADER_TO_KEEP="systemd"
            ;;
        3)
            BOOTLOADER_TO_KEEP="refind"
            ;;
        4)
            BOOTLOADER_TO_KEEP="limine"
            ;;
        *)
            echo "❌ Escolha inválida. Por favor, tente novamente."
            choose_bootloader # Chama a função novamente em caso de erro
            ;;
    esac
}

# --- Executa a Escolha ---
choose_bootloader

# --- Remoção dos Módulos Não Selecionados ---
echo
echo "🚀 Passo 2: Removendo/Sincronizando módulos de gerenciador de boot..."
echo "-----------------------------------------------------------------------"
# Lista de todos os módulos
MODULES=("grub" "systemd" "refind" "limine")

for module in "${MODULES[@]}"; do
    PACKAGE="cachyos-calamares-qt6-${module}"

    if [ "$module" != "$BOOTLOADER_TO_KEEP" ]; then
        echo "Removendo: $PACKAGE"
        # O comando de remoção é executado com confirmação automática
        yes | sudo pacman -R $PACKAGE --noconfirm 2>/dev/null
    else
        echo "Mantendo (e garantindo a instalação): $PACKAGE"
        # Sincroniza e garante a instalação do módulo escolhido
        sudo pacman -Sy $PACKAGE --noconfirm
    fi
done

# --- NOVO PASSO: COMENTAR LINHAS NO SCRIPT DE MIRRORLIST ---
echo
echo "📝 Passo 3: Comentando as 3 últimas linhas do script de atualização de mirrorlist..."
echo "------------------------------------------------------------------------------------"
if [ -f "$MIRRORLIST_SCRIPT" ]; then
    # O comando 'sed' é usado para substituir as 3 últimas linhas por elas mesmas precedidas de '#'
    # ':a;N;$!ba; ...' - Lê o arquivo inteiro.
    # 's/\(.*\)\n\(.*\)\n\(.*\)$/#\1\n#\2\n#\3/g' - Captura as 3 últimas linhas (\n é nova linha) e as substitui com '#' na frente de cada uma.
    sudo sed -i -e :a -e 'N;$!ba' -e 's/\(.*\)\n\(.*\)\n\(.*\)$/#\1\n#\2\n#\3/g' "$MIRRORLIST_SCRIPT"
    echo "Linhas comentadas em $MIRRORLIST_SCRIPT."
else
    echo "⚠️ Aviso: Script de mirrorlist $MIRRORLIST_SCRIPT não encontrado. Pulando este passo."
fi


# --- Configuração do Calamares ---
echo
echo "⚙️ Passo 4: Configurando o Calamares para modo Online..."
echo "---------------------------------------------------------"
if [ -f "$CALAMARES_SOURCE" ]; then
    # Copia o arquivo de configuração de online para ser o settings principal
    sudo cp "$CALAMARES_SOURCE" "$CALAMARES_DEST"
    echo "Arquivo de configuração copiado com sucesso para $CALAMARES_DEST."
else
    echo "⚠️ Aviso: Arquivo $CALAMARES_SOURCE não encontrado. Pulando a cópia de settings."
fi

# --- Início do Calamares ---
echo
echo "✨ Passo 5: Iniciando o Instalador Calamares em modo de Depuração..."
echo "-------------------------------------------------------------------"
# O comando dbus-launch com -D6 (debug level 6) para logs detalhados
sudo -E dbus-launch calamares -D6

echo
echo "================================================="
echo " Configuração e Início do Calamares Concluídos! "
echo "================================================="
