@echo OFF
setlocal enabledelayedexpansion

Echo Launch dir: "%~dp0"
Echo Current dir: "%CD%"

Echo Passed in dir: "%1"

for /D %%f in (*.*) do (
  set FOLDER=%~dp0%%f
  if "%%f"=="Scripts" (
    set NEWFOLDER = %1\Bin\Data\research
    if exist NEWFOLDER (
      echo Scripts Folder already exists
    ) else (
      echo we need to make link !NEWFOLDER!
    )
  ) else (
    set NEWFOLDER = %1\Bin\Extra\%%f
    if exist NEWFOLDER (
      echo !FOLDER! already exist
    ) else (
      echo we need to make !NEWFOLDER!
    )
  )

)
