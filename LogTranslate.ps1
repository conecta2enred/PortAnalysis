# SCRIPT CONECTA2 EN RED #
# Traductor se encarga de tomar los datos del log de Control de RED generados por PortControl.ps1 para traducir las IP por su resolución de DNS y los procesos
# por el nombre de proceso al que pertenece.
# Si no reconoce la DNS lo indicará en el Script. En el caso de no resolver el nombre del proceso, quiere decir que en el momento de la ejecución del
# traductor este no estaba funcionando. Esta puede ser una alerta y es conveniente comprobar con más detalle este caso.

# Ruta del archivo de registro original. Modificar por lugar donde añadiste el log
$originalLogPath = "C:\Users\user\Desktop\log.log"

# Ruta del archivo de traducción. Modificar por lugar donde guardar el log de traducción
$traduccionLogPath = "C:\Users\user\Desktop\traduccion.log"

# Leer el contenido del archivo de registro original
$logContent = Get-Content -Path $originalLogPath

# Función para traducir la dirección IP a nombre de host
function Translate-IPAddress {
    param (
        [string]$IPAddress
    )

    try {
        $hostName = (Resolve-DnsName -Name $IPAddress).NameHost
        if ($hostName) {
            return $hostName
        } else {
            return "No Detectado DNS"
        }
    } catch {
        return "No Detectado DNS"
    }
}

# Función para obtener el nombre del proceso a partir del ID de proceso (PID)
function Get-ProcessName {
    param (
        [int]$PIDF
    )

    $process = Get-Process -Id $PIDF -ErrorAction SilentlyContinue
    if ($process) {
        return $process.ProcessName
    } else {
        return "Alerta Proceso No reconocido"
    }
}

# Inicializar el archivo de traducción. Si no queremos este valor, podemos comentar la siguiente linea.
$logContent[0..1] | Out-File -FilePath $traduccionLogPath

# Traducir y registrar las conexiones
for ($i = 4; $i -lt $logContent.Count; $i++) {
    if ($logContent[$i] -match '^  (TCP|UDP)\s+(\S+:\d+)\s+(\S+:\d+)\s+(\S+)\s+(\d+)$') {
        $protocol = $matches[1]
        $localAddress = $matches[2]
        $remoteAddress = $matches[3]
        $state = $matches[4]
        $pidn = $matches[5]

        $localAddressComponents = $localAddress -split ':'
        $remoteAddressComponents = $remoteAddress -split ':'

        $translatedLocalAddress = "$($localAddressComponents[0]):$($localAddressComponents[1])"
        $translatedRemoteAddress = "$($remoteAddressComponents[0]):$($remoteAddressComponents[1])"

        $translatedRemoteHostName = Translate-IPAddress -IPAddress $remoteAddressComponents[0]
        $processName = Get-ProcessName -PID $pidn

        #Podemos modificar el logentry para que muestre los valores que nos interesa.

        $logEntry = "$protocol ; $translatedLocalAddress ; $translatedRemoteAddress ; $state ; $pidn ; $translatedRemoteHostName ; $processName"
        $logEntry | Out-File -Append -FilePath $traduccionLogPath
    }elseif($logContent[$i] -match '^\s*(UDP)\s+((\[([^\]]+)\]|(\d+\.\d+\.\d+\.\d+)):(\d+))\s+(\S+)\s+(\d+)$'){
        #podemos añadir más valores de manera similar al control de TCP anterior.
        $protocol = $matches[1]
        $pidn = $matches[8]
        $processName = Get-ProcessName -PID $pidn
        #Podemos definir el logentry con los valores que queramos mostrar
        $logEntry = "$protocol ; $pidn ; $processName"
        $logEntry | Out-File -Append -FilePath $traduccionLogPath
    
    }else{
        $logContent[$i] | Out-File -Append -FilePath $traduccionLogPath
    }
}


Write-Output "Traducción completada."