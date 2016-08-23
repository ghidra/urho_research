@echo OFF
setlocal EnableDelayedExpansion

SET URHOPATH=%1
SET URHOBUILD=%2

if NOT "%1"=="" (
  if NOT "%2"=="" (

    if exist "%URHOPATH%" (
      if exist "!URHOBUILD!" (

        Echo -----------------------

        Echo Launch dir: "%~dp0"
        Echo Current dir: "%CD%"
        Echo Passed in dir: "%1"
        Echo Passed in Build dir: "%2"

        Echo -----------------------

        SET "URHOBINPATH=!URHOBUILD!\bin\"
        SET "URHODATAPATH=!URHOBUILD!\Bin\Data\"
        SET "URHOCOREDATAPATH=!URHOPBUILD!\Bin\CoreData\"

        echo valid path "!URHOPATH!"
        echo bin: "!URHOBINPATH!"
        echo data: "!URHODATAPATH!"
        echo core: "!URHOCOREDATAPATH!"

        call:makeFolder "Research" "!URHOBINPATH!"

        for /D %%f in (*.*) do (
          SET FOLDER=%~dp0%%f
          ::http://stackoverflow.com/questions/17279114/split-path-and-take-last-folder-name-in-batch-script
          set MYDIR=!FOLDER:~0!
          for %%f in (!MYDIR!) do set myfolder=%%~nxf

          if "!myfolder!"=="Scripts" call:makeAlias "!myfolder!" "!FOLDER!" "!URHOBINPATH!\Research\!myfolder!"
          if "!myfolder!"=="RenderPaths" call:makeAlias "!myfolder!" "!FOLDER!" "!URHOBINPATH!\Research\!myfolder!"
          if "!myfolder!"=="Techniques" call:makeAlias "!myfolder!" "!FOLDER!" "!URHOBINPATH!\Research\!myfolder!"
          if "!myfolder!"=="Shaders" call:makeAlias "!myfolder!" "!FOLDER!" "!URHOBINPATH!\Research\!myfolder!"
          if "!myfolder!"=="Materials" call:makeAlias "!myfolder!" "!FOLDER!" "!URHOBINPATH!\Research\!myfolder!"
          if "!myfolder!"=="Models" call:makeAlias "!myfolder!" "!FOLDER!" "!URHOBINPATH!\Research\!myfolder!"

        )
        echo ***********************************
        echo editor script
        SET PROJECTPATH=%~dp0
        SET LAUNCH=!URHOBUILD!\bin\Urho3DPlayer.exe \Scripts\"%1".as -pp !URHOBUILD!\bin -p "CoreData;Data;Research"
        if exist "!PROJECTPATH!\launch.bat" (
          if 1==0 (
              echo !LAUNCH! > !PROJECTPATH!launch.bat
              echo           -launch.bat edited
            ) else (
              echo           "-launch.bat already exists"
            )
        ) else (
          echo. 2>!PROJECTPATH!launch.bat
          echo !LAUNCH! > !PROJECTPATH!launch.bat
          echo           -launch.bat created
        )

      ) else (
          echo invalid build path given "%URHOBUILD%"
      )
    ) else (
      echo invalid path given: "%URHOPATH%"
    )

  ) else (
    echo -----------------------
    echo second argument required, urho build path
  )
) else (
  echo "***********************************"
  echo no arguments given, please provide:
  echo      -urho source path
  echo      -urho build path
  echo "***********************************"
)

Echo -----------------------

GOTO:EOF

:makeAlias
if exist %~3 (
  echo %~3 already exists
) else (
  mklink /J %~3 %~2
)
GOTO:EOF

:makeFolder
if exist %~2%~1 (
  echo           -%~1 already exists
) else (
  mkdir %~2%~1
  echo           -%~1 created
)
GOTO:EOF