# SCRIPT CONECTA2 EN RED #
# Control de Red analiza mediante Netstat durante un periodo de tiempo las conexiones del equipo para encontrar una conexion no identificada que pueda
# pertenecer a Bot-net/malware en el sistema.

# Path donde guardar el log. Utiliza tu ruta.
$filePath = "C:\Users\user\Desktop\log.log"

# Netstat
$initialConnections = netstat -ano

# Inicializar la lista de conexiones anteriores
$lastConnections = $initialConnections

# Log Register Primer Netstat
$initialConnections | Out-File -Append -FilePath $filePath

# Bucle for para ejecutar el comando durante 20 segundos. Puedes cambiar el valor 20 de -le
# para poner más o menos tiempo.
for ($i = 1; $i -le 20; $i++) {
    # Obtener las conexiones actuales
    $currentConnections = netstat -ano

    # Determinar conexiones añadidas y quitadas
    $addedConnections = Compare-Object -ReferenceObject $lastConnections -DifferenceObject $currentConnections -PassThru
    $removedConnections = Compare-Object -ReferenceObject $currentConnections -DifferenceObject $lastConnections -PassThru

    # Registrar tiempo de consulta
    Write-Output "Segundo $i" | Out-File -Append -FilePath $filePath

    # Registrar conexiones añadidas
    if ($addedConnections.Count -gt 0) {
        Write-Output "Direcciones añadidas:" | Out-File -Append -FilePath $filePath
        $addedConnections | Out-File -Append -FilePath $filePath
    }

    # Registrar conexiones quitadas
    if ($removedConnections.Count -gt 0) {
        Write-Output "Direcciones quitadas:" | Out-File -Append -FilePath $filePath
        $removedConnections | Out-File -Append -FilePath $filePath
    }

    # Actualizar la lista de conexiones anteriores
    $lastConnections = $currentConnections

    # Esperar 1 segundo antes de la próxima iteración
    Start-Sleep -Seconds 1
}

# Bucle for para analizar cada minuto hasta 10 minutos. Puedes cambiar el valor
# -le para añadir más tiempo
for ($j = 1; $j -le 10; $j++) {
    # Esperar 1 minuto antes de la próxima iteración
    Start-Sleep -Seconds 60

    # Obtener las conexiones actuales
    $currentConnections = netstat -ano

    # Registrar tiempo de consulta
    Write-Output "Minuto $j" | Out-File -Append -FilePath $filePath

    # Determinar conexiones añadidas y quitadas
    $addedConnections = Compare-Object -ReferenceObject $lastConnections -DifferenceObject $currentConnections -PassThru
    $removedConnections = Compare-Object -ReferenceObject $currentConnections -DifferenceObject $lastConnections -PassThru

    # Registrar conexiones añadidas
    if ($addedConnections.Count -gt 0) {
        Write-Output "Direcciones añadidas:" | Out-File -Append -FilePath $filePath
        $addedConnections | Out-File -Append -FilePath $filePath
    }

    # Registrar conexiones quitadas
    if ($removedConnections.Count -gt 0) {
        Write-Output "Direcciones quitadas:" | Out-File -Append -FilePath $filePath
        $removedConnections | Out-File -Append -FilePath $filePath
    }

    # Actualizar la lista de conexiones anteriores
    $lastConnections = $currentConnections
}

Write-Output "Registro completado."