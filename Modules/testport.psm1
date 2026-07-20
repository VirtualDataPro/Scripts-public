Function TestPort {
    Param(
        [parameter(ParameterSetName='ComputerName', Position=0)]
        [string]
        $ComputerName,

        [parameter(ParameterSetName='IP', Position=0)]
        [System.Net.IPAddress]
        $IPAddress,

        [Parameter(Position=1)]
		[ValidateRange(1,65535)]
		[Int[]]$Port = 3389,

        [parameter(Position=2)]
        [ValidateSet("TCP", "UDP")]
        [string]$Protocol = "TCP"
        )

    $RemoteServer = If ([string]::IsNullOrEmpty($ComputerName)) {$IPAddress} Else {$ComputerName};
	
    If ($Protocol -eq 'TCP')
    {
        $test = New-Object System.Net.Sockets.TcpClient;
        Try
        {
            Write-Host "Connecting to "$RemoteServer":"$Port" (TCP)..";
            $test.Connect($RemoteServer, $Port);
            Write-Host "Connection successful" -ForegroundColor Green;
        }
        Catch
        {
            Write-Host "Connection failed" -ForegroundColor Red;
        }
        Finally
        {
            $test.Dispose();
        }
    }

    If ($Protocol -eq 'UDP')
    {
        Write-Host "UDP port test functionality currently not available."
        <#
        $test = New-Object System.Net.Sockets.UdpClient;
        Try
        {
            Write-Host "Connecting to "$RemoteServer":"$Port" (UDP)..";
            $test.Connect($RemoteServer, $Port);
            Write-Host "Connection successful";
        }
        Catch
        {
            Write-Host "Connection failed";
        }
        Finally
        {
            $test.Dispose();
        }
        #>
    }
}