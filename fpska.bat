chcp 1251
@echo off &setlocal
setlocal enabledelayedexpansion

cls

(set \n=^
%=Do not remove this line=%
)

rem echo Line1!\n!Line2

CALL :Info_Message "fpska v0.5 - ������ ��� ������������ 50/60 FPS"

rem ============= init =============================
set fpska_home=%~dp0
set ffmpeg_threads=1
set method=slow
set ncpu=2
set container=""
set audio_codeck=""
set video_file=%~f2
set video_ext=%~x2
rem =================================================

FOR %%i IN ("%~f1") DO (
rem ECHO filedrive=%%~di
rem ECHO filepath=%%~pi
set video_file_name=%%~ni
rem ECHO fileextension=%%~xi
)

echo Fpska �������� �����: !fpska_home!
echo.
echo ������ ���� � �����:  !video_file! 
echo.

rem ===================== set nethod ================
if [%1]==[] (
set method=fast
) else (
set method=%1
)

if [%3]==[] (
set ncpu=4
) else (
set ncpu=%3
)

echo ����� ����������� � 50/60fps: !method!


if [!video_file!]==[] (
echo �� ������ ������� ��� �����
echo.
pause
exit
)

CALL :Check_Install

echo --------------------------------------------------------
echo [��� 1/5] ��������� ���������� � ����� � ����� ������� �� ����������
"!fpska_home!\ffmpeg\ffprobe.exe" -i "!video_file!" 1> NUL 2> "!fpska_home!ffprobe.log"
if %errorlevel%==0 (
	echo ���������� ��������� ������� � ���� "!fpska_home!\ffprobe.log"
	echo.
) else (
	echo ������ ���������� ����������
	pause
	exit
)

findstr /m /c:"Audio: aac" "!fpska_home!ffprobe.log" >NUL
if %errorlevel%==0 (
	set audio_codeck=aac
)

findstr /m /c:"Audio: mp3" "!fpska_home!ffprobe.log" >NUL
if %errorlevel%==0 (
	set audio_codeck=mp3
)
findstr /m "matroska" "!fpska_home!ffprobe.log" >NUL
if %errorlevel%==0 (
	set container=mkv
)

findstr /m /c:"Video: h264" "!fpska_home!ffprobe.log" >NUL
if %errorlevel%==0 (
	set container=mp4
)

findstr /m /c:"mov,mp4,m4a,3gp,3g2,mj2" "!fpska_home!ffprobe.log" >NUL
if %errorlevel%==0 (
	set container=mp4
)

findstr /m /c:"mpegts" "!fpska_home!ffprobe.log" >NUL
if %errorlevel%==0 (
	set container=mpegts
)

findstr /m /c:"avi," "!fpska_home!ffprobe.log" >NUL
if %errorlevel%==0 (
	set container=avi
)

echo ���������� � ����������:
echo ��������� ��������� ����������: !container!
echo �������� ������� � �������: !audio_codeck!
echo.
rem echo --------------------------------------------------------


rmdir /S/Q "!fpska_home!tmp"
mkdir "!fpska_home!tmp"

@echo off


echo ����� ������ �����������
echo %time%
echo.

echo [��� 2/5] ��������� �������� ������� �� ��������� ����������
if "!container!"=="mp4" (
 if "!audio_codeck!"=="aac" ( 
"!fpska_home!ffmpeg\ffmpeg.exe" -y -i !video_file! -vn -acodec copy "!fpska_home!\tmp\60fps_audio.aac" -v quiet
)
)

if "!container!"=="avi" (
 if "!audio_codeck!"=="mp3" ( 
"!fpska_home!ffmpeg\ffmpeg.exe" -y -i !video_file! -vn -acodec copy "!fpska_home!\tmp\60fps_audio.mp3" -v quiet
)
)

if "!container!"=="mkv" (
copy "!video_file!" "!fpska_home!\tmp"
cd "!fpska_home!\tmp"

"!fpska_home!eac3to\eac3to.exe" "!fpska_home!\tmp\!video_file_name!!video_ext!" -demux
del "!fpska_home!\tmp\!video_file_name!!video_ext!" 
del "!fpska_home!\tmp\*.txt"
del "!fpska_home!\tmp\*.h264"
del "!fpska_home!\tmp\*.vc1"

cd "!fpska_home!"

)

if "!container!"=="mpegts" (
copy "!video_file!" "!fpska_home!\tmp"
cd "!fpska_home!\tmp"

"!fpska_home!eac3to\eac3to.exe" "!fpska_home!\tmp\!video_file_name!!video_ext!" -demux
del "!fpska_home!\tmp\!video_file_name!!video_ext!" 
del "!fpska_home!\tmp\*.txt"
del "!fpska_home!\tmp\*.h264"
del "!fpska_home!\tmp\*.vc1"

cd "!fpska_home!"

)

