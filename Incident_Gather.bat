@ECHO OFF 
ECHO ****** Information gathering      == ******
ECHO ******			   CSA Incidentes			      ******
ECHO ******  		Enero 2022		      ******
REM ****** @AUTHOR: Miguel Angel Martinez		      ******

SETLOCAL ENABLEDELAYEDEXPANSION
set localDEjec=%~d0%~p0
set StrName=%COMPUTERNAME%
set root=%localDEjec%\INC_CSA_%StrName%

mkdir %root%

REM ... Solo ejecutar si el equipo esta en linea
ECHO Capturando Conexiones...
netsh trace start capture=yes tracefile=%root%\netsh_%StrName%.etl

ECHO Consultando SID, Grupos, Privilegios...
WHOAMI /USER /GROUPS /CLAIMS /PRIV>> %root%\whoamiALL_%StrName%.txt

ECHO Consultando IP...
ipconfig /all>> %root%\ipconfig_%StrName%.txt

ECHO Consultando cuentas de Usuario...
net user>> %root%\netuser_%StrName%.txt

ECHO Consultando grupos locales...
net localgroup>> %root%\localgroup_%StrName%.txt

ECHO Consultando servicios Iniciados..
net start>> %root%\netstart_%StrName%.txt

ECHO Consultando Usuarios Locales
powershell -nop -c Get-LocalUser>> %root%\getlocaluser_%StrName%.txt

ECHO Consultando lista de tareas
tasklist>> %root%\tasklist_%StrName%.txt

ECHO Consultando lista de servicios...
tasklist /svc>> %root%\tasklistsvc_%StrName%.txt

ECHO Consultando procesos...
powershell -nop -c get-process>> %root%\getprocess_%StrName%.txt

ECHO Consultando todos los procesos
wmic process list full >> %root%\processfull_%StrName%.txt

ECHO Consultando nombre y id de proceso...
wmic process get name,parentprocessid,processid>> %root%\processname_%StrName%.txt

ECHO Consultando servicios
powershell -nop -c Get-Service>> %root%\getservice_%StrName%.txt

ECHO Consultando detalle servicios
sc query | more>> %root%\query_%StrName%.txt

ECHO Consultando cache DNS
sc query dnscache>> %root%\dnscache_%StrName%.txt

ECHO Consultando tareas
schtasks>> %root%\schtasks_%StrName%.txt

ECHO Consultando inicios de servicios...
wmic startup get caption,command>> %root%\startup_%StrName%.txt

ECHO Consultando Instancias
powershell -nop -c "$a=Get-CimInstance Win32_StartupCommand |Select-Object Name, command, Location, User| Format-List;$a">> %root%\ciminstance_%StrName%.txt

ECHO Consultando ejecuciones en registro...
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run>> %root%\queryhklm_%StrName%.txt

ECHO Consultando ejecuciones de usuario registro...
reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run>> %root%\queryhklmuser_%StrName%.txt

ECHO Consultando conexiones
netstat -ano>> %root%\netstat_%StrName%.txt

ECHO Consultando compartidos...
powershell -nop -c Get-SMBShare>> %root%\smbshare_%StrName%.txt

ECHO Consultando firewall...
netsh advfirewall firewall show rule name=all verbose>> %root%\firewall_%StrName%.txt

ECHO Consultando reglas firewall...
netsh firewall show config>> %root%\firewallconfig_%StrName%.txt

ECHO Consultando compartidos
net use>> %root%\netuse_%StrName%.txt

ECHO Compartidos y permisos
powershell -nop -c "get-smbshare -includehidden | Format-list -Property Name, Path, SecurityDescriptor" >> %root%\netsmbSD_%StrName%.txt

ECHO Buscando ProgramData BAT
powershell -nop -c "$days = 30; $Time= (Get-Date).adddays(-($Days)); get-psdrive -p "FileSystem" ` | % {write-host -f Green "Searching " $_.Root;get-childitem $_.Root -include *.bat -r ` | sort-object Length -descending}| where-object { $_.LastWriteTime -gt $Time}" >> %root%\archivos_bat_%StrName%.txt

ECHO Buscando ProgramData VBS
powershell -nop -c "$days = 30; $Time= (Get-Date).adddays(-($Days)); get-psdrive -p "FileSystem" ` | % {write-host -f Green "Searching " $_.Root;get-childitem $_.Root -include *.vbs -r ` | sort-object Length -descending}| where-object { $_.LastWriteTime -gt $Time}" >> %root%\archivos_vbs_%StrName%.txt

ECHO Buscando ProgramData BIN
powershell -nop -c "$days = 30; $Time= (Get-Date).adddays(-($Days)); get-psdrive -p "FileSystem" ` | % {write-host -f Green "Searching " $_.Root;get-childitem $_.Root -include *.bin -r ` | sort-object Length -descending}| where-object { $_.LastWriteTime -gt $Time}" >> %root%\archivos_bin_%StrName%.txt

ECHO Buscando ProgramData ps1
powershell -nop -c "$days = 30; $Time= (Get-Date).adddays(-($Days)); get-psdrive -p "FileSystem" ` | % {write-host -f Green "Searching " $_.Root;get-childitem $_.Root -include *.ps1 -r ` | sort-object Length -descending}| where-object { $_.LastWriteTime -gt $Time}" >> %root%\archivos_ps1_%StrName%.txt

ECHO Buscando ProgramData log
powershell -nop -c "$days = 30; $Time= (Get-Date).adddays(-($Days)); get-psdrive -p "FileSystem" ` | % {write-host -f Green "Searching " $_.Root;get-childitem $_.Root -include *.log -r ` | sort-object Length -descending}| where-object { $_.LastWriteTime -gt $Time}" >> %root%\archivos_log_%StrName%.txt

ECHO Consultando sesiones
net session>> %root%\sessione_%StrName%.txt

ECHO Consultando lista de logs...
powershell -nop -c "Get-EventLog -List">> %root%\eventlog_%StrName%.txt

ECHO VALIDAR DNS

ipconfig /registerdns>> %root%\RegDNS_%StrName%.txt

ECHO Extraer cache de DNS

powershell -nop -c "Get-DnsClientCache" >> %root%\DNS_Cache_%StrName%.txt

ECHO Validar los privilegios del usuario

whoami /priv>> %root%\priv_%StrName%.txt

ECHO Extraer Permisos sobre los compartidos

powershell -nop -c "Get-SmbShare |  Get-ACL -ErrorAction SilentlyContinue | Format-List" >> %root%\Permisos_Share_%StrName%.txt

ECHO Guardando Lista de Productos.

wmic product list full>> %root%\product_list_%StrName%.txt

ECHO Finalizando...
TIMEOUT /T 10 /NOBREAK > nul

ECHO Desconectando Consulta de Conexiones...
netsh trace stop


#ECHO Comprimiendo...
REM 7za a -r "%StrName%.zip" "%root%\"

rem del Incident_Gather.bat
rem del Incident_Gather.rar
del Incident_Gather.zip


