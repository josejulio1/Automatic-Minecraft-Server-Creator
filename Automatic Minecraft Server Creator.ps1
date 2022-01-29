
Clear-Host

Write-Output 'Introduce el nombre de la carpeta del servidor'
while (!$SERVERNAME) {
    $SERVERNAME = Read-Host
    Write-Output ''

    if (!$SERVERNAME) {
        Write-Output 'Debes introducir un nombre'
    }
}

Write-Output "Ruta del ordenador en el que quieres crear el servidor. Si no introduces nada, por defecto se instalara en el escritorio"
while ($true) {
    $ROUTE = Read-Host
    Write-Output ''

    if (!$ROUTE) {
        $ROUTE = [System.Environment]::GetFolderPath('Desktop')
    }

    if (Test-Path $ROUTE) {
        mkdir $ROUTE\$SERVERNAME | Out-Null
        Set-Location $ROUTE\$SERVERNAME
        break
    } else {
        Write-Output 'Has introducido una ruta inexistente'
    }
}

Write-Output 'Servidor Vanilla o Forge'
:main while ($CLIENT -ne 'vanilla' -or $CLIENT -ne 'forge') {
    $CLIENT = Read-Host
    Write-Output ''
    switch ($CLIENT.ToLower()) {
        vanilla {
            Write-Output 'Version que tendra el servidor. Versiones soportadas: 1.17.1, 1.17, 1.16.5'
            while ($true) {
                $VERSION = Read-Host
                Write-Output ''
                switch ($VERSION) {
                    1.17.1 {
                        Invoke-WebRequest -Uri https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar -OutFile server.jar
                        break main
                    }
                    1.17 {
                        Invoke-WebRequest -Uri https://launcher.mojang.com/v1/objects/0a269b5f2c5b93b1712d0f5dc43b6182b9ab254e/server.jar -OutFile server.jar
                        break main
                    }
                    1.16.5 {
                        Invoke-WebRequest -Uri https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar -OutFile server.jar
                        break main
                    }
                    default { Write-Output 'Version introducida incorrecta' }
                }
            }
        }
        forge {
            Write-Output 'Version que tendra el servidor. Versiones soportadas: 1.16.5, 1.15.2, 1.12.2'
            while ($true) {
                $VERSION = Read-Host
                Write-Output ''
                switch ($VERSION) {
                    1.16.5 {
                        Invoke-WebRequest -Uri https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.20/forge-1.16.5-36.2.20-installer.jar -OutFile forge-1.16.5-installer.jar
                        Write-Output 'Espera, por favor'
                        java -jar forge-1.16.5-installer.jar --installServer | Out-Null
                        Remove-Item *installer*
                        break main
                    }
                    1.15.2 {
                        Invoke-WebRequest -Uri https://maven.minecraftforge.net/net/minecraftforge/forge/1.15.2-31.2.55/forge-1.15.2-31.2.55-installer.jar -OutFile forge-1.15.2-installer.jar
                        Write-Output 'Espera, por favor'
                        java -jar forge-1.15.2-installer.jar --installServer | Out-Null
                        Remove-Item *installer*
                        break main
                    }
                    1.12.2 {
                        Invoke-WebRequest -Uri https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2860/forge-1.12.2-14.23.5.2860-installer.jar -OutFile forge-1.12.2-installer.jar
                        Write-Output 'Espera, por favor'
                        java -jar forge-1.12.2-installer.jar --installServer | Out-Null
                        Remove-Item *installer*
                        break main
                    }
                    default { Write-Output 'Version introducida incorrecta' }
                }
            }
        }
        default { Write-Output 'Opcion introducida incorrecta' }
    }
}

Write-Output ''

Write-Output 'Cuanta RAM quieres que tenga el servidor. Introduce solo el numero'
while ($RAM -notmatch '\d' -or $RAM -match '-\d' -or $RAM -le 0) {
    $RAM = Read-Host
    Write-Output ''
    if ($RAM -notmatch '\d') {
        Write-Output 'Debes introducir un numero'
    } elseif ($RAM -match '-\d' -or $RAM -le 0) {
        Write-Output 'Debes introducir como minimo 1'
    }
}

$RAM+='G'
# This is because 1.17 version is made in a new version of Java
$JAVAPATH="C:\Program Files\Java\$((Get-ChildItem 'C:\Program Files\Java').Name | Select-String 'jre*')\bin\java.exe"
# Set double quotes to $JAVAPATH
$JAVAPATH='"{0}"' -f $JAVAPATH
if ($CLIENT.Equals('vanilla') -and ($VERSION.Equals('1.17.1') -or $VERSION.Equals('1.17'))) {
    cmd.exe /C "echo java -Xmx$RAM -Xms$RAM -jar server.jar nogui > start.bat"
} elseif ($CLIENT.Equals('vanilla')) {
    cmd.exe /C "echo $JAVAPATH -Xmx$RAM -Xms$RAM -jar server.jar nogui > start.bat"
} else {
    $FORGE = (Get-ChildItem).Name | Select-String 'forge'
    cmd.exe /C "echo $JAVAPATH -Xmx$RAM -Xms$RAM -jar $FORGE nogui > start.bat"
}
.\start.bat | Out-Null
(Get-Content eula.txt).Replace('false', 'true') | Set-Content eula.txt
cmd.exe /C 'type nul > server.properties'

