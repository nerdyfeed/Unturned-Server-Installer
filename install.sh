# /bin/sh

read -p "Введите имя сервера: " serverName
echo Начинаю установку Unturned Server...
echo Обновление окружения...
sleep 3
sudo apt-get -y update
sudo apt-get -y upgrade
echo Установка необходимого ПО...
sleep 3
sudo apt-get -y install screen htop mc unzip
echo Добавление архитектуры...
sudo dpkg --add-architecture i386
echo Установка библиотек...
sleep 3
sudo apt-get -y install lib32stdc++6
sudo apt-get -y install mono-runtime mono-reference-assemblies-2.0 mono-devel libmono-cil-dev
sudo apt-get -y install libc6:i386 libgl1-mesa-glx:i386 libxcursor1:i386 libxrandr2:i386
sudo apt-get -y install libc6-dev-i386 libgcc-4.8-dev:i386
echo Загрузка ядра сервера в директорию /root.
sleep 3
cd ~
wget https://ci.rocketmod.net/job/Rocket.Unturned%20Linux/lastSuccessfulBuild/artifact/Rocket.Unturned/bin/Release/Rocket.zip -O rocket.zip
unzip -o rocket.zip
rm rocket.zip
cd ~/Scripts
echo Установка прав...
sleep 3
chmod 755 update.sh
chmod 755 start.sh
echo Установка сервера...
sleep 3
sh update.sh "srvuntrnd" "serveruntnrned"
echo Установка SteamCMD...
sleep 3
cd ~
mkdir steamcmd
cd steamcmd
wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
chmod +x steamcmd.sh
./steamcmd.sh +@sSteamCmdForcePlatformBitness 32 +login "srvuntrnd" "serveruntnrned"
echo Подключение SteamCMD...
sleep 3
cd ~
cp steamcmd/linux32/steamclient.so /lib
cp steamcmd/linux64/steamclient.so /lib64
mkdir ~/Servers/$serverName
echo "sh ~/Scripts/start.sh $serverName" > start.sh
echo Установка завершена! Для запуска сервера введите start.sh