set TSDir=C:\Users\swathi\Dropbox\ITDTESPlatform
set TDIDir=C:\Users\swathi\Dropbox\ITDTESPlatform\TDInterconnection
set DSDir=C:\Users\swathi\Dropbox\ITDTESPlatform\DistributionSystem

set AmesVersion=AMES-V5.0X
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

set "NHour=4"
set "deltaT=300"
set "NoOfHouses=4"
set "NDistSys=1"
set "DistFeederFileName=IEEE123Feeder"
set /a "tmax=%MaxDay%*86400+%NHour%*3600"
set /a "NoOfProcesses=%NoOfHouses%+%NDistSys%+2+2"

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
start /b cmd /c python %ForecastDir%/NetLoadForecastDAM.py %tmax% %deltaT% ^>%LogFilesDir%/NetLoadForecastDAM.log 2^>^&1

set FNCS_CONFIG_FILE=%YAMLFilesDir%/NetLoadForecastRTM.yaml
set FNCS_LOG_LEVEL=
start /b cmd /c python %ForecastDir%/NetLoadForecastRTM.py %tmax% %deltaT% ^>%LogFilesDir%/NetLoadForecastRTM.log 2^>^&1

set FNCS_LOG_LEVEL=DEBUG2
start /b cmd /c fncs_broker %NoOfProcesses% ^>%LogFilesDir%/broker.log 2^>^&1

cd %DSDir%

set FNCS_LOG_LEVEL=
set FNCS_CONFIG_FILE=%DSYAMLFilesDir%/IDSO.yaml
start /b cmd /c python ./IDSO/IDSO.py %DSJsonFilesDir%/IDSO_registration.json %tmax% %deltaT% %NDistSys% %C% %FRP% %PL% %TPLR% %RefLoad% ^>%LogFilesDir%/IDSO.log 2^>^&1

set FNCS_LOG_LEVEL=DEBUG2
FOR /L %%i IN (1,1,%NDistSys%) DO start /b cmd /c gridlabd %DSInputFilesDir%/%DistFeederFileName%Modified%%i.glm ^>%LogFilesDir%/gridlabd%%i.log 2^>^&1

set FNCS_LOG_LEVEL=
REM runhouses27.bat
start /b cmd /c python ./household/houseController.py ./inputFiles/jsonFiles/controller_registration_house_1A_1_thermostat_controller.json %tmax% %deltaT% ^>%logfilesdir%/house_1A_1.log 2^>^&1
start /b cmd /c python ./household/houseController.py ./inputFiles/jsonFiles/controller_registration_house_1A_2_thermostat_controller.json %tmax% %deltaT% ^>%logfilesdir%/house_1A_2.log 2^>^&1
start /b cmd /c python ./household/houseController.py ./inputFiles/jsonFiles/controller_registration_house_1A_3_thermostat_controller.json %tmax% %deltaT% ^>%logfilesdir%/house_1A_3.log 2^>^&1
start /b cmd /c python ./household/houseController.py ./inputFiles/jsonFiles/controller_registration_house_1A_4_thermostat_controller.json %tmax% %deltaT% ^>%logfilesdir%/house_1A_4.log 2^>^&1
