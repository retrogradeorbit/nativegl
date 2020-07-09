Rem @echo off

Rem set GRAALVM_HOME=C:\Users\IEUser\Downloads\graalvm\graalvm-ce-java11-20.1.0
Rem set PATH=%PATH%;C:\Users\IEUser\bin

if "%GRAALVM_HOME%"=="" (
    echo Please set GRAALVM_HOME
    exit /b
)
set JAVA_HOME=%GRAALVM_HOME%
set PATH=%GRAALVM_HOME%\bin;%PATH%
set /P NATIVEGL_VERSION=< .meta\VERSION

echo Building nativegl %NATIVEGL_VERSION%

call lein do clean, javac
mkdir target
mkdir target/jni
call javac -h target/jni src/c/NativeGL.java

call cl.exe /I"%JAVA_HOME%\include" /I"%JAVA_HOME%\include\win32" /I"target\jni" /I"SDL2-devel\SDL2-2.0.12\include" /MD /LD /Fenativegl.dll src/c/NativeGL.c SDL2-devel\SDL2-2.0.12\lib\x64\SDL2.lib

mkdir resources
copy nativegl.dll resources\
echo "present:"
dir

echo "src:"
dir src

echo "src\c:"
dir src\c

echo "resources:"
dir resources

call lein do clean, uberjar
if %errorlevel% neq 0 exit /b %errorlevel%

call %GRAALVM_HOME%\bin\gu install native-image

Rem the --no-server option is not supported in GraalVM Windows.
call %GRAALVM_HOME%\bin\native-image.cmd ^
  "-jar" "target/uberjar/nativegl-%NATIVEGL_VERSION%-standalone.jar" ^
  "-H:Name=nativegl" ^
  "-H:+ReportExceptionStackTraces" ^
  "-J-Dclojure.spec.skip-macros=true" ^
  "-J-Dclojure.compiler.direct-linking=true" ^
  "-H:ConfigurationFileDirectories=graal-configs/" ^
  "--initialize-at-build-time" ^
  "-H:Log=registerResource:" ^
  "-H:EnableURLProtocols=http" ^
  "--verbose" ^
  "--allow-incomplete-classpath" ^
  "--no-fallback" ^
  "-J-Xmx5g"

if %errorlevel% neq 0 exit /b %errorlevel%

call nativegl.exe --test-load

echo Creating zip archive
jar -cMf nativegl-%NATIVEGL_VERSION%-windows-amd64.zip nativegl.exe
