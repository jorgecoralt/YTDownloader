@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"
title YouTube Downloader - Instalador simple

rem --- CONFIGURACION ---
set "BASE_DIR=%~dp0"
set "YTDLP_EXE=yt-dlp.exe"
set "YTDLP_URL=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
set "OUTPUT_DIR=%BASE_DIR%downloads"
set "TEMP_DIR=%BASE_DIR%temp_zips"

set "FFMPEG_DIR=%BASE_DIR%ffmpeg"
set "FFMPEG_ZIP=%BASE_DIR%ffmpeg.zip"
set "FFMPEG_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

rem --- CREAR CARPETAS NECESARIAS ---
if not exist "%OUTPUT_DIR%" md "%OUTPUT_DIR%"
if not exist "%TEMP_DIR%" md "%TEMP_DIR%"

rem --- DESCARGAR yt-dlp SI FALTA ---
if not exist "%BASE_DIR%%YTDLP_EXE%" (
  echo Descargando yt-dlp.exe...
  curl -L "%YTDLP_URL%" -o "%BASE_DIR%%YTDLP_EXE%"
)

rem --- INSTALAR FFMPEG LOCAL EN /ffmpeg/bin/ ---
if exist "%FFMPEG_DIR%" (
  for /r "%FFMPEG_DIR%" %%F in (ffmpeg.exe) do (
    echo FFmpeg ya esta instalado en: %%F
    set "FFMPEG_BIN=%%~dpF"
    goto :ffmpeg_encontrado
  )
)

echo Descargando FFmpeg...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%FFMPEG_URL%' -OutFile '%FFMPEG_ZIP%' -UseBasicParsing"

echo Extrayendo archivos...
powershell -Command "Expand-Archive -Path '%FFMPEG_ZIP%' -DestinationPath '%FFMPEG_DIR%' -Force"
del "%FFMPEG_ZIP%"

rem Buscar carpeta extraida tipo ffmpeg-xxxx
setlocal enabledelayedexpansion
for /d %%D in ("%FFMPEG_DIR%\ffmpeg-*") do (
    set "FFMPEG_BIN=%%D\bin"
)
endlocal & set "FFMPEG_BIN=%FFMPEG_BIN%"

if not exist "%FFMPEG_BIN%\ffmpeg.exe" (
    echo ERROR: No se encontro ffmpeg.exe en %FFMPEG_BIN%
    pause
    exit /b
)

:ffmpeg_encontrado
set "PATH=%PATH%;%FFMPEG_BIN%"
echo FFmpeg listo.

rem --- PEDIR URL ---
echo.
set /p "URL=Escribe o pega la URL de YouTube: "
if "%URL%"=="" (
  echo No se ingreso ninguna URL.
  pause
  exit /b
)

rem --- DESCARGAR VIDEO/AUDIO ---
echo.
echo Iniciando descarga...

"%BASE_DIR%%YTDLP_EXE%" ^
-f "bv*[height=1080]+ba/best" ^
--merge-output-format mp4 ^
-o "%OUTPUT_DIR%\%%(title)s.%%(ext)s" ^
"%URL%"

echo.
echo Descarga finalizada.
echo Archivo guardado en: %OUTPUT_DIR%
pause
popd
endlocal
