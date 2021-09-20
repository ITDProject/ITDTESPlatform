set TSDir=C:\Users\swathi\Dropbox\ITDTESPlatform
set TDIDir=C:\Users\swathi\Dropbox\ITDTESPlatform\TDInterconnection
set DSDir=C:\Users\swathi\Dropbox\ITDTESPlatform\DistributionSystem

set AmesVersion=AMES-V5.1
set AMESDir=%TSDir%\%AmesVersion%
set fncsLibDir=%AMESDir%\fncsDependencies

set DistFeederDir=%DSDir%\feeder\IEEE123
set DSInputFilesDir=%DSDir%\inputFiles
set DSJsonFilesDir=%DSInputFilesDir%\jsonFiles
set DSYAMLFilesDir=%DSInputFilesDir%\yamlFiles

set ForecastDir=%TDIDir%\forecast
set YAMLFilesDir=%TDIDir%\yamlFiles
set OutputFilesDir=%TDIDir%\outputFiles
set LogFilesDir=%OutputFilesDir%\logFiles
set PlotFilesDir=%OutputFilesDir%\plotFiles

set Param=MaxDay

for /f "tokens=1,2" %%a in (%AMESDir%/DATA/%1.dat) do ( if %%a==%Param% set MaxDay=%%b )

set Param=RTOPDur

for /f "tokens=1,2" %%a in (%AMESDir%/DATA/%1.dat) do ( if %%a==%Param% set RTOPDur=%%b )

set "NHour=4"
set "deltaT=300"
set "NoOfHouseholds=927"
set "NDistSys=1"
set "FileName=IEEE123Grid"
set /a "tmax=%MaxDay%*86400+%NHour%*3600"
set /a "NoOfProcesses=%NoOfHouseholds%+%NDistSys%+2+2"

set "C=2"
REM choose 0 for FRP, 1 for PR, 2 for LF 

set "FRP=12"
set "PL=5000"
set "TPLR=500"
set "RefLoad=1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500"

md %OutputFilesDir% 2> nul
md %LogFilesDir% 2> nul
md %PlotFilesDir% 2> nul


cd %AMESDir%

set FNCS_FATAL=no
set FNCS_LOG_STDOUT=yes
set FNCS_TRACE=no
set FNCS_LOG_LEVEL=DEBUG2
set FNCS_CONFIG_FILE=%YAMLFilesDir%/ames.yaml
start /b cmd /c java -jar -Djava.library.path=%fncsLibDir% "%AMESDir%/dist/%AmesVersion%.jar"^ > %LogFilesDir%/ames.log 2^>^&1


cd %TDIDir%

set FNCS_CONFIG_FILE=%YAMLFilesDir%/NetLoadForecastDAM.yaml
set FNCS_LOG_LEVEL=
start /b cmd /c python %ForecastDir%/NetLoadForecastDAM.py %tmax% %RTOPDur% ^>%LogFilesDir%/NetLoadForecastDAM.log 2^>^&1

set FNCS_CONFIG_FILE=%YAMLFilesDir%/NetLoadForecastRTM.yaml
set FNCS_LOG_LEVEL=
start /b cmd /c python %ForecastDir%/NetLoadForecastRTM.py %tmax% %RTOPDur% ^>%LogFilesDir%/NetLoadForecastRTM.log 2^>^&1

set FNCS_LOG_LEVEL=DEBUG2
start /b cmd /c fncs_broker %NoOfProcesses% ^>%LogFilesDir%/broker.log 2^>^&1

cd %DSDir%

set FNCS_LOG_LEVEL=
set FNCS_CONFIG_FILE=%DSYAMLFilesDir%/IDSO.yaml
start /b cmd /c python ./IDSO/IDSO.py %DSJsonFilesDir%/IDSO_registration.json %tmax% %deltaT% %NDistSys% %C% %FRP% %PL% %TPLR% %RefLoad% ^>%LogFilesDir%/IDSO.log 2^>^&1

set FNCS_LOG_LEVEL=DEBUG2
FOR /L %%i IN (1,1,%NDistSys%) DO start /b cmd /c gridlabd %DSInputFilesDir%/%FileName%Modified%%i.glm ^>%LogFilesDir%/gridlabd%%i.log 2^>^&1

set FNCS_LOG_LEVEL=
runHouseholds927.bat