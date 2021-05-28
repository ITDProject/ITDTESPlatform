set TSDir=YourLocationToParentDirectortyOfAMES
set AMESDir=%TSDir%\AMES-V5.0\

cd %AMESDir%
call ant clean
call ant jar