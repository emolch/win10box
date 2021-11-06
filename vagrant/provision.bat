@echo off
cd "%UserProfile%"

echo Get VisualStudio build tools installer
curl -SL --output vs_buildtools.exe https://aka.ms/vs/15/release/vs_buildtools.exe

echo Install VisualStudio build tools...
start /w vs_buildtools.exe --quiet --wait --norestart --nocache ^
    --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools" ^
    --add Microsoft.VisualStudio.Workload.MSBuildTools ^
    --add Microsoft.VisualStudio.Workload.VCTools ^
    --includeRecommended

echo Install VisualStudio build tools (done)
cd "%UserProfile%"

if not exist "%UserProfile%\miniconda3.exe" (
    echo Downloading conda installer...
    call curl "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -o "%UserProfile%\miniconda3.exe" -s
) else (
    echo Conda installer already downloaded.
)

if not exist "%UserProfile%\miniconda3" (
    echo Installing conda...
    call "%UserProfile%\miniconda3.exe" /InstallationType=JustMe /S /D="%UserProfile%\miniconda3"

    echo Installing conda modules needed by Pyrocko...
    call "%UserProfile%\miniconda3\Scripts\activate.bat"
    call conda install -y m2-libiconv m2-libintl m2-vim m2-bash m2-tar m2-gzip m2-patch git 
) else (
    echo Conda is already installed, activating...
    call "%UserProfile%\miniconda3\Scripts\activate.bat"
)

call conda init