Write-Output 'IP local del servidor'
while ($IP -notmatch '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}') {
    $IP = Read-Host
    Write-Output ''

    if ($IP -notmatch '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' -and !(!$IP)) {
        Write-Output 'Debes escribir una IP valida'
    } elseif (!$IP) {
        Write-Output 'Debes escribir una IP'
    }
}
cmd.exe /C "echo server-ip=$IP >> server.properties"

Write-Output 'Puerto del servidor. Si no introduces nada, se pondra el puerto por defecto de Minecraft'
while ($PORT -notmatch '\d' -or $PORT -match '-\d' -or $PORT -le '0' -or $PORT -gt '65535') {
    $PORT = Read-Host
    Write-Output ''

    if (!$PORT) {
        $PORT='25565'
    }
    if ($PORT -notmatch '\d') {
        Write-Output 'Puerto invalido'
    } elseif ($PORT -match '-\d' -or $PORT -le '0' -or $PORT -gt '65535') {
        Write-Output 'Debes introducir como minimo 1'
    }
}
cmd.exe /C "echo server-port=$PORT >> server.properties"

Write-Output 'Servidor Premium o No Premium. P/NP'
:premium while ($true) {
    $PREMIUM = Read-Host
    Write-Output ''
    switch ($PREMIUM.ToLower()) {
        p {
            cmd.exe /C 'echo online-mode=true >> server.properties'
            break premium
        }
        np {
            cmd.exe /C 'echo online-mode=false >> server.properties'
            break premium
        }
        default { Write-Output 'Opcion introducida incorrecta' }
    }
}

Write-Output 'Dificultad que tiene el servidor. (Facil | Easy), (Normal), (Dificil | Hard)'
:difficulty while ($true) {
    $DIFFICULTY = Read-Host
    Write-Output ''
    switch ($DIFFICULTY.ToLower()) {
        facil {
            cmd.exe /C 'echo difficulty=easy >> server.properties'
            break difficulty
        }
        easy {
            cmd.exe /C 'echo difficulty=easy >> server.properties'
            break difficulty
        }
        normal {
            cmd.exe /C 'echo difficulty=normal >> server.properties'
            break difficulty
        }
        dificil {
            cmd.exe /C 'echo difficulty=hard >> server.properties'
            break difficulty
        }
        hard {
            cmd.exe /C 'echo difficulty=hard >> server.properties'
            break difficulty
        }
        default { Write-Output 'Opcion introducida incorrecta' }
    }
}

Write-Output 'Jugadores maximos'
while ($MAXPLAYERS -notmatch '\d' -or $MAXPLAYERS -match '-\d' -or $MAXPLAYERS -le '0') {
    $MAXPLAYERS = Read-Host
    Write-Output ''
    
    if ($MAXPLAYERS -notmatch '\d') {
        Write-Output 'Debes introducir numeros'
    } elseif ($MAXPLAYERS -match '-\d' -or $MAXPLAYERS -le '0') {
        Write-Output 'Debes introducir como minimo 1'
    }
}
cmd.exe /C "echo max-players=$MAXPLAYERS >> server.properties"

Write-Output 'Chunks maximos posibles de visualizar'
while ($CHUNKS -notmatch '\d' -or $CHUNKS -match '-\d' -or $CHUNKS -le '0') {
    $CHUNKS = Read-Host
    Write-Output ''

    if ($CHUNKS -notmatch '\d') {
        Write-Output 'Debes introducir numeros'
    } elseif ($CHUNKS -match '-\d' -or $CHUNKS -le '0') {
        Write-Output 'Debes introducir como minimo 1'
    }
}
cmd.exe /C "echo view-distance=$CHUNKS >> server.properties"

cmd.exe /C 'echo spawn-protection=0 >> server.properties'
cmd.exe /C 'echo max-tick-time=-1 >> server.properties'

(Get-Content server.properties).Replace(' ', '') | Set-Content server.properties

if ($CLIENT.Equals('forge')) {
    Write-Output 'Indica si vas a instalar el mod Biomes O Plenty. S/N'
    :mod while ($true) {
        $MOD = Read-Host
        Write-Output ''
        switch ($MOD.ToLower()) {
            s {
                if ($VERSION.Equals('1.17.1') -or $VERSION.Equals('1.17') -or $VERSION.Equals('1.16.5')) {
                    cmd.exe /C 'echo level-type=biomesoplenty >> server.properties'
                } else {
                    cmd.exe /C 'echo level-type=BIOMESOP >> server.properties'
                }
                break mod
            }
            n { break mod }
            default { Write-Output 'Opcion introducida incorrecta' }
        }
    }
}

Write-Output 'Establece un MOTD al servidor. Si no introduces nada, no meteras ningun MOTD'
$MOTD = Read-Host
cmd.exe /C "echo motd=$MOTD >> server.properties"
Clear-Host
Write-Output 'Servidor creado exitosamente'
Write-Output ''
Write-Output 'Esta es tu IP publica. Debes pasarsela a las personas que quieres que entren a tu servidor'
if ($PORT.Equals('25565')) {
    Invoke-WebRequest ifconfig.me | ForEach-Object {$_.Content}
} else {
    "$(Invoke-WebRequest ifconfig.me | ForEach-Object {$_.Content}):$PORT"
}
Write-Output 'Para iniciar el servidor, ejecuta el archivo start.bat'

Write-Output ''
Write-Output 'Pulsa cualquier tecla para salir'
Read-Host