#PPing
Function Port-Ping {
    param([Array]$hostlist,[Array]$ports,[Int]$timeout = "50")
    $ErrorActionPreference = "SilentlyContinue"
    $ping = new-object System.Net.NetworkInformation.Ping
    foreach ($ip in $hostlist) {
        $rslt = $ping.send($ip,$timeout)
        if (! $?){
            Write-Host "Host: $ip - not found" -ForegroundColor Red
        }
        else {
            if ($rslt.status.tostring() –eq “Success”) {
                write-host "Host: $ip - Ports: " -foregroundColor Green -NoNewline
                foreach ($port in $ports){
                    $socket = new-object System.Net.Sockets.TcpClient($ip, $port)
                    if ($socket –eq $null) {
                        write-host "$port," -ForegroundColor Red -NoNewline
                    }
                    else {
                        write-host "$port,"-foregroundcolor Green -NoNewline
                        $socket = $null
                    }
                }
            Write-Host
            }
            else {
                write-host "Host: $ip - down" -ForegroundColor Red
            }
        }
    }
    Write-Host ""
    $ping = $null
}