if %errorlevel%==0 (
	echo �������� ������� ��������� �������
	echo.
) else (
	echo ������ ���������� �������� �������
	pause
	exit
)


echo [��� 3/5] ������� ������ ��� Avisynth �� �������

if "!method!"=="slow" (
copy "!fpska_home!\scripts\fpska_slow.avs" "!fpska_home!\scripts\work.avs" >NUL
) else if "!method!"=="medium" (
copy "!fpska_home!\scripts\fpska_medium.avs" "!fpska_home!\scripts\work.avs" >NUL
) else if "!method!"=="fast" (
copy "!fpska_home!\scripts\fpska_fast.avs" "!fpska_home!\scripts\work.avs" >NUL
)
set "search=fullhd.mkv"
set "search_threads=nthreads"
set "replace=!video_file!"
set "threads=!ncpu!"

set "textfile=!fpska_home!\scripts\work.avs"
set "newfile=!fpska_home!\scripts\tmp.txt"

(for /f "delims=" %%i in (%textfile%) do (
    set "line=%%i"
    set "line=!line:%search%=%replace%!"
    set "line=!line:%search_threads%=%threads%!"
    echo(!line!
))>"%newfile%"
del "!fpska_home!\scripts\work.avs"
ren "!fpska_home!\scripts\tmp.txt" "work.avs"

if exist "!fpska_home!scripts\work.avs" (
	echo ������ ��� Avisynth ������ �������
	echo.
) else (
	echo ������ �������� Avisynth �������
	pause
	exit
)

echo [��� 4/5] ������� ����� � �������� 50/60fps
if "!method!"=="slow" (
"!fpska_home!\ffmpeg\ffmpeg.exe" -y -i "!fpska_home!\scripts\work.avs" -c:a copy -c:v libx264 -crf 20 -preset slow "!fpska_home!tmp\60fps_video.mp4" -v quiet -stats
) else if "!method!"=="medium" (
"!fpska_home!\ffmpeg\ffmpeg.exe" -y -i "!fpska_home!\scripts\work.avs" -c:a copy -c:v libx264 -crf 24 -preset slow "!fpska_home!tmp\60fps_video.mp4" -v quiet -stats
) else if "!method!"=="fast" (
"!fpska_home!\ffmpeg\ffmpeg.exe" -y -i "!fpska_home!\scripts\work.avs" -c:a copy -c:v libx264 -crf 28 -preset fast "!fpska_home!tmp\60fps_video.mp4" -v quiet -stats
)

echo.

if %errorlevel%==0 (
	echo ����� � �������� 50/60fps c������ ������� "!fpska_home!tmp\60fps_video.mp4"
	echo.
) else (
	echo ������ �������� ����� � �������� 50/60fps
	pause
	exit
)

echo [��� 5/5] ��������� ����� � �������� �������
for %%i in ("!fpska_home!tmp\*.*") do set str=!str! "%%i"

"!fpska_home!\mkvtoolnix\mkvmerge.exe" !str! -o "!video_file!_fpska_60fps.mkv" >NUL
if %errorlevel%==0 (
	echo ����� � �������� ������� ���������� �������
	echo.
) else (
	echo ������ ��� ����������� ����� � �������� �������
	pause
	exit
)

del !fpska_home!\ffprobe.log >NUL

endlocal
echo �������������� ��������� ����� � ������ 50/60fps ���������
echo %time%
echo.
echo --------------------------------------------------------
echo.
echo ��������� � ������� 50/60fps: !video_file!_fpska_60fps.mkv
pause


:Info_Message
echo --------------------------------------------------------
echo. 
echo %~1
echo. 
echo --------------------------------------------------------
EXIT /B 0

:Check_Install

set not_installed=0

if not exist "!fpska_home!eac3to\eac3to.exe" (
	echo eac3to �� �����������, ��������� setup.bat �� Administrator
	set not_installed=1
)

if not exist "!fpska_home!ffmpeg\ffmpeg.exe" (
	echo ffmpeg �� ����������, ��������� setup.bat �� Administrator
	set not_installed=1
)

if not exist "!fpska_home!mkvtoolnix\mkvmerge.exe" (
	echo mkvtoolnix �� �����������, ��������� setup.bat �� Administrator
	set not_installed=1
)

if not exist "!fpska_home!svpflow\svpflow1.dll" (
	echo svpflow �� �����������, ��������� setup.bat �� Administrator
	set not_installed=1
)

if "!not_installed!"=="1" (
	pause
	exit
)

EXIT /B 0
