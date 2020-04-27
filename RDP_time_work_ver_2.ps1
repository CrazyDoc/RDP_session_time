$startDate = [DateTime]::Today #(get-date).AddDays(-1)

$LogON = Get-EventLog -LogName Security -after $startDate|

    ?{(4624) -contains $_.EventID -and $_.Message -match 'Тип входа:\s\s'}|

    where {$_.ReplacementStrings[3] -eq '0x0' -and $_.ReplacementStrings[18] -ne ('::1') -and $_.ReplacementStrings[18] -ne ('-') -and $_.Message -notlike "*уничтожении*" }|

    %{([PSCustomObject]@{
        Time = $_.TimeGenerated
        ClientIP = $_.Message -replace '(?smi).*Сетевой адрес источника:\s+([^\s]+)\s+.*','$1'
        UserName = $_.ReplacementStrings[5]
        UserDomain = $_.Message -replace '(?smi).*Домен учетной записи:\s+([^\s]+)\s+.*','$1'
        LogonType = $_.Message -replace '(?smi).*Тип входа:\s+([^\s]+)\s+.*','$1'
        }
    )} | 

    sort Time -Unique |Select Time, ClientIP, UserName, LogonType

$LogON | Select Time, ClientIP, UserName, LogonType

$idList = New-Object System.Collections.ArrayList

foreach ($elem in $LogON)
    {
    if ($idList -contains $elem.UserName)
        {}
        else {$idList.Add([Tuple]::Create($elem.UserName))}
    }

$LogOFF = Get-EventLog -LogName Security -after $startDate|

    ?{(4634) -contains $_.EventID -and $_.Message -like "*уничтожении*" -and $_.Message -notlike '*Тип входа:*7*' -and $_.Message -notlike '*Тип входа:*10*'}|

    where {$_.ReplacementStrings[1] -in $idList.Item1}|

    %{([PSCustomObject]@{
        Time = $_.TimeGenerated
        UserName = $_.ReplacementStrings[1]
        LogonType = $_.Message -replace '(?smi).*Тип входа:\s+([^\s]+)\s+.*','$1'
        })} |
         
    sort Time -Unique |Select Time, UserName, LogonType

$LogOFF | Select Time, ClientIP, UserName, LogonType

foreach($username in $idList)
    {
    $username.Item1

    $on = $LogON | where {$_.UserName -in $username.Item1}

    $off = $LogOFF | where {$_.UserName -in $username.Item1}

    $on
    $off
    if ($on.count -gt 0 -and $off.count -gt 0 )
        {
        $c = Compare-Object $on $off -Property Time -IncludeEqual -ExcludeDifferent

        $on = $on | where {$_.Time -notin $c.Time}

        $off = $off | where {$_.Time -notin $c.Time}

        $name = [string]$username.Item1

        $wtime = 0

        foreach ($time in $on | Select Time)
            {
            foreach ($ctime in $off | Select Time)
                {
                if ($time.Time -lt $ctime.Time)
                    {
                    $wtime = $wtime + ($ctime.Time.TimeOfDay - $time.Time.TimeOfDay)

                    $on = $on | where {$_.Time -notin $time.Time}

                    $off = $off | where {$_.Time -notin $ctime.Time}

                    break
                    }
                }
            }

        $FilteredOutput = ([PSCustomObject]@{
            Name = $name
            WorkTime = $wtime
            })
		
		$Date = (Get-Date -Format s) -replace ":", "."
		
        $FilePath = "c:\Temp\$Date'_RDP_time_work.csv"
		
		$isfile = Test-Path $FilePath
		if($isfile -eq "True") 
			{
			Remove-Item -Path $FilePath
			}
			
        $FilteredOutput | Sort Name | Export-Csv $FilePath -NoTypeInformation -append
        }
    else{write-host $username.Item1}

    }

