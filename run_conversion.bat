@echo off
setlocal

:: Check and assign parameters
set "IFC_FILE=%~1"
set "EPW_FILE=%~2"
set "EPLUS_PATH=%~3"

if "%IFC_FILE%"=="" (
    echo [ERROR] Please provide the path to the IFC file as the first argument.
    exit /b 1
)
if "%EPW_FILE%"=="" (
    echo [ERROR] Please provide the path to the EPW file as the second argument.
    exit /b 1
)
if "%EPLUS_PATH%"=="" set "EPLUS_PATH=/usr/local/EnergyPlus-9-4-0/"

:: Extract filenames
for %%F in ("%IFC_FILE%") do set "IFC_NAME=%%~nxF"
for %%F in ("%IFC_FILE%") do set "IFC_BASE=%%~nF"
for %%F in ("%EPW_FILE%") do set "EPW_NAME=%%~nxF"

:: Start container
docker run -dit --name ep epone

:: Copy files into container
docker cp "%IFC_FILE%" ep:/tmp/
docker cp "%EPW_FILE%" ep:/tmp/

:: Run script
docker exec ep micromamba run -n base python /home/mambauser/bim2sim/bim2sim/convert_to_idf.py /tmp/%IFC_NAME% /tmp/%EPW_NAME% %EPLUS_PATH%

:: Find the folder inside /tmp starting with "gensim"
for /f "delims=" %%G in ('docker exec ep sh -c "ls -d /tmp/gensim* 2>/dev/null"') do set "GENSIM_DIR=%%G"

:: Compose the full path inside container
set "IDF_CONTAINER_PATH=%GENSIM_DIR%/export/EnergyPlus/SimResults/%IFC_BASE%/%IFC_BASE%.idf"

:: Local path to save the IDF
for %%F in ("%IFC_FILE%") do set "IFC_FOLDER=%%~dpF"
set "LOCAL_IDF_PATH=%IFC_FOLDER%%IFC_BASE%.idf"

:: Copy the file back
docker cp ep:%IDF_CONTAINER_PATH% "%LOCAL_IDF_PATH%"

echo Copied IDF file from %IDF_CONTAINER_PATH% to %LOCAL_IDF_PATH%

endlocal
pause
