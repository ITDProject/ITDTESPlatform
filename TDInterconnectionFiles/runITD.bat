set TSDir=YourLocationToParentDirectortyOfAMES
set TDIDir=YourLocationToTDInterconnectionFiles
set DSDir=YourLocationToHouseholdFormulationRepository
set AmesVersion=AMES-V5.0
set AMESDir=%TSDir%\%AmesVersion%
set fncsLibDir=%AMESDir%\fncsDependencies
set logfilesdir=%TDIDir%\logfiles
set plotfilesdir=%DSDir%\plotfiles
set outputfilesdir=%DSDir%\output
set HouseWelfareCalDir=%DSDir%\HouseWelfareCal


set Param=MaxDay

for /f "tokens=1,2" %%a in (%AMESDir%/DATA/%1.dat) do ( if %%a==%Param% set MaxDay=%%b )

rem set "NDay=2"
set "NHour=4"
set "deltaT=300"
set "NoOfHouses=4"
set "NDSystems=1"
set /a "tmax=%MaxDay%*86400+%NHour%*3600"
set /a "NoOfProcesses=%NoOfHouses%+%NDSystems%+2+2"

set "C=0"
rem choose 0 for FRP, 1 for PR, 2 for LF 

set "FRP=10"
set "PL=5000"
set "TPLR=500"
set "RefLoad=1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500 1500"

md %logfilesdir% 2> nul
md %plotfilesdir% 2> nul
md %outputfilesdir% 2> nul
md %HouseWelfareCalDir% 2> nul


cd %AMESDir%

set FNCS_FATAL=no
set FNCS_LOG_STDOUT=yes
set FNCS_LOG_LEVEL=DEBUG4
set FNCS_TRACE=no
set FNCS_CONFIG_FILE=%TDIDir%/YamlFiles/ames.yaml
start /b cmd /c java -jar -Djava.library.path=%fncsLibDir% "%AMESDir%\dist\%AmesVersion%.jar"^ > %logfilesdir%/ames.log 2^>^&1


cd %TDIDir%

set FNCS_CONFIG_FILE=%TDIDir%/YamlFiles/NetLoadForecastDAM.yaml
set FNCS_LOG_LEVEL=DEBUG4
start /b cmd /c python NetLoadForecastDAM.py %tmax% 1 ^>%logfilesdir%/NetLoadForecastDAM.log 2^>^&1

set FNCS_CONFIG_FILE=%TDIDir%/YamlFiles/NetLoadForecastRTM.yaml
set FNCS_LOG_LEVEL=
start /b cmd /c python NetLoadForecastRTM.py %tmax% 1 ^>%logfilesdir%/NetLoadForecastRTM.log 2^>^&1

cd %DSDir%

set FNCS_LOG_LEVEL=DEBUG2
set FNCS_TRACE=NO
start /b cmd /c fncs_broker %NoOfProcesses% ^>%logfilesdir%/broker.log 2^>^&1

set FNCS_LOG_LEVEL=
set FNCS_CONFIG_FILE=%TDIDir%/YamlFiles/IDSO.yaml
start /b cmd /c python IDSO.py input/IDSO_registration.json %tmax% %deltaT% %NDSystems% %C% %FRP% %PL% %TPLR% %RefLoad% ^>%logfilesdir%/IDSO.log 2^>^&1

set FNCS_LOG_LEVEL=DEBUG2
FOR /L %%i IN (1,1,%NDSystems%) DO start /b cmd /c gridlabd IEEE123Modified%%i.glm ^>%logfilesdir%/gridlabd%%i.log 2^>^&1

set FNCS_LOG_LEVEL=
runHouseholds927.bat
