function MenuResume() {
	clear
	echo "Добро пожаловать в установщик сервера Unturned"
	echo "Репозиторий скрипта доступен здесь: https://github.com/nerdyfeed/Unturned-Server-Installer"
	echo ""
	echo "Похоже, у вас уже есть установленные сервера"
	echo ""
	echo "Что хотите сделать?"
	echo "   1) Добавить сервер"
	echo "   2) Обновить сервер"
	echo "   3) Добавить аккаунт"
	echo "   4) Выход"

until [[ "$MENU_OPTION" =~ ^[1-4]$ ]]; do
	read -rp "Выбор [1-4]: " MENU_OPTION
done

case $MENU_OPTION in
	1)
		FirstSetup
	;;
	2)
		UpdateServer
	;;
	3)
		addUser
	;;
	4)
		exit 0
	;;
esac

}

function addUser() {
if [ ! -f /etc/untsrv/.steam-acc ]; then
	echo "Пожалуйста, введите данные от Steam аккаунта для установки сервера"
	read -p "Логин: " steamLogin
	read -p "Пароль: " steamPass
	echo -e "$steamLogin" > /etc/untsrv/.steam-acc
	echo -e "$steamPass" > /etc/untsrv/.steam-pass
else
	echo "Данные уже введены"
fi
}

function FirstSetup() {
mkdir /etc/untsrv/
#COLORS
green=$(tput setaf 2)
red=$(tput setaf 1)
reset=$(tput sgr0)
# GET ACC
if [ ! -f /etc/untsrv/.steam-acc ]; then
	echo "$red[Ошибка] Отсутствуют данные аккаунта Steam $reset"
	echo ""
	addUser
fi
LOGIN=$(< /etc/untsrv/.steam-acc)
PASS=$(< /etc/untsrv/.steam-pass)
# VARS
SUCCESS="${green}[Успешно]${reset}"
STARTING="${green}Начинаю установку сервера Unturned...${reset}"
# ACTION
clear
read -p "Введите имя сервера: " serverName
read -p "Введите количество слотов [24] : " serverSlots
read -p "Введите карту сервера [PEI]: " serverMap
read -p "Введите директорию сервера [/root]: " serverDirectory
echo -e "#LAST INSTALL CONF\nname $serverName\nslots $serverSlots\nmap $serverMap\ndir $serverDirectory" > /etc/untsrv/server.conf
#START
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
wget https://bitbucket.org/NerDyFeed/usi/downloads/Rocket-linux.zip -O rocket.zip && unzip -o rocket.zip && rm rocket.zip && echo $SUCCESS
echo Установка прав...
cd $serverDirectory/Scripts && chmod 755 update.sh && chmod 755 start.sh && echo $SUCCESS
echo Установка сервера...
./update.sh "$LOGIN" "$PASS" && echo $SUCCESS
echo Установка SteamCMD...
cd $serverDirectory
mkdir steamcmd
cd steamcmd
wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
chmod +x steamcmd.sh
./steamcmd.sh +@sSteamCmdForcePlatformBitness 32 +login "$LOGIN" "$PASS" && echo $SUCCESS
echo Подключение SteamCMD...
cd $serverDirectory
cp steamcmd/linux32/steamclient.so /lib
cp steamcmd/linux64/steamclient.so /lib64
mkdir $serverDirectory/Servers/$serverName
mkdir $serverDirectory/Servers/$serverName/Server
touch $serverDirectory/Servers/$serverName/Server/Commands.dat
echo -e "name $serverName \nwelcome Добро пожаловать на сервер! \nmap $serverMap \nport 27015 \nmaxplayers $serverSlots \nperspective both \nmode normal \npvp" > $serverDirectory/Servers/$serverName/Server/Commands.dat
cd $serverDirectory
echo Добавление команды запуска
echo 'alias start="cd /root/Scripts/; echo "Starting server..."; /usr/bin/screen -d -m ./start.sh srv; cd /root"' >> ~/.bashrc
echo 'alias console="screen -x"' >> ~/.bashrc
echo "${green}
----------------------
Установка завершена!
Название: $serverName
Слотов: $serverSlots
Карта: $serverMap
Директория: $serverDirectory
----------------------
Для запуска сервера введите start
Для входа в консоль введите console
${reset}"
# END
}

function UpdateServer() {
	LOGIN=$(< /etc/untsrv/.steam-acc)
    PASS=$(< /etc/untsrv/.steam-pass)
    if [[ -z "$LOGIN" && -z "$PASS" ]]; then
    	addUser
    else
    cd /root/Scripts/
	./update.sh "$LOGIN" "$PASS"
	fi
}

if [[ $EUID -ne 0 ]]; then
    echo "Скрипт может быть запущен только от имени root."
    exit 1
else
	if [ -f /etc/untsrv/server.conf ]; then
	        MenuResume
	else
	        FirstSetup
	fi
fi