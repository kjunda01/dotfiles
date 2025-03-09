clear
echo "CRIANDO A CHAVE:
ssh-keygen -t ed25519 -C "sinvaljuniorlms@gmail.com"
clear
echo "ATIVANDO O SSH-AGENT:
eval "$(ssh-agent -s)"
clear
echo "ADICIONANDO A CHAVE"
ssh-add ~/.ssh/id_ed25519
clear
echo "SUA CHAVE ABAIXO: "
cat ~/.ssh/id_ed25519.pub
cd ~/dotfiles/
git remote set-url origin git@github.com:kjunda01/dotfiles.git
