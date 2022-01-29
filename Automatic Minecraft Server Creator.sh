#!/bin/bash			

clear

echo 'Introduce el nombre de la carpeta del servidor'
while [ -z $SERVERNAME ]; do
	read SERVERNAME
	echo

	if [ -z $SERVERNAME ]; then
		echo 'Debes introducir un nombre'
	fi
done


echo 'Ruta del ordenador en el que quieres crear el servidor. Si no introduces nada, por defecto se instalara en tu directorio de trabajo'
while true; do
	read ROUTE
	echo

	if [[ $(users | awk '{print $1}') = 'root' && -z $ROUTE ]]; then
		ROUTE='/root'
	elif [ -z $ROUTE ]; then
		ROUTE="/home/$(users | awk '{print $1}')"
	fi

	if [ -d $ROUTE ]; then
		mkdir "$ROUTE/$SERVERNAME"
		cd "$ROUTE/$SERVERNAME"
		break
	else
		echo 'Has introducido una ruta inexistente'
	fi
done

echo 'Servidor Vanilla o Forge'
until [[ $CLIENT = "vanilla" || $CLIENT = "forge" ]]; do
	read CLIENT
	echo
	CLIENT=$(echo $CLIENT | tr [:upper:] [:lower:])
	case $CLIENT in
		vanilla)
			echo 'Version que tendra el servidor. Versiones soportadas: 1.17.1, 1.17, 1.16.5'
			while true; do
				read VERSION
				echo
				case $VERSION in
					1.17.1)
						wget https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar &> /dev/null
						break 2
					1.17)
						wget https://launcher.mojang.com/v1/objects/0a269b5f2c5b93b1712d0f5dc43b6182b9ab254e/server.jar &> /dev/null
						break 2
						;;
					1.16.5)
						wget https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar &> /dev/null
						break 2
						;;
					*)
						echo 'Versión introducida incorrecta'
						;;
				esac
			done
			;;
		forge)
			echo 'Version que tendra el servidor. Versiones soportadas: 1.16.5, 1.15.2, 1.12.2'
			while true; do
				read VERSION
				echo
				case $VERSION in
					1.16.5)
						wget -O forge-1.16.5-installer.jar https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.1.32/forge-1.16.5-36.1.32-installer.jar &> /dev/null
						echo 'Espera, por favor'
						java -jar forge-1.16.5-installer.jar --installServer > /dev/null
						rm *installer*
						break 2
						;;
					1.15.2)
						wget -O forge-1.15.2-installer.jar https://maven.minecraftforge.net/net/minecraftforge/forge/1.15.2-31.2.55/forge-1.15.2-31.2.55-installer.jar &> /dev/null
						echo 'Espera, por favor'
						java -jar forge-1.15.2-installer.jar --installServer > /dev/null
						rm *installer*
						break 2
						;;
					1.12.2)
						wget -O forge-1.12.2-installer.jar https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2855/forge-1.12.2-14.23.5.2855-installer.jar &> /dev/null
						echo 'Espera, por favor'
						java -jar forge-1.12.2-installer.jar --installServer > /dev/null
						rm *installer*
						break 2
						;;
					*)
						echo "Versión introducida incorrecta"
						;;
				esac
			done
			;;
		*)
			echo "Opción introducida incorrecta"
			;;
	esac
done

echo 'Espera, por favor'

echo 'Cuanta RAM quieres que tenga el servidor. Introduce solo el numero'
while [[ ! $RAM =~ [0-9] || $RAM =~ -[0-9] || $RAM =~ 0 ]]; do
	read RAM
	echo
	if [[ ! $RAM =~ [0-9] ]]; then
		echo 'Debes introducir un numero'
	elif [[ $RAM =~ -[0-9] || $RAM -le 0 ]]; then
		echo 'Debes introducir como minimo 1'
	fi
done

RAM+='G'
JAVAPATH=/usr/lib/jvm/java-8-openjdk-arm64/jre/bin/java
if [[ $CLIENT = 'vanilla' && ($VERSION = '1.17.1' || $VERSION = '1.17') ]]; then
	echo "java -Xmx"$RAM" -Xms"$RAM" -jar server.jar nogui"
elif [ $CLIENT = 'vanilla' ]; then
	echo "$JAVAPATH -Xmx"$RAM" -Xms"$RAM" -jar server.jar nogui" > start.sh
else
	FORGE=$(ls | grep forge)
	echo "$JAVAPATH -Xmx"$RAM" -Xms"$RAM" -jar $FORGE nogui" > start.sh
