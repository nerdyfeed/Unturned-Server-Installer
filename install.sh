# /bin/sh

#COLORS
green=$(tput setaf 2)
red=$(tput setaf 1)
reset=$(tput sgr0)
# VARS
SUCCESS="${green}[Успешно]${reset}"
STARTING="${green}Начинаю установку Unturned Server...${reset}"
# ACTION
clear
read -p "Введите имя сервера: " serverName
read -p "Введите количество слотов: " serverSlots
read -p "Введите карту сервера: " serverMap
read -p "Введите директорию сервера: " serverDirectory
echo $STARTING
echo "Обновление окружения..."
sudo apt-get -y update && sudo apt-get -y upgrade && echo $SUCCESS
echo Установка необходимого ПО...
sudo apt-get -y install screen htop mc unzip && echo $SUCCESS
echo Добавление архитектуры...
sudo dpkg --add-architecture i386 && echo $SUCCESS
echo Установка библиотек...
sudo apt-get -y install lib32stdc++6 && sudo apt-get -y install mono-runtime mono-reference-assemblies-2.0 mono-devel libmono-cil-dev && sudo apt-get -y install libc6:i386 libgl1-mesa-glx:i386 libxcursor1:i386 libxrandr2:i386 && sudo apt-get -y install libc6-dev-i386 libgcc-4.8-dev:i386 && echo $SUCCESS
echo Загрузка ядра сервера в директорию $serverDirectory.
cd $serverDirectory
wget https://ci.rocketmod.net/job/Rocket.Unturned%20Linux/lastSuccessfulBuild/artifact/Rocket.Unturned/bin/Release/Rocket.zip -O rocket.zip && unzip -o rocket.zip && rm rocket.zip && echo $SUCCESS
echo Установка прав...
cd $serverDirectory/Scripts && chmod 755 update.sh && chmod 755 start.sh && echo $SUCCESS
echo Установка сервера...
sh update.sh +login "srvuntrnd" "serveruntnrned" +set_steam_guard_code "HV7PJ" && echo $SUCCESS
echo Установка SteamCMD...
cd $serverDirectory
mkdir steamcmd
cd steamcmd
wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
chmod +x steamcmd.sh
./steamcmd.sh +@sSteamCmdForcePlatformBitness 32 +login "srvuntrnd" "serveruntnrned" +set_steam_guard_code "HV7PJ" && echo $SUCCESS
echo Подключение SteamCMD...
cd $serverDirectory
cp steamcmd/linux32/steamclient.so /lib
cp steamcmd/linux64/steamclient.so /lib64
mkdir $serverDirectory/Servers/$serverName
echo "sh ~/Scripts/start.sh $serverName" > $serverName.sh
chmod 777 $serverName.sh
echo "${green}
----------------------
Установка завершена!
Название: $serverName
Слотов: $serverSlots
Карта: $serverMap
Директория: $serverDirectory
----------------------
Для запуска сервера введите start.sh
${reset}"