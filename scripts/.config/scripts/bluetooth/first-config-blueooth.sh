echo "Instalando blueooth com bluez e bluez-utils"
pacman -Sy bluez bluez-utils blueman-manager

echo "Ligando btusb"
modprobe btusb

echo "Iniciando bluetooth.service..." 
systemctl start bluetooth.service

echo "Habilitando bluetooth.service..."
systemctl enable bluetooth.service
