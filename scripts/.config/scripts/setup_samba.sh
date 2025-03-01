kk#!/bin/bash

# Verifica se o script está sendo executado como root ou com sudo
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute o script como root ou com sudo."
  exit 1
fi

# Atualiza o sistema e instala o Samba
echo "Atualizando o sistema e instalando o Samba..."
pacman -Syu --noconfirm
pacman -S samba --noconfirm

# Faz backup do smb.conf original, se existir
if [ -f /etc/samba/smb.conf ]; then
  cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
  echo "Backup do smb.conf original criado em /etc/samba/smb.conf.bak"
fi

# Solicita a senha do usuário Samba
echo "Digite a senha desejada para o usuário Samba (kjunda01):"
read -s SAMBA_PASS
echo "Confirme a senha:"
read -s SAMBA_PASS_CONFIRM

# Verifica se as senhas são iguais
if [ "$SAMBA_PASS" != "$SAMBA_PASS_CONFIRM" ]; then
  echo "As senhas não coincidem. Execute o script novamente."
  exit 1
fi

# Configuração do Samba
echo "Configurando o Samba em /etc/samba/smb.conf..."
cat <<EOL > /etc/samba/smb.conf
[global]
workgroup = WORKGROUP
server string = Samba Server no Arch
security = user
encrypt passwords = yes
passdb backend = tdbsam

[Downloads]
path = /home/kjunda01/Downloads
browsable = yes
writable = yes
read only = no
guest ok = no
valid users = kjunda01
force user = kjunda01
force group = users
EOL

# Verifica as permissões atuais da pasta
echo "Verificando permissões de /home/kjunda01/Downloads..."
ls -ld /home/kjunda01/Downloads

# Ajusta as permissões da pasta
echo "Ajustando permissões da pasta /home/kjunda01/Downloads..."
chmod -R 775 /home/kjunda01/Downloads
chown -R kjunda01:users /home/kjunda01/Downloads

# Adiciona o usuário ao Samba e define a senha
echo "Criando usuário Samba (kjunda01) e definindo senha..."
(echo "$SAMBA_PASS"; echo "$SAMBA_PASS") | smbpasswd -a -s kjunda01

# Inicia os serviços do Samba
echo "Iniciando os serviços smb e nmb..."
systemctl start smb
systemctl start nmb

# Habilita os serviços para iniciar automaticamente no boot
echo "Habilitando os serviços smb e nmb no boot..."
systemctl enable smb
systemctl enable nmb

# Testa a configuração do Samba
echo "Testando a configuração do Samba..."
testparm -s

# Informa o IP para acesso
IP=$(ip addr show | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1' | head -n 1)
echo "Configuração concluída!"
echo "Acesse o compartilhamento em: \\\\${IP}\\Downloads"
echo "Se não funcionar, verifique o firewall ou as permissões."

