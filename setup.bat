@echo OFF
setlocal EnableDelayedExpansion

Echo -----------------------

Echo Launch dir: "%~dp0"
Echo Current dir: "%CD%"
Echo Passed in dir: "%1"

SET URHOPATH=%1

if exist "%URHOPATH%" (
  SET "URHOBINPATH=!URHOPATH!\Bin\"
  SET "URHODATAPATH=!URHOPATH!\Bin\Data\"
  SET "URHOCOREDATAPATH=!URHOPATH!\Bin\CoreData\"

  echo valid path "!URHOPATH!"
  echo bin: "!URHOBINPATH!"
  echo data: "!URHODATAPATH!"
  echo core: "!URHOCOREDATAPATH!"

  for /D %%f in (*.*) do (
    SET FOLDER=%~dp0%%f
    ::http://stackoverflow.com/questions/17279114/split-path-and-take-last-folder-name-in-batch-script
    set MYDIR=!FOLDER:~0!
    for %%f in (!MYDIR!) do set myfolder=%%~nxf

    if "!myfolder!"=="Scripts" call:makeAlias "!myfolder!" "!FOLDER!" "!URHODATAPATH!!myfolder!\research"
    if "!myfolder!"=="RenderPaths" call:makeAlias "!myfolder!" "!FOLDER!" "!URHOCOREDATAPATH!!myfolder!\research"
    if "!myfolder!"=="Techniques" call:makeAlias "!myfolder!" "!FOLDER!" "!URHOCOREDATAPATH!!myfolder!\research"
    if "!myfolder!"=="Shaders" call:makeAlias "!myfolder!" "!FOLDER!" "!URHODATAPATH!!myfolder!\research"
    if "!myfolder!"=="Materials" call:makeAlias "!myfolder!" "!FOLDER!" "!URHODATAPATH!!myfolder!\research"
    if "!myfolder!"=="Models" call:makeAlias "!myfolder!" "!FOLDER!" "!URHODATAPATH!!myfolder!\research"

  )

) else (
  echo invalid path given: "%URHOPATH%"
)

Echo -----------------------

GOTO:EOF

:makeAlias
mklink /J %~3 %~2
GOTO:EOF