fi

. start.sh > /dev/null
sed -i s/false/true/g eula.txt
touch server.properties

echo 'IP local del servidor'
while [[ ! $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; do
	read IP
	echo
	
	if [[ ! $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		echo 'Debes escribir una IP valida'
	elif [ -z $IP ]; then
		echo 'Debes escribir una IP'
	fi
done
echo "server-ip=$IP" >> server.properties

echo 'Puerto del servidor. Si no introduces nada, se pondra el puerto por defecto de Minecraft'
while [[ ! $PORT =~ [0-9] || $PORT =~ -[0-9] || $PORT -le 0 || $PORT -gt 65535 ]]; do
	read PORT
	echo

	if [ -z $PORT ]; then
		PORT='25565'
	fi
	if [[ ! $PORT =~ [0-9] ]]; then
		echo 'Puerto invalido'
	elif [[ $PORT =~ -[0-9] || $PORT -le 0 || $PORT -gt 65535 ]]; then
		echo 'Debes introducir como minimo 1'
	fi
done
echo "server-port=$PORT" >> server.properties

echo 'Servidor Premium o No Premium. P/NP'
while true; do
	read PREMIUM
	echo
	case $PREMIUM in
		p)
			echo 'online-mode=true' >> server.properties
			break 2
			;;
		np)
			echo 'online-mode=false' >> server.properties
			break 2
			;;
		*)
			echo 'Opcion introducida incorrecta'
			;;
	esac
done

echo 'Dificultad que tiene el servidor. (Facil | Easy), (Normal), (Dificil | Hard)'
while true; do
	read DIFFICULTY
	echo
	case $DIFFICULTY in
		facil|easy)
			echo 'difficulty=easy' >> server.properties
			break 2
			;;
		normal)
			echo 'difficulty=normal' >> server.properties
			break 2
			;;
		dificil|hard)
			echo 'difficulty=hard' >> server.properties
			break 2
			;;
		*)
			echo 'Opcion introducida incorrecta'
			;;
	esac
done

echo 'Jugadores maximos'
while [[ ! $MAXPLAYERS =~ [0-9] || $MAXPLAYERS =~ -[0-9] || $MAXPLAYERS -le 0 ]]; do
	read MAXPLAYERS
	echo

	if [[ ! $MAXPLAYERS =~ [0-9] ]]; then
		echo 'Debes introducir numeros'
	elif [[ $MAXPLAYERS =~ -[0-9] || $MAXPLAYERS -le 0 ]]; then
		echo 'Debes introducir como minimo 1'
	fi
done
echo "max-players=$MAXPLAYERS" >> server.properties

echo 'Chunks maximos posibles de visualizar'
while [[ ! $CHUNKS =~ [0-9] || $CHUNKS =~ -[0-9] || $CHUNKS -le 0 ]]; do
	read CHUNKS
	echo

	if [[ ! $CHUNKS =~ [0-9] ]]; then
		echo 'Debes introducir numeros'
	elif [[ $CHUNKS =~ -[0-9] || $CHUNKS -le 0 ]]; then
		echo 'Debes introducir como minimo 1'
	fi
done
echo "view-distance=$CHUNKS" >> server.properties

echo 'spawn-protection=0' >> server.properties
echo 'max-tick-time=-1' >> server.properties

if [ $CLIENT = 'forge' ]; then
	echo 'Indica si vas a instalar el mod Biomes O Plenty. S/N'
	while true; do
		read MOD
		echo
		case $MOD in
			s)
				if [[ $VERSION = '1.17.1' || $VERSION = '1.17' || $VERSION = '1.16.5' ]]; then
					echo 'level-type=biomesoplenty' >> server.properties
				else
					echo 'level-type=BIOMESOP' >> server.properties
				fi
				;;
			n)
				break 2
				;;
			*)
				echo 'Opcion introducida incorrecta'
				;;
		esac
	done
fi

echo 'Establece un MOTD al servidor. Si no introduces nada, no meteras ningun MOTD'
read MOTD
echo "motd=$MOTD" >> server.properties
clear
echo 'Servidor creado exitosamente'
echo
echo 'Esta es tu IP publica. Debes pasarsela a las personas que quieres que entren en tu servidor'
if [ $PORT = '25565' ]; then
	curl ifconfig.me
else
	echo "$(curl -s ifconfig.me):$PORT"
fi
echo 'Para iniciar el servidor, ejecuta el archivo start.sh'

echo
echo 'Pulsa cualquier tecla para salir'
read